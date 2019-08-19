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
#ifdef KERNEL_AVAIL
#include "kernel.h"
#ifndef OPENCL
#include "sim_kernel.h"
#endif
#endif
#ifdef OPENCL
#include <CL/opencl.h>
#include "kernel.h"
#include "hw_kernel.h"
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

#undef KERNEL_NAME
#ifdef KERNEL
#define KERNEL_NAME GET_STRING(KERNEL)
#else
#define KERNEL_NAME NULL
#endif

#define SOCKET "SOCKET"
//-#define ACK_DATA "ACK_DATA"
//-#define ACK_SIZE "ACK_SIZE"
// #define PORT 8080

#define CHUNK_SIZE 8192
#define MSG_LENGTH 128


using namespace std;

class HostApp {

public:
  ostream & cout_line() {return(cout << "C++: ");}
  ostream & cerr_line() {return(cerr << "C++ Error: ");}

  int server_main(int argc, char const *argv[], const char *kernel_name);

  // Main method for processing traffic from/to the client.
  void processTraffic();

  /*
  ** Data structure to handle a array of doubles and its size to have a dynamic behaviour
  ** TODO: This is messy. At least make it an object with destructor.
  */
  typedef struct {
    double * data;
    int data_size;
  } dynamic_array;

#ifdef KERNEL_AVAIL
#ifdef OPENCL
  HW_Kernel kernel;
#else
  SIM_Kernel kernel;
#endif
#endif

  static const int DATA_WIDTH_BYTES = 64;
  static const int DATA_WIDTH_WORDS = DATA_WIDTH_BYTES / 4; //
  static const int DATA_WIDTH_BITS = DATA_WIDTH_BYTES * 8;  // 512 bits
  static const int verbosity = 0; // 0: no debug messages; 10: all debug messages.

protected:
  int socket;  // The ID of the socket connected to the web server.

  /*
  ** This function is needed to translate the message coming from
  ** the socket into a number to be given in input to the
  ** switch construct to decode the command
  */
  int get_command(const char * command);

  /*
  ** Utility function to print errors
  */
  void perror(const char * error);


  // TODO: Move socket methods into their own class.

  /*
  ** Send to socket.
  **  - tag: Identifies the data in debug messages.
  **  - buf: The data to send.
  **  - len: The length of the data in bytes.
  **  - send_size: true to prepend the data with a size, false if the receiver knows the size implicitly.
  **               Must be received w/ corresponding methods.
  */
  void socket_send(const char * tag, const void *buf, uint32_t len, bool send_size);
  /*
  ** Send string.
  **  - tag: Identifies the data in debug messages.
  **  - string: String to send.
  */
  void socket_send(const char * tag, string s);
  /*
  ** Send JSON.
  **  - tag: Identifies the data in debug messages.
  **  - json: JSON to send.
  */
  void socket_send(const char * tag, json j);
  /*
  ** Receive from socket.
  **  - tag: Identifies the data in debug messages.
  **  - buf: Pointer to the buffer to fill.
  **  - len: Length of data to receive.
  */
  void socket_recv(const char * tag, void *buf, size_t len);
  /*
  ** Receive size sent by socket_send(..) with send_size == true.
  **  - tag: Identifies the data whose size is being read in debug messages. (" size" is appended.)
  **/
  uint32_t socket_recv_size(const char * tag);
  /*
  ** Receive a malloc'ed C string (which must be free'ed).
  */
  char * socket_recv_c_string(const char * tag);
  /*
  ** Receive string.
  */
  string socket_recv_string(const char * tag);
  /*
  ** Receive JSON.
  */
  json socket_recv_json(const char * tag);

  /*
  ** Utility function to handle the command decode coming from the socket
  ** connection with the python webserver
  */
  #ifdef KERNEL_AVAIL
  void init_platform(char * response);
  void init_kernel(char * response, const char *xclbin, const char *kernel_name, int memory_size);
  #else
  char *image_buffer;
  #endif

  virtual void fakeKernel(size_t bytes_in, void * in_buffer, size_t bytes_out, void * out_buffer);

  /*
  ** Utility function to handle the data coming from the socket and sent to the FPGA device
  */
  dynamic_array handle_write_data();

  /*
  ** Utility function to handle the data coming from the FPGA that has to be sent back to the client
  */
  int handle_read_data(const void * data, int data_size);

  #ifdef KERNEL_AVAIL
  void handle_get_image(int ** data_array_p, input_struct * input_p);
  #endif

  virtual void get_image() {printf("No defined behavior for get_image()\n");}

};



#endif
