/*
**
** The main application that is needed to communicate with the hardware and the 
** python server.
**
** It accepts socket communications to transmit data and commands.
** The access to the hardware resources is possible through the use of a library
** "kernel.c" which contains all the functions that are needed to utilize the FPGA device.
**
** There is a set of functions that handle the communication through the socket.
**
** Author: Alessandro Comodi, Politecnico di Milano
**
** TODO: There's still a lot of image-specific content here. Partition cleanly.
*/

#include <fcntl.h>
#include <cstdio>
#include <cstdlib>
#include <string.h>
#include <iostream>
#include <math.h>
#include <unistd.h>
#include <assert.h>
#include <stdbool.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <time.h>
#include <stdint.h>
#include <stdbool.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <string.h>
#ifdef OPENCL
#include <CL/opencl.h>
#include "kernel.h"
#endif

#include "lodepng.h"
#include "protocol.h"
#include "mandelbrot.h"

#define STR_VALUE(arg) #arg
#define GET_STRING(name) STR_VALUE(name)

#if defined(SDX_PLATFORM) && !defined(TARGET_DEVICE)
#define TARGET_DEVICE GET_STRING(SDX_PLATFORM)
#endif

#ifdef KERNEL
#define KERNEL_NAME GET_STRING(KERNEL)
#endif

#define SOCKET "SOCKET"
#define ACK_DATA "ACK_DATA"
#define ACK_SIZE "ACK_SIZE"
// #define PORT 8080

#define CHUNK_SIZE 8192
#define MSG_LENGTH 128

using namespace std;
using namespace lodepng;

/*
** Data structure to handle a array of doubles and its size to have a dynamic behaviour
** TODO: This is messy. At least make it an object with destructor.
*/
typedef struct array {
  double * data;
  int data_size;
} dynamic_array;

/* 
** This function is needed to translate the message coming from 
** the socket into a number to be given in input to the
** switch construct to decode the command
*/
int get_command(char * command);

/* 
** Utility function to print errors
*/
void perror(const char * error);

/*
** Utility function to handle the command decode coming from the socket
** connection with the python webserver
*/
#ifdef OPENCL
cl_data_types init_platform(cl_data_types cl, char * response);
cl_data_types init_kernel(cl_data_types cl, char * response, const char *xclbin, const char *kernel_name, int memory_size);
cl_data_types handle_command(int socket, int command, cl_data_types opencl, const char *xclbin, const char *kernel_name, int memory_size);
#else
char *image_buffer;
#endif

/*
** Utility function to handle the data coming from the socket and sent to the FPGA device
*/
dynamic_array handle_write_data(int socket);

/*
** Utility function to handle the data coming from the FPGA that has to be sent back to the client
*/
int handle_read_data(int socket, unsigned char data[], int data_size);

/*
** Utility function to handle the data coming from the FPGA that has to be sent back to the client
*/
int handle_read_data(int socket, int data[], int data_size);

#ifdef OPENCL
cl_data_types handle_get_image(int socket, int ** data_array_p, input_struct * input_p, cl_data_types cl);
#endif


