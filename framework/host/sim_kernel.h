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


#include "kernel.h"
#include <stdlib.h>
#include "verilator_kernel.h"
#include "verilated.h"
#include "server_main.h"

#ifndef HEADER_SIM_KERNEL
#define HEADER_SIM_KERNEL

#define COLS 4096
#define ROWS 4096



class SIM_Kernel: public Kernel {

private:

  VERILATOR_KERNEL *verilator_kernel;
  VerilatedVcdC* tfp;
  void* input_buff = 0;
  uint32_t* output_buff = 0;
  int data_size = 0;
  int resp_data_size = 0;
  int tick_cntr = 0;
  bool tracing_enabled = false;

  /*
  ** Step testbench
  */
  void tick();

public:

  int status = 1;
  bool initialized = false;

  SIM_Kernel();
  ~SIM_Kernel();

  void perror(const char * msg);

  /***********************************
  **                                **
  ** Simulation Interface functions **
  **                                **
  ************************************/

  /*
  ** Save the pointer to the input data
  */
  void writeKernelData(void * input, int data_size, int resp_data_size);
  void write_kernel_data(input_struct * input, int data_size);

  /*
  ** Enables trace waveform recording
  */
  void enable_tracing();
  /*
  ** Disables trace waveform recording
  */
  void disable_tracing();
  /*
  ** Saves trace waveform
  */
  void save_trace();
  
  /*
  ** Performs reset on user kernel
  */
  void reset_kernel();
  /*
  ** Starts computation
  */
  void start_kernel();
  /*
  ** Copy received data to an output buffer
  */
  void read_kernel_data(int h_a_output[], int data_size);
};

#endif
