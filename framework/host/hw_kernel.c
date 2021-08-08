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
#include <CL/opencl.h>

#include "server_main.h"


HW_Kernel::HW_Kernel() {
}

void HW_Kernel::perror(const char * msg) {
  cout << msg;
  status = EXIT_FAILURE;
}

int HW_Kernel::load_file_to_memory(const char *filename, char **result) {
  uint size = 0;
  FILE *f = fopen(filename, "rb");
  if (f == NULL) {
    *result = NULL;
    return -1; // -1 means file opening fail
  }
  fseek(f, 0, SEEK_END);
  size = ftell(f);
  fseek(f, 0, SEEK_SET);
  *result = (char *)malloc(size+1);
  if (size != fread(*result, sizeof(char), size, f)) {
    free(*result);
    return -2; // -2 means file reading fail
  }
  fclose(f);
  (*result)[size] = 0;
  return size;
}

void HW_Kernel::initialize_platform() {
  // Get all platforms and then select Xilinx platform
  cl_platform_id platforms[16];       // platform id
  cl_uint platform_count;
  char cl_platform_vendor[1001];

  int err;

  int platform_found = 0;
  err = clGetPlatformIDs(16, platforms, &platform_count);
  if (err != CL_SUCCESS) {
    perror("Error: Failed to find an OpenCL platform!\nTest failed\n");
    return;
  }

  printf("INFO: Found %d platforms\n", platform_count);

  // Finds an available Xilinx Platform
  for (unsigned int iplat=0; iplat<platform_count; iplat++) {
    err = clGetPlatformInfo(platforms[iplat], CL_PLATFORM_VENDOR, 1000, (void *)cl_platform_vendor,NULL);
    if (err != CL_SUCCESS) {
      perror("Error: clGetPlatformInfo(CL_PLATFORM_VENDOR) failed!\nTest failed\n");
      return;
    }

    if (strcmp(cl_platform_vendor, "Xilinx") == 0) {
      printf("INFO: Selected platform %d from %s\n", iplat, cl_platform_vendor);
      platform_id = platforms[iplat];
      //printf("INFO: Platform id = %d\n", platform_id);
      platform_found = 1;
    }
  }

  if (!platform_found) {
    perror("ERROR: Platform Xilinx not found. Exit.\n");
    return;
  }

  // Connection to a compute device
  int fpga = 0;
  #if defined (FPGA_DEVICE)
      fpga = 1;
  #endif
  printf("get device, fpga is %d \n", fpga);
  err = clGetDeviceIDs(platform_id, fpga ? CL_DEVICE_TYPE_ACCELERATOR : CL_DEVICE_TYPE_CPU,
               1, &device_id, NULL);
  if (err != CL_SUCCESS) {
    perror("Error: Failed to create a device group!\nTest failed\n");
    return;
  }
  // Creation of a compute context
  context = clCreateContext(0, 1, &device_id, NULL, NULL, &err);
  if (!context) {
    perror("Error: Failed to create a compute context!\nTest failed\n");
    return;
  }

  // Creation a command commands
  commands = clCreateCommandQueue(context, device_id, 0, &err);
  if (!commands) {
    perror("Error: Failed to create a command commands!\nTest failed\n");
    return;
  }

  status = 0;
}

void HW_Kernel::initialize_kernel(const char *xclbin, const char *kernel_name, int memory_size) {
  int err;
  // Create Program Objects
  // Load binary from disk
  unsigned char *kernelbinary;

  //------------------------------------------------------------------------------
  // xclbin
  //------------------------------------------------------------------------------
  printf("INFO: loading xclbin %s\n", xclbin);
  int n_i0 = load_file_to_memory(xclbin, (char **) &kernelbinary);
  if (n_i0 < 0) {
    perror("Error: Failed to load kernel from the xclbin provided\nTest failed\n");
    return;
  }
  size_t n0 = n_i0;

  // Create the compute program from offline
  program = clCreateProgramWithBinary(context, 1, &device_id, &n0,
                                      (const unsigned char **) &kernelbinary, &status, &err);
  // TODO: Looks like kernelbinary is never deallocated. What's the right behavior, here?

  if ((!program) || (err!=CL_SUCCESS)) {
    perror("Error: Failed to create a compute program binary!\nTest failed\n");
    return;
  }

  // Build the program executable
  //
  err = clBuildProgram(program, 0, NULL, NULL, NULL, NULL);
  if (err != CL_SUCCESS) {
      size_t len;
      char buffer[2048];

      printf("Error: Failed to build program executable!\n");
      clGetProgramBuildInfo(program, device_id, CL_PROGRAM_BUILD_LOG, sizeof(buffer), buffer, &len);
      printf("%s\n", buffer);
      printf("Test failed\n");
      status = EXIT_FAILURE;
  }

  // Create the compute kernel in the program we wish to run
  kernel = clCreateKernel(program, kernel_name, &err);
  if (!kernel || err != CL_SUCCESS) {
    perror("Error: Failed to create a compute kernel!\nTest failed\n");
    return;
  }

  // Create the input and output arrays in device memory for our calculation
  //
  // This must be modified by the user if the number (or name) of the arguments is different from this
  // application
  //
  //read_mem  = clCreateBuffer(context, CL_MEM_READ_WRITE,  sizeof(int) * memory_size, NULL, NULL);
  //write_mem = read_mem;
  read_mem  = clCreateBuffer(context, CL_MEM_READ_ONLY ,  sizeof(int) * memory_size, NULL, NULL);  // TODO: Fix memory_size.
  write_mem = clCreateBuffer(context, CL_MEM_WRITE_ONLY,  sizeof(int) * memory_size, NULL, NULL);

  if (!(write_mem) || !(read_mem)) {
    perror("Error: Failed to allocate device memory!\nTest failed\n");
    return;
  }

  status = 0;
}

