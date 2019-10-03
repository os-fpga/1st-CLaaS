/*
BSD 3-Clause License

Copyright (c) 2019, Akos Hadnagy
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

* Neither the name of the copyright holder nor the names of its
  contributors may be used to endorse or promote products derived from
  this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

/*
**
** This library performs the Verilator-based simulation of the user kernel.
**
*/

#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <unistd.h>
#include <assert.h>
#include <stdbool.h>
#include <cstdint>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <atomic>
#include <thread>
#include <mutex>
#include "kernel.h"
#include "sim_kernel.h"
#include "verilated_vcd_c.h"


const int SIM_Kernel::MAX_PHASES = 10000;
const int SIM_Kernel::MAX_TRACE_PHASES = 1000;

SIM_Kernel::SIM_Kernel() {
  this->verilator_kernel = new VERILATOR_KERNEL;
  Verilated::traceEverOn(true);
  this->tfp = new VerilatedVcdC;

}

SIM_Kernel::~SIM_Kernel() {
  tfp->close();
  delete tfp;
  delete verilator_kernel;
}

void SIM_Kernel::perror(const char * msg) {
  cout << msg;
  status = EXIT_FAILURE;
}

void SIM_Kernel::enable_tracing() {
  verilator_kernel->trace (tfp, 99);
  tfp->open ("../out/sim/trace.vcd");
  tracing_enabled = true;
  trace_phase_cnt = 0;
}

void SIM_Kernel::disable_tracing() {
  tracing_enabled = false;
}

void SIM_Kernel::save_trace() {
  tfp->close();
}

void SIM_Kernel::tick() {
  //verilator_kernel->reset = 0;
  verilator_kernel->clk = !verilator_kernel->clk;
  verilator_kernel->eval();
  if (tracing_enabled) {
    tfp->dump (phase_cnt);
    trace_phase_cnt++;
    
    // A quick-n-dirty protection against kernels that don't complete.
    // Close the trace and exit if phase_cnt > MAX.
    if (trace_phase_cnt > MAX_TRACE_PHASES) {
      save_trace();
      cout << "Traced more than " << MAX_TRACE_PHASES << " phases. Exiting." << endl;
      exit(1);
    }
  }
  if (phase_cnt > MAX_PHASES) {
      cout << "Kernel failed to complete within " << MAX_PHASES << " phases. Exiting." << endl;
      exit(1);
  }
  phase_cnt++;
}

void SIM_Kernel::reset_kernel() {
  verilator_kernel->in_avail = 0;
  verilator_kernel->out_ready = 0;
  verilator_kernel->reset = 1;
  //TODO: parameterize the reset duration
  for(int rst_cntr=0; rst_cntr<10; rst_cntr++) {
    tick();
  }
  verilator_kernel->reset = 0;
}

void SIM_Kernel::writeKernelData(void * input, int data_size, int resp_data_size) {
  input_buff = input;
  output_buff = new uint32_t[(resp_data_size/HostApp::DATA_WIDTH_BYTES)*HostApp::DATA_WIDTH_WORDS];
  this->data_size = data_size/HostApp::DATA_WIDTH_BYTES;
  this->resp_data_size = resp_data_size/HostApp::DATA_WIDTH_BYTES;
}

void SIM_Kernel::write_kernel_data(input_struct * input, int data_size) {
  uint resp_length = (uint)(input->width * input->height) / HostApp::DATA_WIDTH_WORDS;
  cout << "Verilator: (" << input->width << "x" << input->height << "), resp_length = " << resp_length << endl;

  input_buff = input;
  output_buff = new uint32_t [resp_length*HostApp::DATA_WIDTH_WORDS];
  this->data_size = data_size/HostApp::DATA_WIDTH_BYTES;
  this->resp_data_size = resp_length;
}


// A data buffer is available to send.
void SIM_Kernel::start_kernel() {
  verilator_kernel->clk = 0;

  unsigned int send_cntr=0;
  unsigned int recv_cntr=0;

  while ((send_cntr < data_size) || (recv_cntr < resp_data_size)) {
    tick();

    if(recv_cntr < resp_data_size) {
      verilator_kernel->out_ready = 1;
    } else {
      verilator_kernel->out_ready = 0;
    }
    //For the case where out_ready combinatorially effects the signals read in the code below. Such as vadd, which is purely combinatorial.
    //TODO: unnecessary overhead in most cases, migh want a mechanism to diasble
    verilator_kernel->eval();
  
    if(recv_cntr < resp_data_size && verilator_kernel->out_avail) {
      uint32_t * output = (uint32_t *)output_buff;
      for(int words = 0; words < HostApp::DATA_WIDTH_WORDS; words++) {
        output[recv_cntr*HostApp::DATA_WIDTH_WORDS + words] = verilator_kernel->out_data[words];
      }
      recv_cntr++;
      //printf("Verilator recv_cntr: %d\n", recv_cntr);
    }  

    if(send_cntr < data_size) {
      uint32_t * input = (uint32_t *)input_buff;
      verilator_kernel->in_avail = 1;
      for(int words = 0; words < HostApp::DATA_WIDTH_WORDS; words++) {
        verilator_kernel->in_data[words] = input[send_cntr*HostApp::DATA_WIDTH_WORDS + words];
      }
      if(verilator_kernel->in_ready) {
        //printf("Verilator send_cntr: %d\n", send_cntr);
        send_cntr++;
      }
      
    } else {
       verilator_kernel->in_avail = 0;
    }

    tick();
  }
}

void SIM_Kernel::read_kernel_data(int h_a_output[], int data_size) {
  memcpy(h_a_output, output_buff, sizeof(uint32_t)*resp_data_size*HostApp::DATA_WIDTH_WORDS);
  delete output_buff;
}