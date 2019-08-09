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


#include "kernel.h"
#include <stdlib.h>
#include "Vmandelbrot_kernel.h"
#include "verilated.h"

#ifndef HEADER_SIM_KERNEL
#define HEADER_SIM_KERNEL

#define COLS 4096
#define ROWS 4096



class SIM_Kernel: public Kernel {

private:

  Vmandelbrot_kernel *verilator_kernel = new Vmandelbrot_kernel;
  void* input_buff;
  void* output_buff;
  int data_size;
  int resp_data_size;

public:

  int status = 1;
  bool initialized = false;

  SIM_Kernel();

  void perror(const char * msg);

  void writeKernelData(void * input, int data_size, int resp_data_size);
  void write_kernel_data(input_struct * input, int data_size);
  void start_kernel();
  void read_kernel_data(int h_a_output[], int data_size);
  void clean_kernel();

};

#endif