void HW_Kernel::write_kernel_data(double h_a_input[], int data_size){
  perror("Oh! I thought write_kernel_data(double h_a_input[], int data_size) was unused.\n");

  int err;
  err = clEnqueueWriteBuffer(commands, read_mem, CL_TRUE, 0, data_size, h_a_input, 0, NULL, NULL);
  if (err != CL_SUCCESS) {
    perror("Error: Failed to write to source array h_a_input!\nTest failed\n");
    return;
  }

  // Set the arguments of the kernel. This must be modified by the user depending on the number (or name)
  // of the arguments
  err = 0;
  err |= clSetKernelArg(kernel, 0, sizeof(cl_mem), &read_mem);
  err |= clSetKernelArg(kernel, 1, sizeof(cl_mem), &write_mem);

  if (err != CL_SUCCESS) {
    perror("Error: Failed to set kernel arguments!\nTest failed\n");
    return;
  }
}

// TODO: Experimental WIP
void HW_Kernel::writeKernelData(void * input, int data_size, int resp_data_size) {
  int err;
  err = clEnqueueWriteBuffer(commands, read_mem, CL_TRUE, 0, data_size, input, 0, NULL, NULL);
  if (err != CL_SUCCESS) {
    perror("Error: Failed to write to source array h_a_input!\nTest failed\n");
    return;
  }

  // Set the arguments of the kernel. This must be modified by the user depending on the number (or name)
  // of the arguments
  err = 0;
  err |= clSetKernelArg(kernel, 0, sizeof(uint), &data_size);
  err |= clSetKernelArg(kernel, 1, sizeof(uint), &resp_data_size);
  err |= clSetKernelArg(kernel, 2, sizeof(cl_mem), &read_mem);
  err |= clSetKernelArg(kernel, 3, sizeof(cl_mem), &write_mem);

  if (err != CL_SUCCESS) {
    perror("Error: Failed to set kernel arguments!\nTest failed\n");
    return;
  }
}

void HW_Kernel::write_kernel_data(input_struct * input, int data_size) {
  int err;
  err = clEnqueueWriteBuffer(commands, read_mem, CL_TRUE, 0, data_size, input, 0, NULL, NULL);
  if (err != CL_SUCCESS) {
    perror("Error: Failed to write to source array h_a_input!\nTest failed\n");
    return;
  }

  // Set the arguments of the kernel. This must be modified by the user depending on the number (or name)
  // of the arguments
  err = 0;
  uint resp_length = (uint)(input->width * input->height) / 16 * HostApp::DATA_WIDTH_BYTES;
  cout << "C++: (" << input->width << "x" << input->height << "), resp_length = " << resp_length << endl;
  //perror("C++: UNTESTED write_kernel_data\n");
  err |= clSetKernelArg(kernel, 0, sizeof(uint), &data_size);
  err |= clSetKernelArg(kernel, 1, sizeof(uint), &resp_length);
  err |= clSetKernelArg(kernel, 2, sizeof(cl_mem), &read_mem);
  err |= clSetKernelArg(kernel, 3, sizeof(cl_mem), &write_mem);

  if (err != CL_SUCCESS) {
    perror("Error: Failed to set kernel arguments!\nTest failed\n");
    return;
  }
}

void HW_Kernel::start_kernel() {
  int err;
  err = clEnqueueTask(commands, kernel, 0, NULL, NULL);
  if (err) {
    perror("Error: Failed to execute kernel!\nTest failed\n");
    return;
  }

  // Read back the results from the device to verify the output
  //

  status = 0;
}

void HW_Kernel::read_kernel_data(int h_a_output[], int data_size) {
  int err;
  cl_event readevent;

  clFinish(commands);

  /* Prepopulate buffer for debug
  for (int i = 0; i < data_size / (int)sizeof(int); i++) {
    h_a_output[i] = i;
  }
  */
  err |= clSetKernelArg(kernel, 0, sizeof(uint), &data_size);

  err = clEnqueueReadBuffer(commands, write_mem, CL_TRUE, 0, data_size, h_a_output, 0, NULL, &readevent);

  if (err != CL_SUCCESS) {
    perror("Error: Failed to read output array h_a_output!\nTest failed\n");
    return;
  }

  clWaitForEvents(1, &readevent);
}

void HW_Kernel::clean_kernel() {
  // This has to be modified by the user if the number (or name) of arguments is different
  clReleaseMemObject(read_mem);
  clReleaseMemObject(write_mem);

  clReleaseProgram(program);
  clReleaseKernel(kernel);
  clReleaseCommandQueue(commands);
  clReleaseContext(context);
}
