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

cl_data_types perror(const char * msg, cl_data_types cl){
  printf(msg);
  cl.status = EXIT_FAILURE;
  return cl;
}

int load_file_to_memory(const char *filename, char **result)
{
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

cl_data_types initialize_platform(){
  cl_data_types cl;
  // Get all platforms and then select Xilinx platform
  cl_platform_id platforms[16];       // platform id
  cl_uint platform_count;
  char cl_platform_vendor[1001];

  int err;

  int platform_found = 0;
  err = clGetPlatformIDs(16, platforms, &platform_count);
  if (err != CL_SUCCESS)
    return perror("Error: Failed to find an OpenCL platform!\nTest failed\n", cl);

  printf("INFO: Found %d platforms\n", platform_count);

  // Finds an available Xilinx Platform
  for (unsigned int iplat=0; iplat<platform_count; iplat++) {
    err = clGetPlatformInfo(platforms[iplat], CL_PLATFORM_VENDOR, 1000, (void *)cl_platform_vendor,NULL);
    if (err != CL_SUCCESS)
      return perror("Error: clGetPlatformInfo(CL_PLATFORM_VENDOR) failed!\nTest failed\n", cl);

    if (strcmp(cl_platform_vendor, "Xilinx") == 0) {
      printf("INFO: Selected platform %d from %s\n", iplat, cl_platform_vendor);
      cl.platform_id = platforms[iplat];
      //printf("INFO: Platform id = %d\n", cl.platform_id);
      platform_found = 1;
    }
  }

  if (!platform_found) 
    return perror("ERROR: Platform Xilinx not found. Exit.\n", cl);


  // Connection to a compute device
  int fpga = 0;
  #if defined (FPGA_DEVICE)
      fpga = 1;
  #endif
  printf("get device, fpga is %d \n", fpga);
  err = clGetDeviceIDs(cl.platform_id, fpga ? CL_DEVICE_TYPE_ACCELERATOR : CL_DEVICE_TYPE_CPU,
               1, &cl.device_id, NULL);
  if (err != CL_SUCCESS)
    return perror("Error: Failed to create a device group!\nTest failed\n", cl);

  // Creation of a compute context
  cl.context = clCreateContext(0, 1, &cl.device_id, NULL, NULL, &err);
  if (!cl.context)
    return perror("Error: Failed to create a compute context!\nTest failed\n", cl);

  // Creation a command commands
  cl.commands = clCreateCommandQueue(cl.context, cl.device_id, 0, &err);
  if (!cl.commands) 
    return perror("Error: Failed to create a command commands!\nTest failed\n", cl);

  cl.status = 0;
  return cl;
}

cl_data_types initialize_kernel(cl_data_types opencl, const char *xclbin, const char *kernel_name, int memory_size){
  cl_data_types cl = opencl;

  int err;
  // Create Program Objects
  // Load binary from disk
  unsigned char *kernelbinary;

  //------------------------------------------------------------------------------
  // xclbin
  //------------------------------------------------------------------------------
  printf("INFO: loading xclbin %s\n", xclbin);
  int n_i0 = load_file_to_memory(xclbin, (char **) &kernelbinary);
  if (n_i0 < 0) 
    return perror("Error: Failed to load kernel from the xclbin provided\nTest failed\n", cl);

  size_t n0 = n_i0;

  // Create the compute program from offline
  cl.program = clCreateProgramWithBinary(cl.context, 1, &cl.device_id, &n0,
                                      (const unsigned char **) &kernelbinary, &cl.status, &err);

  if ((!cl.program) || (err!=CL_SUCCESS)) 
      return perror("Error: Failed to create a compute program binary!\nTest failed\n", cl);

  // Build the program executable
  //
  err = clBuildProgram(cl.program, 0, NULL, NULL, NULL, NULL);
  if (err != CL_SUCCESS) {
      size_t len;
      char buffer[2048];

      printf("Error: Failed to build program executable!\n");
      clGetProgramBuildInfo(cl.program, cl.device_id, CL_PROGRAM_BUILD_LOG, sizeof(buffer), buffer, &len);
      printf("%s\n", buffer);
      printf("Test failed\n");
      cl.status = EXIT_FAILURE;
      return cl;
  }

  // Create the compute kernel in the program we wish to run
  cl.kernel = clCreateKernel(cl.program, kernel_name, &err);
  if (!cl.kernel || err != CL_SUCCESS)
    return perror("Error: Failed to create a compute kernel!\nTest failed\n", cl);

  // Create the input and output arrays in device memory for our calculation
  //
  // This must be modified by the user if the number (or name) of the arguments is different from this 
  // application
  //
  cl.d_a = clCreateBuffer(cl.context,  CL_MEM_READ_WRITE,  sizeof(int) * memory_size, NULL, NULL);

  if (!(cl.d_a)) 
    return perror("Error: Failed to allocate device memory!\nTest failed\n", cl);

  cl.status = 0;
  return cl;
}

cl_data_types write_kernel_data(cl_data_types cl, double h_a_input[], int data_size){
  int err;
  err = clEnqueueWriteBuffer(cl.commands, cl.d_a, CL_TRUE, 0, data_size, h_a_input, 0, NULL, NULL);
  if (err != CL_SUCCESS)
    return perror("Error: Failed to write to source array h_a_input!\nTest failed\n", cl);

  // Set the arguments of the kernel. This must be modified by the user depending on the number (or name)
  // of the arguments
  err = 0;
  err |= clSetKernelArg(cl.kernel, 0, sizeof(cl_mem), &cl.d_a);

  if (err != CL_SUCCESS) 
    return perror("Error: Failed to set kernel arguments!\nTest failed\n", cl);

  return cl;
}

cl_data_types write_kernel_data(cl_data_types cl, input_struct * input, int data_size){
  int err;
  err = clEnqueueWriteBuffer(cl.commands, cl.d_a, CL_TRUE, 0, data_size, input, 0, NULL, NULL);
  if (err != CL_SUCCESS)
    return perror("Error: Failed to write to source array h_a_input!\nTest failed\n", cl);

  // Set the arguments of the kernel. This must be modified by the user depending on the number (or name)
  // of the arguments
  err = 0;  
  uint d_ctrl_length = (uint)(input->width * input->height) / 16;
  err |= clSetKernelArg(cl.kernel, 0, sizeof(uint), &d_ctrl_length);
  err |= clSetKernelArg(cl.kernel, 1, sizeof(cl_mem), &cl.d_a);

  if (err != CL_SUCCESS) 
    return perror("Error: Failed to set kernel arguments!\nTest failed\n", cl);

  return cl;
}

cl_data_types start_kernel(cl_data_types cl){
  int err;
  err = clEnqueueTask(cl.commands, cl.kernel, 0, NULL, NULL);
  if (err) 
    return perror("Error: Failed to execute kernel!\nTest failed\n", cl);

  // Read back the results from the device to verify the output
  //

  cl.status = 0;
  return cl;
}

cl_data_types read_kernel_data(cl_data_types cl, int h_a_output[], int data_size){
  int err;
  cl_event readevent;

  clFinish(cl.commands);
  
  err = clEnqueueReadBuffer(cl.commands, cl.d_a, CL_TRUE, 0, data_size, h_a_output, 0, NULL, &readevent);

  if (err != CL_SUCCESS)
    return perror("Error: Failed to read output array h_a_output!\nTest failed\n", cl);

  clWaitForEvents(1, &readevent);
  return cl;
}

cl_data_types clean_kernel(cl_data_types cl){
  // This has to be modified by the user if the number (or name) of arguments is different
  clReleaseMemObject(cl.d_a);
  
  clReleaseProgram(cl.program);
  clReleaseKernel(cl.kernel);
  clReleaseCommandQueue(cl.commands);
  clReleaseContext(cl.context);
  return cl;
}