int main(int argc, char const *argv[])
{
#ifdef OPENCL

  if (argc != 3) {
    printf("Usage: %s xclbin kernel_name\n", argv[0]);
    return EXIT_FAILURE;
  }

  // Name of the .xclbin binary file and the name of the Kernel passed as arguments
  const char *xclbin = argv[1];
  const char *kernel_name = argv[2];

  // OpenCL data type definition
  cl_data_types cl;
  cl.status = 1;
#endif

  // Socket-related variables
  int server_fd, sock;
  struct sockaddr_un address;
  int opt = 1;
  int addrlen = sizeof(address);


  /************************
  **                     **
  ** Socket related code **
  **                     **
  ************************/

  // Creating socket file descriptor
  if ((server_fd = socket(AF_UNIX, SOCK_STREAM, 0)) == 0) {
    perror("Socket failed");
    exit(1);
  }
    
  // Attaching UNIX SOCKET
  if (setsockopt(server_fd, SOL_SOCKET, SO_REUSEADDR | SO_REUSEPORT,
                          &opt, sizeof(opt))) {
    perror("setsockopt failed");
    exit(1);
  }

  address.sun_family = AF_UNIX;
  unlink(SOCKET);
  strncpy(address.sun_path, SOCKET, sizeof(address.sun_path)-1);
    
  // Binding to the UNIX SOCKET
  if (bind(server_fd, (struct sockaddr *)&address, 
                 sizeof(address))<0) {
    perror("Bind failed");
    exit(1);
  }

  if (listen(server_fd, 3) < 0) {
    perror("Listen failed");
    exit(1);
  }

  int data_array[262144];  // TODO: YIKES!!!

  for (unsigned int i = 0; i < sizeof(data_array) / sizeof(int); i++)
    data_array[i] = 0;

  char msg[MSG_LENGTH];
  
  int command;
  int err;
  int exit_status;



#ifdef OPENCL
  // Platform initialization. These can also be initiated by commands over the socket (though I'm not sure how important that is).                            
  cl = init_platform(cl, NULL);
  cl = init_kernel(cl, NULL, xclbin, kernel_name, COLS * ROWS * sizeof(int));
#endif

  while (true) {
    if ((sock = accept(server_fd, (struct sockaddr *)&address, (socklen_t*)&addrlen)) < 0) {
      printf("%d\n", sock);
      perror("SOCKET: Accept Failure");
      exit(1);
    }

    while(true) {
      if(!(err = recv(sock, msg, sizeof(msg), 0))){
        printf("Error %d: Client disconnected. Exiting.\n", err);
        exit(1);
      }
      
      //cout << "Main loop\n";

      // Translate message to an integer
      command = get_command(msg);
      
      // Dynamic array on which data coming from the client will be saved
      dynamic_array array_struct;
      char response[MSG_LENGTH];
      
      //cout << "Got message (" << command << ")\n";
      
      switch( command ) {
        case WRITE_DATA_N:
          cout << "INFO: WRITE DATA (isn't this obsolete?)" << endl;
          sprintf(response, "INFO: Write Data");
          send(sock, response, strlen(response), MSG_NOSIGNAL);

          // Filling the data structure with data coming from the client with the use of the handle_write_data utility function
          array_struct = handle_write_data(sock);

#ifdef OPENCL
          // Call the OpenCL utility function to send data to the FPGA.
          // We receive extra datums for C++ rendering only that are not sent to the FPGA.
          cout << "C++ received " << array_struct.data_size << " parameters. Sending 7 to FPGA." << endl;
          if (array_struct.data_size < 7) {
            cerr << "Error: C++ received " << array_struct.data_size << " parameters, but needed 7." << endl;
            exit(1);
          }
          cl = write_kernel_data(cl, array_struct.data, 7 * sizeof array_struct.data);  // TODO: Should be sizeof double.
          cerr << "Received WRITE_DATA_N\n";
#else
          cerr << "Received unexpected WRITE_DATA_N\n";
          exit(1);
#endif
          // Free the resources in the data structure
          free(array_struct.data);
          break;
        case READ_DATA_N:
          cout << "INFO: READ DATA (isn't this obsolete?)" << endl;
          sprintf(response, "INFO: Read Data");
          send(sock, response, strlen(response), MSG_NOSIGNAL);
          
#ifdef OPENCL
          // Read data coming from the Kernel and save them in data_array
          cl = read_kernel_data(cl, data_array, sizeof(data_array));
#endif

          // Call the utility function to send data over the socket
          handle_read_data(sock, data_array, sizeof(data_array));
          break;
        case GET_IMAGE_N:
          {  // Provides scope for local variables.
            sprintf(response, "INFO: Get Image");
            send(sock, response, strlen(response), MSG_NOSIGNAL);
          
            dynamic_array array_struct;

            array_struct = handle_write_data(sock);
#ifdef OPENCL
            bool fpga = true;
#else
            bool fpga = false;
#endif
            if (array_struct.data[6] < 0) {
              // Depth argument is negative. This is our indication that we must render in C++. TODO: Ick!
              array_struct.data[6] = - array_struct.data[6];
              fpga = false;
            }
            // Or, newer, only slightly less icky flag
            if ((array_struct.data_size >= 16) && (((int)(array_struct.data[16])) & (1 << 1))) {
              fpga = false;
            }
#ifdef OPENCL
            // Don't go bigger than allocated sizes.
            if (((int)(array_struct.data[4])) > COLS) {
              array_struct.data[4] = (double)COLS;  // (COLS should be a multiple of 16.)
            }
            if (((int)(array_struct.data[5])) > ROWS) {
              array_struct.data[5] = (double)ROWS;
            }
#endif
                
            MandelbrotImage mb_img(array_struct.data, fpga);
            // Free memory for array_struct.
            free(array_struct.data);

            int * depth_data = NULL;
#ifdef OPENCL
            if (fpga) {
              input_struct input;

              // Determine autodepth by generating a coarse-grained image for the auto-depth bounding box.
              if (mb_img.auto_dive || mb_img.auto_darken) {
                mb_img.setAutoDepthBounds();
                input.width = 16;
                input.height = 8;
                input.coordinates[0] = mb_img.wToX(mb_img.calc_center_w - mb_img.auto_depth_w);
                input.coordinates[1] = mb_img.hToY(mb_img.calc_center_h - mb_img.auto_depth_h);
                input.coordinates[2] = mb_img.getPixX() * mb_img.auto_depth_w * 2 / (input.width - 1);
                input.coordinates[3] = mb_img.getPixY() * mb_img.auto_depth_h * 2 / (input.height - 1);
                input.max_depth = (long)(mb_img.getMaxDepth());
                
                // Generate this coarse image on FPGA (allocated by handle_get_image).
                cl = handle_get_image(sock, &depth_data, &input, cl);
                
                // Scan all depths to determine auto-depth.
                for (int w = 0; w < input.width; w++) {
                  for (int h = 0; h < input.height; h++) {
                    mb_img.updateMaxDepth(depth_data[h * input.width + w], (unsigned char)0);
                  }
                }
                free(depth_data);
              } else {
                
              }
              
              // Populate depth_data from FPGA.
              // X,Y are center position, and must be passed to FPGA as top left.
              input.coordinates[0] = mb_img.wToX(0);
              input.coordinates[1] = mb_img.hToY(0);
              input.coordinates[2] = mb_img.getPixX();
              input.coordinates[3] = mb_img.getPixY();
              input.width  = (long)(mb_img.getDepthArrayWidth());
              input.height = (long)(mb_img.getDepthArrayHeight());
              input.max_depth = (long)(mb_img.getMaxDepth());  // may have been changed based on auto-depth.

              cl = handle_get_image(sock, &depth_data, &input, cl);
            }
#endif
  
            mb_img.generatePixels(depth_data);  // Note that depth_array is from FPGA for OpenCL (and given here to mb_img to free), or NULL to generate in C++.
  
            size_t png_size;
            unsigned char *png;
            png = mb_img.generatePNG(&png_size);

            // Call the utility function to send data over the socket
            handle_read_data(sock, png, (int)png_size);
          }
          break;
        default:
#ifdef OPENCL
          cl = handle_command(sock, command, cl, xclbin, kernel_name, COLS * ROWS * sizeof(int));
#else
          char response[MSG_LENGTH];
          sprintf(response, "INFO: Command [%i] is a no-op with no FPGA", command);
          send(sock, response, strlen(response), MSG_NOSIGNAL);
#endif
      }
    }
  }

  return exit_status;
}


