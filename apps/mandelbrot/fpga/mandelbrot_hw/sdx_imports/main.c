// This is a generated file. Use and modify at your own risk.
////////////////////////////////////////////////////////////////////////////////

/*******************************************************************************
Vendor: Xilinx
Associated Filename: main.c
#Purpose: This example shows a basic vector add +1 (constant) by manipulating
#         memory inplace.
*******************************************************************************/

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
#include <CL/opencl.h>

////////////////////////////////////////////////////////////////////////////////

#define NUM_WORKGROUPS (1)
#define WORKGROUP_SIZE (256)
#define MAX_LENGTH 65536

#define STR_VALUE(arg) #arg
#define GET_STRING(name) STR_VALUE(name)

#if defined(SDX_PLATFORM) && !defined(TARGET_DEVICE)
#define TARGET_DEVICE GET_STRING(SDX_PLATFORM)
#endif

#ifdef KERNEL
#define KERNEL_NAME GET_STRING(KERNEL)
#endif

#define COLS 128
#define ROWS 128
////////////////////////////////////////////////////////////////////////////////

typedef struct data {
    double coordinates[4];
    long size[2];
    long max_depth;
} data_struct;


int extractBit(int number, int k, int p){
    return (((1 << k) - 1) & (number >> p));
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

int main(int argc, char** argv)
{

    int err;                            // error code returned from api calls
    int check_status = 0;
//    const uint number_of_words = 32768; // 16KB of data


    cl_platform_id platform_id;         // platform id
    cl_device_id device_id;             // compute device id
    cl_context context;                 // compute context
    cl_command_queue commands;          // compute command queue
    cl_program program;                 // compute programs
    cl_kernel kernel;                   // compute kernel

    char cl_platform_vendor[1001];
    char target_device_name[1001] = TARGET_DEVICE;

    double h_a_input[7];                    // host memory for input vector
    int h_a_output[ROWS * COLS * 8];                   // host memory for output vector
    cl_mem d_a;                         // device memory used for a vector

    if (argc != 2) {
        printf("Usage: %s xclbin\n", argv[0]);
        return EXIT_FAILURE;
    }
    
    #ifndef KERNEL_NAME
        printf("Error: No Kernel Name specified\n");
        return EXIT_FAILURE;
    #endif
    // Fill our data sets with pattern
    int i = 0;
    for(i = 0; i < ROWS * COLS; i++) {
        h_a_output[i] = 0; 
    }

   // Get all platforms and then select Xilinx platform
    cl_platform_id platforms[16];       // platform id
    cl_uint platform_count;
    int platform_found = 0;
    err = clGetPlatformIDs(16, platforms, &platform_count);
    if (err != CL_SUCCESS) {
        printf("Error: Failed to find an OpenCL platform!\n");
        printf("Test failed\n");
        return EXIT_FAILURE;
    }
    printf("INFO: Found %d platforms\n", platform_count);

    // Find Xilinx Plaftorm
    for (unsigned int iplat=0; iplat<platform_count; iplat++) {
        err = clGetPlatformInfo(platforms[iplat], CL_PLATFORM_VENDOR, 1000, (void *)cl_platform_vendor,NULL);
        if (err != CL_SUCCESS) {
            printf("Error: clGetPlatformInfo(CL_PLATFORM_VENDOR) failed!\n");
            printf("Test failed\n");
            return EXIT_FAILURE;
        }
        if (strcmp(cl_platform_vendor, "Xilinx") == 0) {
            printf("INFO: Selected platform %d from %s\n", iplat, cl_platform_vendor);
            platform_id = platforms[iplat];
            platform_found = 1;
        }
    }
    if (!platform_found) {
        printf("ERROR: Platform Xilinx not found. Exit.\n");
        return EXIT_FAILURE;
    }

    // Connect to a compute device
    //
    int fpga = 0;
    #if defined (FPGA_DEVICE)
      fpga = 1;
    #endif
    printf("get device, fpga is %d \n", fpga);
    err = clGetDeviceIDs(platform_id, fpga ? CL_DEVICE_TYPE_ACCELERATOR : CL_DEVICE_TYPE_CPU,
                       1, &device_id, NULL);
    if (err != CL_SUCCESS)
    {
        printf("Error: Failed to create a device group!\n");
        printf("Test failed\n");
        return EXIT_FAILURE;
    }


    // Create a compute context
    //
    context = clCreateContext(0, 1, &device_id, NULL, NULL, &err);
    if (!context) {
        printf("Error: Failed to create a compute context!\n");
        printf("Test failed\n");
        return EXIT_FAILURE;
    }

    // Create a command commands
    commands = clCreateCommandQueue(context, device_id, 0, &err);
    if (!commands) {
        printf("Error: Failed to create a command commands!\n");
        printf("Error: code %i\n",err);
        printf("Test failed\n");
        return EXIT_FAILURE;
    }

    int status;

    // Create Program Objects
    // Load binary from disk
    unsigned char *kernelbinary;
    char *xclbin = argv[1];

    //------------------------------------------------------------------------------
    // xclbin
    //------------------------------------------------------------------------------
    printf("INFO: loading xclbin %s\n", xclbin);
    int n_i0 = load_file_to_memory(xclbin, (char **) &kernelbinary);
    if (n_i0 < 0) {
        printf("failed to load kernel from xclbin: %s\n", xclbin);
        printf("Test failed\n");
        return EXIT_FAILURE;
    }

    size_t n0 = n_i0;

    // Create the compute program from offline
    program = clCreateProgramWithBinary(context, 1, &device_id, &n0,
                                        (const unsigned char **) &kernelbinary, &status, &err);

    if ((!program) || (err!=CL_SUCCESS)) {
        printf("Error: Failed to create compute program from binary %d!\n", err);
        printf("Test failed\n");
        return EXIT_FAILURE;
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
        return EXIT_FAILURE;
    }

    // Create the compute kernel in the program we wish to run
    //
     kernel = clCreateKernel(program, KERNEL_NAME, &err);
    if (!kernel || err != CL_SUCCESS) {
        printf("Error: Failed to create compute kernel!\n");
        printf("Test failed\n");
        return EXIT_FAILURE;
    }

    // Create the input and output arrays in device memory for our calculation
    d_a = clCreateBuffer(context,  CL_MEM_READ_WRITE,  sizeof(int) * COLS * ROWS * 8, NULL, NULL);

    if (!(d_a)) {
        printf("Error: Failed to allocate device memory!\n");
        printf("Test failed\n");
        return EXIT_FAILURE;
    }

    double x = -1.744444444444;
    double y = 0;

    double scale_factor = 1.0;

    double pix_x, pix_y;
    double x_min, y_min;
    
    long size_x = 128;
    long size_y = 128;
    double pix_size;

    pix_size = ((4.0/scale_factor) / size_x);

    x_min = x - size_x/2 * pix_size;
    y_min = y - size_y/2 * pix_size;
/*
    h_a_input[0] = x_min;
    h_a_input[1] = y_min;
    h_a_input[2] = pix_x;
    h_a_input[3] = pix_y;
    h_a_input[4] = size_x;
    h_a_input[5] = size_y;

*/
    data_struct input;

    input.coordinates[0] = x_min;
    input.coordinates[1] = y_min;
    input.coordinates[2] = pix_size;
    input.coordinates[3] = pix_size;

    input.size[0] = size_x;
    input.size[1] = size_y;

    input.max_depth = 32;

    printf("Min x: %lf - Min y: %lf\nPix_x: %lf - Pix_y: %lf\nSize X: %ld - Size Y: %ld\nMAX DEPTH: %ld\n", x_min, y_min, pix_size, pix_size, input.size[0], input.size[1], input.max_depth);

        // Write our data set into the input array in device memory
    for(int l = 0; l < 50; l++){

        if (l) {
            scale_factor *= 1.1;
            pix_size = ((4.0/scale_factor) / size_x);

            x_min = x - size_x/2 * pix_size;
            y_min = y - size_y/2 * pix_size;

            input.coordinates[0] = x_min;
            input.coordinates[1] = y_min;
            input.coordinates[2] = pix_size;
            input.coordinates[3] = pix_size;

            input.size[0] = size_x;
            input.size[1] = size_y;

            input.max_depth = 32;
        }

        err = clEnqueueWriteBuffer(commands, d_a, CL_TRUE, 0, sizeof(double) * 7, &input, 0, NULL, NULL);
        if (err != CL_SUCCESS) {
            printf("Error: Failed to write to source array h_a_input!\n");
            printf("Test failed\n");
            return EXIT_FAILURE;
        }
        
        // Set the arguments to our compute kernel
        // int vector_length = MAX_LENGTH;
        err = 0;
        uint d_ctrl_length = (uint)(size_x * size_y) / 16;
        err |= clSetKernelArg(kernel, 0, sizeof(uint), &d_ctrl_length);
        err |= clSetKernelArg(kernel, 1, sizeof(cl_mem), &d_a);

        if (err != CL_SUCCESS) {
            printf("Error: Failed to set kernel arguments! %d\n", err);
            printf("Test failed\n");
            return EXIT_FAILURE;
        }


        // Execute the kernel over the entire range of our 1d input data set
        // using the maximum number of work group items for this device

        err = clEnqueueTask(commands, kernel, 0, NULL, NULL);
        if (err) {
                printf("Error: Failed to execute kernel! %d\n", err);
                printf("Test failed\n");
                return EXIT_FAILURE;
            }

        // Read back the results from the device to verify the output
        //
        cl_event readevent;
        clFinish(commands);

        err = 0;
        err |= clEnqueueReadBuffer( commands, d_a, CL_TRUE, 0, sizeof(int) * size_x * size_y, h_a_output, 0, NULL, &readevent );

        if (err != CL_SUCCESS) {
                printf("Error: Failed to read output array! %d\n", err);
                printf("Test failed\n");
                return EXIT_FAILURE;
        }
        clWaitForEvents(1, &readevent);
        // Check Results
        
        int j = 0;
        int k, value;
        char fn[80];
        snprintf(fn, sizeof(fn), "mandelbrot%d.ppm", l);
        short depth;
        FILE *fp = fopen(fn, "wb");
        (void) fprintf(fp, "P6\n%d %d\n255\n", size_x, size_y);
        static unsigned char color[3];
        for (uint i = 0; i < size_x * size_y; i++) {
          for(int k = 0; k < 1; k++){
                //depth = ((h_a_output[i] >> k*32) & 0xFFFFFFFF);
                depth = h_a_output[i];
                if(h_a_output[i] != 0) {
                
                    color[0] = int(depth) % 255;
                    color[1] = int(depth) % 255;
                    color[2] = int(depth) % 255;
                    (void) fwrite(color, 1, 3, fp);
                } else {
                    check_status = 1;
                }
            }
        }

        (void) fclose(fp);

    }

        clReleaseMemObject(d_a);
    //--------------------------------------------------------------------------
    // Shutdown and cleanup
    //-------------------------------------------------------------------------- 
    //clReleaseMemObject(d_a);
    clReleaseProgram(program);
    clReleaseKernel(kernel);
    clReleaseCommandQueue(commands);
    clReleaseContext(context);

    if (check_status) {
        printf("INFO: Test failed\n");
        return EXIT_FAILURE;
    } else {
        printf("INFO: Test completed successfully.\n");
    }


} // end of main
