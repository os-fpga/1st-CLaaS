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

#include <CL/opencl.h>


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

public:
  /*
  ** OpenCL characterization of the FPGA.
  */
  cl_platform_id platform_id;         // platform id
  cl_device_id device_id;             // compute device id
  cl_context context;                 // compute context
  cl_command_queue commands;          // compute command queue
  cl_program program;                 // compute programs
  cl_kernel kernel;                   // compute kernel
  cl_mem read_mem;                    // device memory read by kernel
  cl_mem write_mem;                   // device memory written by kernel
  int status = 1;
  bool initialized = false;

  Kernel();

  /*
  ** Utility function to print errors
  */
  void perror(const char * msg);

  /*
  ** Function to load the binary program in RAM in order to write it into the FPGA device
  */
  int load_file_to_memory(const char *filename, char **result);

  /*****************************
  **                          **
  ** FPGA Interface functions **
  **                          **
  *****************************/

  /*
  ** Initialize FPGA platform
  */
  void initialize_platform();


  /*
  ** Initialize the Kernel application.
  ** Allocation of the memory space for the various arguments passed to the device
  */
  void initialize_kernel(const char *xclbin, const char *kernel_name, int memory_size);

  /*
  ** Write data onto the board or device memory that will be consumed by the Kernel
  ** h_a_input: array containing data to be written on the device memory
  ** data_size: size of the data array in bytes
  */
  void write_kernel_data(double h_a_input[], int data_size);
  void writeKernelData(void * input, int data_size);
  void write_kernel_data(input_struct * input, int data_size);

  /*
  ** Starts the computation of the Kernel by injecting the "ap_start" signal
  */
  void start_kernel();

  /*
  ** Read data from the board or device memory. The data is produced by the Kernel
  ** h_a_output: array pointer on which data will be written
  ** data_size: size of data to be read by the kernel
  */
  void read_kernel_data(int h_a_output[], int data_size);

  /*
  ** Releases all the OpenCL components
  */
  void clean_kernel();

};

#endif