void perror(const char * error) {
  printf("%s\n", error);
  exit(EXIT_FAILURE);
}

#ifdef OPENCL

// A wrapper around initialize_platform that reports errors.
// Use NULL response to report errors.
cl_data_types init_platform(cl_data_types cl, char * response) {
  char rsp[MSG_LENGTH];
  if (response == NULL) {
    response = rsp;
  }
  if(!cl.initialized) {
    cl = initialize_platform();
    if (cl.status)
      sprintf(response, "Error: could not initialize platform");
    else
      sprintf(response, "INFO: platform initialized");
  } else {
    sprintf(response, "Error: Platform already initialized");
  }
  if (response == rsp) {
    printf("%s\n", response);
  }
  return cl;
}

// A wrapper around init_kernel that reports errors.
// Use NULL response to report errors.                                                                                                                        
cl_data_types init_kernel(cl_data_types cl, char * response, const char *xclbin, const char *kernel_name, int memory_size) {
  char rsp[MSG_LENGTH];
  if (response == NULL) {
    response = rsp;
  }
  if(cl.status){
    sprintf(response, "Error: first initialize platform");
  } else {
    if(!cl.initialized) {
      cl = initialize_kernel(cl, xclbin, kernel_name, memory_size);
      if (cl.status)
        sprintf(response, "Error: Could not initialize the kernel");
      else {
        sprintf(response, "INFO: kernel initialized");
        cl.initialized = true;
      }
    }
  }
  if (response == rsp) {
    printf("%s\n", response);
  }
  return cl;
}

