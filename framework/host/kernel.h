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
** Header file for the Kernel class which provides the interface through which to communicate with
** the custom FPGA kernel logic.
** All OpenCL calls are performed within this class.
**
** We have created different functions in order to gain more control on
** the FPGA device:
**    - initialize_platform   --> initializes the platform
**    - initialize_kernel     --> initializes the kernel
**    - write_kernel_data     --> writes data to FPGA board memory
**    - read_kernel_data      --> reads data from FPGA board memory
**    - start_kernel          --> injects the start signal to the FPGA
**    - clean_kernel          --> clean the OpenCL variables
**
** Author: Alessandro Comodi, Politecnico di Milano
*/

#ifndef HEADER_KERNEL
#define HEADER_KERNEL

#define COLS 4096
#define ROWS 4096



/*
** Definition of the input data structure for the kernel
** To be modified by the user if he sends different kind of data
** The following struct is specific to mandelbrot set calculation
** TODO: Doesn't belong here.
*/
typedef struct data_struct {
  double coordinates[4];
  long width;
  long height;
  long max_depth;
} input_struct;


class Kernel {

protected:
  int status = 1;
  bool initialized = false;

public:
  virtual void perror(const char * msg) = 0;;
  virtual void reset_kernel() = 0;
  virtual void writeKernelData(void * input, int data_size, int resp_data_size) = 0;
  virtual void write_kernel_data(input_struct * input, int data_size) = 0;
  virtual void start_kernel() = 0;
  virtual void read_kernel_data(int h_a_output[], int data_size) = 0;
  virtual void clean_kernel() {};
  virtual void enable_traing() {};
  virtual void disable_trcaing() {};
  virtual void save_trace() {};

};

#endif
