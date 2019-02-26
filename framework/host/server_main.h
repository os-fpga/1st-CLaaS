#ifndef SERVER_MAIN
#define SERVER_MAIN



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

#include <nlohmann/json.hpp>
using json = nlohmann::json;

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



class HostApp {

public:
  int server_main(int argc, char const *argv[]);
  
  /*
  ** Data structure to handle a array of doubles and its size to have a dynamic behaviour
  ** TODO: This is messy. At least make it an object with destructor.
  */
  typedef struct {
    double * data;
    int data_size;
  } dynamic_array;

#ifdef OPENCL
  cl_data_types cl;
#endif
  
protected:

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

  json read_json(int socket);
  
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
  
#ifdef OPENCL
  virtual cl_data_types get_image(cl_data_types cl, int sock) {printf("No defined behavior for get_image()\n"); return cl;}
#else
  virtual void get_image(int sock) {printf("No defined behavior for get_image()\n");}
#endif
  
};



#endif