cl_data_types handle_command(int socket, int command, cl_data_types cl, const char *xclbin, const char *kernel_name, int memory_size) {
  char response[MSG_LENGTH];

  switch (command) {
    // Initialization of the platform
    case INIT_PLATFORM_N:
      cl = init_platform(cl, NULL);
      break;

    // Initialization of the kernel (loads the fpga program)
    case INIT_KERNEL_N:
      cl = init_kernel(cl, NULL, xclbin, kernel_name, memory_size);
      break;

    // Releasing all OpenCL links to the fpga
    case CLEAN_KERNEL_N:
      cl = clean_kernel(cl);
      sprintf(response, "INFO: Kernel cleaned");
      break;

    // Start Kernel computation
    case START_KERNEL_N:
      cl = start_kernel(cl);
      sprintf(response, "INFO: Started computation");
      break;
    default:
      sprintf(response, "Command not recognized");
      break;
  }
  
  send(socket, response, strlen(response), MSG_NOSIGNAL);

  return cl;
}
#endif

/*
** Paramters
** socket: reference to the socket channel with the webserver
*/
dynamic_array handle_write_data(int socket) {
  // Variable definitions
  int data_size, data_read = 0;
  int to_read = CHUNK_SIZE;
  dynamic_array array_struct;
  double * data_chunks;

  // Receive size of the data that will be transmitted by the webserver
  if(!recv(socket, &data_size, sizeof(data_size), 0))
    printf("Data size receive error: Client disconnected\n");

  // Sending ACK to webserver to synchronize
  send(socket, ACK_SIZE, strlen(ACK_SIZE), MSG_NOSIGNAL);

  // Prepare to receive the data allocating space in the memory
  array_struct.data_size = data_size;
  array_struct.data = (double *) malloc(data_size * sizeof *array_struct.data);
  data_chunks = (double *) malloc(CHUNK_SIZE * sizeof *data_chunks);

  // Loop to receive data in chuncks in order to prevent data loss through the socket
  int j = 0;
  while(data_read < data_size) {
    data_read += CHUNK_SIZE;
    to_read = data_read > data_size ? 
                data_size - (data_read - to_read) : 
                CHUNK_SIZE;

    if(!recv(socket, data_chunks, to_read * sizeof *data_chunks, 0))
      printf("Data receive error: Client disconnected\n");

    // Fill the data array incrementally with the chuncks of data
    for (int i = 0; i < to_read; i++)
      array_struct.data[i+(j*CHUNK_SIZE)] = data_chunks[i];

    j++;
  }
  
  free(data_chunks);

  // Sending ACK to state that data was correctly received
  send(socket, ACK_DATA, strlen(ACK_DATA), MSG_NOSIGNAL);
  return array_struct;
}

