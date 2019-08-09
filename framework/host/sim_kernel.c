/*
BSD 3-Clause License

Copyright (c) 2018, alessandrocomodi
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
** This is the library that holds all the functions that perform the
** communication with the FPGA device.
**
** The functions are described in the header file.
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
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/time.h>
#include "kernel.h"
#include "sim_kernel.h"
#include "verilated_vcd_c.h"


#include "server_main.h"


SIM_Kernel::SIM_Kernel() {
}

void SIM_Kernel::perror(const char * msg) {
  printf(msg);
  status = EXIT_FAILURE;
}



// TODO: Experimental WIP
void SIM_Kernel::writeKernelData(void * input, int data_size, int resp_data_size) {
printf("writeKernelData");
input_buff = input;
output_buff = new input_struct[resp_data_size];
this->data_size = data_size;
this->resp_data_size = resp_data_size;
}

void SIM_Kernel::write_kernel_data(input_struct * input, int data_size) {
  int err;

  err = 0;
  printf("Input size: %d\n", data_size);
  uint resp_length = (uint)(input->width * input->height) / 16;
  cout << "C++: (" << input->width << "x" << input->height << "), resp_length = " << resp_length << endl;

  input_buff = input;
  output_buff = new unsigned int [resp_length*16];
  this->data_size = data_size/64;
  this->resp_data_size = resp_length;
}



void SIM_Kernel::start_kernel() {

  printf("input size: %d\n", data_size);
  printf("output size: %d\n", resp_data_size);

int tick_cntr = 0;


Verilated::traceEverOn(true);
VerilatedVcdC* tfp = new VerilatedVcdC;

verilator_kernel->trace (tfp, 99);
tfp->open ("counter.vcd");

printf("start_kernel");
unsigned int send_cntr=0;
unsigned int recv_cntr=0;

for(int rst_cntr=0; rst_cntr<40; rst_cntr++) {
  tfp->dump (tick_cntr++);
  verilator_kernel->reset = 1;
  verilator_kernel->clk = 1;
  verilator_kernel->eval();
  tfp->dump (tick_cntr++);
  verilator_kernel->clk = 0;
  verilator_kernel->eval();
}


while ((send_cntr < data_size | recv_cntr < resp_data_size)) {
  //tfp->dump (tick_cntr++);
  verilator_kernel->reset = 0;
  verilator_kernel->clk = 1;
  verilator_kernel->eval();

  if(send_cntr < data_size) {
    unsigned int * input = (unsigned int *)input_buff;
    //printf("Input: %x\n", input[send_cntr*sizeof(unsigned int)*16]);
    verilator_kernel->in_avail = 1;
    for(int words = 0; words < 16; words++) {
      verilator_kernel->in_data[words]    = input[send_cntr*16 + words];
    }
    if(verilator_kernel->in_ready) {
      printf("Verilator send_cntr: %d\n", send_cntr);
      send_cntr++;
    }
    
  } else {
     verilator_kernel->in_avail = 0;
  }

  if(recv_cntr < resp_data_size) {
    verilator_kernel->out_ready = 1;
  } else {
    verilator_kernel->out_ready = 0;
  }

  if(recv_cntr < resp_data_size & verilator_kernel->out_avail) {
    unsigned int * output = (unsigned int *)output_buff;
    for(int words = 0; words < 16; words++) {
      verilator_kernel->out_ready = 1;
      output[recv_cntr*16 + words]  = verilator_kernel->out_data[words];
      //printf("Out data: %d\n", verilator_kernel->out_data[words]);
    }
    recv_cntr++;
    //printf("Verilator recv_cntr: %d\n", recv_cntr);
  }  
  //tfp->dump (tick_cntr++);
  verilator_kernel->clk = 0;
  verilator_kernel->eval();
}
printf("start_kernel returned\n");
tfp->close();
}

void SIM_Kernel::read_kernel_data(int h_a_output[], int data_size) {
  printf("read_kernel_data");
  memcpy(h_a_output, output_buff, sizeof(unsigned int)*resp_data_size*16);
  //TODO FREE BUFFER!!!!!
  free(output_buff);
}


void SIM_Kernel::clean_kernel() {
printf("Test");

}
