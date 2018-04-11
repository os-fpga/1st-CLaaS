/*
**
** This is the header file containing the definitions of the functions
** used in "kernel.c" host file. 
** The kernel functions will communicate with the FPGA device through
** OpenCL calls. 
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
** Definition of the data structure type containing all the necessary
** OpenCL datatypes used to interface with the FPGA
*/
typedef struct opencl {
  cl_platform_id platform_id;         // platform id
  cl_device_id device_id;             // compute device id
  cl_context context;                 // compute context
  cl_command_queue commands;          // compute command queue
  cl_program program;                 // compute programs
  cl_kernel kernel;                   // compute kernel
  cl_mem d_a;                         // device memory used for a vector
  int status;
  bool initialized = false;
} cl_data_types;

/*
** Definition of the input data structure for the kernel
** To be modified by the user if he sends different kind of data
** The following struct is specific to mandelbrot set calculation
*/
typedef struct data_struct {
  double coordinates[4];
  long width;
  long height;
  long max_depth;
} input_struct;

/*
** Utility function to print errors
*/
cl_data_types perror(const char * msg, cl_data_types cl);

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
cl_data_types initialize_platform();


/*
** Initialize the Kernel application.
** Allocation of the memory space for the various arguments passed to the device
*/
cl_data_types initialize_kernel(cl_data_types cl, const char *xclbin, const char *kernel_name, int memory_size);

/*
** Write data onto the board or device memory that will be consumed by the Kernel
** cl: OpenCL data structure
** h_a_input: array containing data to be written on the device memory
** data_size: size of the data array
*/
cl_data_types write_kernel_data(cl_data_types cl, double h_a_input[], int data_size);

cl_data_types write_kernel_data(cl_data_types cl, input_struct * input, int data_size);

/*
** Starts the computation of the Kernel by injecting the "ap_start" signal
*/
cl_data_types start_kernel(cl_data_types cl);

/*
** Read data from the board or device memory. The data is produced by the Kernel
** cl: OpenCL data structure
** h_a_output: array pointer on which data will be written
** data_size: size of data to be read by the kernel
*/
cl_data_types read_kernel_data(cl_data_types cl, int h_a_output[], int data_size);

/*
** Releases all the OpenCL components
*/
cl_data_types clean_kernel(cl_data_types cl);

#endif