/*
** Parameters
** socket: reference to the socket channel with the webserver
** data: array containing data to be sent. For this function the array is made of bytes
** data_size: size of the array that has to be sent
*/
int handle_read_data(int socket, unsigned char data[], int data_size) {
  int result_send;
  char ack[MSG_LENGTH];
  if(!recv(socket, ack, sizeof(ack), 0))
    printf("Ack receive error: Client disconnected\n");

  send(socket, &data_size, sizeof(data_size), MSG_NOSIGNAL);

  if(!recv(socket, ack, sizeof(ack), 0))
    printf("Ack receive error: Client disconnected\n");
  
  result_send = send(socket, data, data_size, MSG_NOSIGNAL);
  if(result_send < 0)
    perror("Send data failed");

  return 0;
}

/*
** Parameters
** socket: reference to the socket channel with the webserver
** data: array containing data to be sent. For this function the array is made of integers
** data_size: size of the array that has to be sent
*/
int handle_read_data(int socket, int data[], int data_size) {
  int result_send;
  char ack[MSG_LENGTH];
  if(!recv(socket, ack, sizeof(ack), 0))
    printf("Ack receive error: Client disconnected\n");

  send(socket, &data_size, sizeof(data_size), MSG_NOSIGNAL);

  if(!recv(socket, ack, sizeof(ack), 0))
    printf("Ack receive error: Client disconnected\n");

  result_send = send(socket, data, data_size, MSG_NOSIGNAL);
  if(result_send < 0)
    perror("Send data failed");

  return 0;
}

#ifdef OPENCL
/*
** Parameters
** socket: reference to the socket channel with the webserver
** cl: OpenCL datatypes
** color_scheme: color transition scheme in order to create the PNG image given the computation results
*/
cl_data_types handle_get_image(int socket, int ** data_array_p, input_struct * input_p, cl_data_types cl) {
  cl = write_kernel_data(cl, input_p, sizeof(input_struct));

  // check timing
  struct timespec start, end;
  uint64_t delta_us;
  
  // getting start time
  clock_gettime(CLOCK_MONOTONIC_RAW, &start);

  cl = start_kernel(cl);

  *data_array_p = (int *) malloc(input_p->width * input_p->height * sizeof(int));

  cl = read_kernel_data(cl, *data_array_p, input_p->width * input_p->height * sizeof(int));

  // getting end time
  clock_gettime(CLOCK_MONOTONIC_RAW, &end);
  delta_us = (end.tv_sec - start.tv_sec) * 1000000 + (end.tv_nsec - start.tv_nsec) / 1000;

  printf("Kernel execution time GET_IMAGE: %ld [us]\n", delta_us);
  return cl;
}
#endif


/*
** This function generates a number corresponding to the command that receives in input as a string
*/
int get_command(char * command) {
  if(!strncmp(command, INIT_PLATFORM, strlen(INIT_PLATFORM)))
    return INIT_PLATFORM_N;
  else if(!strncmp(command, INIT_KERNEL, strlen(INIT_KERNEL)))
    return INIT_KERNEL_N;
  else if(!strncmp(command, START_KERNEL, strlen(START_KERNEL)))
    return START_KERNEL_N;
  else if(!strncmp(command, WRITE_DATA, strlen(WRITE_DATA)))
    return WRITE_DATA_N;
  else if(!strncmp(command, READ_DATA, strlen(READ_DATA)))
    return READ_DATA_N;
  else if(!strncmp(command, CLEAN_KERNEL, strlen(CLEAN_KERNEL)))
    return CLEAN_KERNEL_N;
  else if(!strncmp(command, GET_IMAGE, strlen(GET_IMAGE)))
    return GET_IMAGE_N;
  else
    return -1;
}
