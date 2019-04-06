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
  int server_main(int argc, char const *argv[], const char *kernel_name);

  /*
  ** Data structure to handle a array of doubles and its size to have a dynamic behaviour
  ** TODO: This is messy. At least make it an object with destructor.
  */
  typedef struct {
    double * data;
    int data_size;
  } dynamic_array;

#ifdef OPENCL
  Kernel kernel;
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
  void init_platform(char * response);
  void init_kernel(char * response, const char *xclbin, const char *kernel_name, int memory_size);
  void handle_command(int socket, int command, const char *xclbin, const char *kernel_name, int memory_size);
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
  void handle_get_image(int socket, int ** data_array_p, input_struct * input_p);
  #endif

  virtual void get_image(int sock) {printf("No defined behavior for get_image()\n");}

};



#endif
