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


#include "server_main.h"
// #include "mandelbrot.h"

using namespace std;
using namespace lodepng;



int HostApp::server_main(int argc, char const *argv[], const char *kernel_name)
{
//TODO else ifndef OPENCL
#ifdef OPENCL
  string opencl_arg_str = " xclbin";
  int opencl_arg_cnt = 1;
#else
  string opencl_arg_str = "";
  int opencl_arg_cnt = 0;
#endif
  // Poor-mans arg parsing.
  int argn = 1;
  if (strcmp(argv[1], "-s") == 0) {
    socket_filename = argv[2];
    argn += 2;
  }
  if (argc != argn + opencl_arg_cnt) {
    printf("Usage: %s [-s socket] %s\n", argv[0], opencl_arg_str.c_str());
    return EXIT_FAILURE;
  }

#ifdef OPENCL
  // Name of the .xclbin binary file and the name of the Kernel passed as arguments
  const char *xclbin = argv[argn + opencl_arg_cnt - 1];
#endif

  // Socket-related variables
  int server_fd;
  struct sockaddr_un address;
  int opt = 1;
  int addrlen = sizeof(address);


  /************************
  **                     **
  ** Socket related code **
  **                     **
  ************************/

  // Creating socket file descriptor
  if ((server_fd = ::socket(AF_UNIX, SOCK_STREAM, 0)) == 0) {
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
  unlink(socket_filename.c_str());
  strncpy(address.sun_path, socket_filename.c_str(), sizeof(address.sun_path)-1);

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


  #ifdef OPENCL
    // Platform initialization. These can also be initiated by commands over the socket (though I'm not sure how important that is).
    init_platform(NULL);
    init_kernel(NULL, xclbin, kernel_name, COLS * ROWS * sizeof(int));  // TODO: FIX size.
  #endif

  #ifdef KERNEL_AVAIL
    kernel.reset_kernel();
  #endif


  while (true) {
    if ((socket = accept(server_fd, (struct sockaddr *)&address, (socklen_t*)&addrlen)) < 0) {
      printf("%d\n", socket);
      perror("SOCKET: Accept Failure");
      exit(1);
    }

    int loop_cnt = 0;
    while(true) {
      //cout << "C++ Main loop" << endl;
      loop_cnt++;
      if (loop_cnt > 10000) {
        if (verbosity > 5) {cout << "." << flush;}
        loop_cnt = 0;
      }

      processTraffic();
    }
  }

  return 0;
}

void HostApp::processTraffic() {
  int command;

  string msg = socket_recv_string("command");

  //cout << "Main loop" << "Msg: " << msg << endl;

  // Translate message to an integer
  command = get_command(msg.c_str());

  //cout << "Got message (" << command << ")\n";

  // check timing
  struct timespec start, end;

  // getting start time
  if (verbosity > 2) {clock_gettime(CLOCK_MONOTONIC_RAW, &start);}

  switch( command ) {
    case GET_IMAGE_N:
      {  // Provides scope for local variables.

        get_image();
      }
      break;
    case DATA_MSG_N:
      {  // Provides scope for local variables.
        // Get JSON data.
        json data_json = socket_recv_json("DATA");
        try {
          const int DATA_WIDTH_UINT32 = DATA_WIDTH_BYTES / 4;
          // Allocate in/out data buffers.
          size_t size = data_json["size"];
          size_t resp_size = data_json["resp_size"];
          uint32_t * int_data_p = (uint32_t *)malloc(size * DATA_WIDTH_BYTES);
          uint32_t * int_resp_data_p = (uint32_t *)malloc(resp_size * DATA_WIDTH_BYTES); {
            // With these data arrays...

            // Initial data for arrays (debug only).
            for (uint i = 0; i < size * DATA_WIDTH_UINT32; i++) {
              int_data_p[i] = 0xDEADBEEF;
            }
            for (uint i = 0; i < resp_size * DATA_WIDTH_UINT32; i++) {
              int_resp_data_p[i] = 0xBEEFCAFE;
            }

            cout_line() << "Extracting data from JSON structure." << endl;
            // Populate from JSON.
            for (unsigned int d = 0; d < size; d++) {
              for (int i = 0; i < DATA_WIDTH_UINT32; i++) {
                uint32_t val = data_json["data"][d][i];
                int_data_p[d * DATA_WIDTH_UINT32 + i] = val;
                if (verbosity > 1) {cout_line() << "Set data[" << d << "][" << i << "] to " << hex << val << dec << endl;}
              }
            }
            cout_line() << "Done extracting data." << endl;

            // Send data to FPGA, or do fake FPGA processing.
            #ifdef KERNEL_AVAIL
            // Process in FPGA.
            kernel.writeKernelData(int_data_p, size * DATA_WIDTH_BYTES, resp_size * DATA_WIDTH_BYTES);
            if (verbosity > 2) {cout << "Wrote kernel." << endl;}


            kernel.start_kernel();
            if (verbosity > 2) {cout << "Started kernel." << endl;}

            if (verbosity > 2) {cout << "Reading kernel data (" << resp_size * DATA_WIDTH_BYTES << " bytes)." << endl;}
            kernel.read_kernel_data((int *)int_resp_data_p, resp_size * DATA_WIDTH_BYTES);
            if (verbosity > 3) {cout << "Read kernel data (" << resp_size * DATA_WIDTH_BYTES << " bytes)." << endl;}
            #else
            // Fake the kernel.
            fakeKernel(size * DATA_WIDTH_BYTES, int_data_p, resp_size * DATA_WIDTH_BYTES, int_resp_data_p);
            #endif

            // Convert data to JSON.
            string s("");
            //s += "{\"size\":";
            //s += to_string(resp_size);
            //s += ",\"data\":";
            cout_line() << "Kernel produced:" << endl;
            s += "[";
            for (unsigned int d = 0; d < resp_size; d++) {
              if (d > 0) {s += ",";}
              s += "[";
              for (int i = 0; i < DATA_WIDTH_UINT32; i++) {
                if (i > 0) {s += ",";}
                uint32_t val = int_resp_data_p[d * DATA_WIDTH_UINT32 + i];
                s += to_string(val);
                if (verbosity > 1) {cout_line() << "Read data[" << d << "][" << i << "] == " << hex << val << dec << endl;}
              }
              s += "]";
            }
            s += "]";
            //s += "}";

            // Respond.
            if (verbosity > 5) {cout_line() << "Responding with: " << s << endl;}
            socket_send("DATA response", s);

          } free(int_resp_data_p); free(int_data_p);
        } catch (nlohmann::detail::exception) {
          cerr_line() << "Unable to process DATA message." << endl;
          exit(1);
        }
        break;
      }
      case START_TRACING_N:
      {
        //json data_json = socket_recv_json("START TRACING");
        #ifdef KERNEL_AVAIL
        if (verbosity > 1) {cout_line() << "STARTING TRACE." << endl;}
        kernel.enable_tracing();
        #endif
        //socket_send("START_TRACING Response", string("\"START_TRACING ACK\""));
        break;
      }
      case STOP_TRACING_N:
      {
        //json data_json = socket_recv_json("START TRACING");
        #ifdef KERNEL_AVAIL
        if (verbosity > 1) {cout_line() << "STOPPING TRACE." << endl;}
        kernel.disable_tracing();
        kernel.save_trace();
        #endif
        //socket_send("STOP_TRACING Response", string("\"STOP_TRACING ACK\""));
        break;
      }
      break;
    default:
      cout_line() << "Unrecognized command: " << command << "." << endl;
      exit(1);
      #ifdef KERNEL_AVAIL
      #ifdef OPENCL
      //cout << "Calling handle_command(.., " << command << ", ..)" << endl;
      //handle_command(command, kernel.xclbin, kernel_name, COLS * ROWS * sizeof(int));
      #else
      //Simulation commands
      #endif
      #endif
  }

  if (verbosity > 2) {
    // getting end time
    clock_gettime(CLOCK_MONOTONIC_RAW, &end);

    uint64_t delta_us = (end.tv_sec - start.tv_sec) * 1000000 + (end.tv_nsec - start.tv_nsec) / 1000;
    printf("Kernel execution time %s: %ld [us]\n", msg.c_str(), delta_us);
  }
}

// Default fake server is an echo server.
void HostApp::fakeKernel(size_t bytes_in, void * in_buffer, size_t bytes_out, void * out_buffer) {
  if (bytes_out != bytes_in) {
    cerr_line() << "Default Echo server expects bytes_out (" << bytes_out << ") == bytes_in (" << bytes_in << "). Exiting." << endl;
    exit(1);
  }
  memcpy(out_buffer, in_buffer, bytes_in);
}

void HostApp::perror(const char * error) {
  cerr_line() << error << endl;
  cerr << "\texiting with status" << EXIT_FAILURE << "." << endl;
  exit(EXIT_FAILURE);
}

void HostApp::socket_send(const char * tag, const void *buf, uint32_t len, bool send_size) {
  if (verbosity > 5 && tag != NULL) {cout_line() << "Sending " << len << "-byte \"" << tag << (send_size ? " with size" : "") << "\" to socket" << "." << endl;}
  if (send_size) {
    uint32_t len_data = htonl(len);
    socket_send(NULL, &len_data, 4, false);
  }
  if (send(socket, buf, len, MSG_NOSIGNAL) != (int)len) {
    cerr_line() << "Socket send error for \"" << tag << "\"." << endl;
    exit(1);
  }
  if (verbosity > 7 && tag != NULL) {cout_line() << "Sent " << len << "-byte \"" << tag << "\" to socket." << endl;}
}

void HostApp::socket_send(const char * tag, string s) {
  string size_tag(tag);
  size_tag += " size";
  socket_send(size_tag.c_str(), s.c_str(), s.length(), true);
}

void HostApp::socket_send(const char * tag, json j) {
  socket_send(tag, j.dump());
}

void HostApp::socket_recv(const char * tag, void *buf, size_t len) {
  if (verbosity > 5) {cout_line() << "Receiving " << len << "-byte \"" << tag << "\" from socket." << endl;}
  if (recv(socket, buf, len, 0) != (int)len) {
    cerr << "C++ Host socket receive error for \"" << tag << "\"." << endl;
  }
  if (verbosity > 7) {cout_line() << "Received " << len << "-byte \"" << tag << "\" from socket." << endl;}
}

uint32_t HostApp::socket_recv_size(const char * tag) {
  string size_tag(tag);
  size_tag += " size";
  uint32_t ret;
  socket_recv(size_tag.c_str(), &ret, (uint32_t)4);
  return ntohl(ret);
}

char * HostApp::socket_recv_c_string(const char * tag) {
  uint32_t len = socket_recv_size(tag);
  char * s = (char *)malloc(len + 1);
  socket_recv(tag, s, len);
  s[len] = '\0';
  if (verbosity > 4) {cout_line() << "Received string: " << s << endl;}
  return s;
}

string HostApp::socket_recv_string(const char * tag) {
  char * s = socket_recv_c_string(tag);
  string str(s);  // (copy can be expensive)
  free(s);
  return str;
}

json HostApp::socket_recv_json(const char * tag) {
  char * c_str = socket_recv_c_string(tag);
  json ret = json::parse(c_str);
  free(c_str);
  return ret;
}

#ifdef OPENCL
// A wrapper around initialize_platform that reports errors.
// Use NULL response to report errors.
void HostApp::init_platform(char * response) {
  char rsp[MSG_LENGTH];
  if (response == NULL) {
    response = rsp;
  }
  if(!kernel.initialized) {
    kernel.initialize_platform();

    if (kernel.status)
      sprintf(response, "Error: could not initialize platform");
    else
      sprintf(response, "INFO: platform initialized");
  } else {
    sprintf(response, "Error: Platform already initialized");
  }
  if (response == rsp) {
    printf("%s\n", response);
  }
}

// A wrapper around init_kernel that reports errors.
// Use NULL response to report errors.
void HostApp::init_kernel(char * response, const char *xclbin, const char *kernel_name, int memory_size) {
  char rsp[MSG_LENGTH];
  if (response == NULL) {
    response = rsp;
  }
  if (kernel.status){
    sprintf(response, "Error: first initialize platform");
  } else {
    if(!kernel.initialized) {
      kernel.initialize_kernel(xclbin, kernel_name, memory_size);
      if (kernel.status)
        sprintf(response, "Error: Could not initialize the kernel");
      else {
        sprintf(response, "INFO: kernel initialized");
        kernel.initialized = true;
      }
    }
  }
  if (response == rsp) {
    printf("%s\n", response);
  }
}

#endif



/*
** Paramters
** socket: reference to the socket channel with the web server
** TODO: Not used
** TODO: Only works when size aligns w/ sizeof double.
*/
HostApp::dynamic_array HostApp::handle_write_data() {
  // Variable definitions
  int data_size, data_read = 0;
  int to_read = CHUNK_SIZE;
  dynamic_array array_struct;
  double * data_chunks;

  // Receive size of the data that will be transmitted by the web server
  socket_recv("Size", &data_size, sizeof(data_size));

  //-// Sending ACK to web server to synchronize
  //-send(socket, ACK_SIZE, strlen(ACK_SIZE), MSG_NOSIGNAL);

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

    socket_recv("chunk", data_chunks, to_read * sizeof *data_chunks);

    // Fill the data array incrementally with the chuncks of data
    for (int i = 0; i < to_read; i++)
      array_struct.data[i+(j*CHUNK_SIZE)] = data_chunks[i];

    j++;
  }

  free(data_chunks);

  //-// Sending ACK to state that data was correctly received
  //-send(socket, ACK_DATA, strlen(ACK_DATA), MSG_NOSIGNAL);
  return array_struct;
}

/*
** Parameters
** socket: reference to the socket channel with the web server
** data: array containing data to be sent. For this function the array is made of bytes
** data_size: size of the array that has to be sent
*/
int HostApp::handle_read_data(const void * data, int data_size) {
  //-char ack[MSG_LENGTH];
  //-if(!recv(ack, sizeof(ack), 0))
  //-  printf("Ack receive error: Client disconnected\n");

  //cout << "Sending data_size: " << data_size << endl;
  uint32_t size_data = htonl(data_size);
  socket_send("Size", &size_data, 4, false);

  //-if(!recv(ack, sizeof(ack), 0))
  //-  printf("Ack receive error: Client disconnected\n");

  socket_send("Data", data, data_size, false);

  return 0;
}

#ifdef KERNEL_AVAIL
/*
** Parameters
** socket: reference to the socket channel with the web server
** cl: OpenCL datatypes
*/
void HostApp::handle_get_image(int ** data_array_p, input_struct * input_p) {
  if (verbosity > 3) {
    cout << "handle_get_image(..) input_struct: [" <<
          input_p->coordinates[0] << ", " <<
          input_p->coordinates[1] << ", " <<
          input_p->coordinates[2] << ", " <<
          input_p->coordinates[3] << ", " <<
          input_p->width << ", " <<
          input_p->height << ", " <<
          input_p->max_depth << "]" <<
          endl;
  }
  kernel.write_kernel_data(input_p, DATA_WIDTH_BYTES);  // sizeof(input_struct));  TODO: I used full data width, but the structure is smaller.
  if (verbosity > 2) {cout << "Wrote kernel." << endl;}

  // check timing
  struct timespec start, end;
  uint64_t delta_us;

  // getting start time
  if (verbosity > 2) {clock_gettime(CLOCK_MONOTONIC_RAW, &start);}

  kernel.start_kernel();
  if (verbosity > 2) {cout << "Started kernel." << endl;}

  int data_bytes = input_p->width * input_p->height * (int)sizeof(int);
  *data_array_p = (int *) malloc(data_bytes);

  if (verbosity > 2) {cout << "Reading kernel data (" << data_bytes << " bytes)." << endl;}
  kernel.read_kernel_data(*data_array_p, data_bytes);
  if (verbosity > 3) {cout << "Read kernel data (" << data_bytes << " bytes)." << endl;}

  if (verbosity > 2) {
    // getting end time
    clock_gettime(CLOCK_MONOTONIC_RAW, &end);
    delta_us = (end.tv_sec - start.tv_sec) * 1000000 + (end.tv_nsec - start.tv_nsec) / 1000;

    cout_line() << "Kernel execution time GET_IMAGE: " << delta_us << " us." << endl;
  }
}
#endif


/*
** This function generates a number corresponding to the command that receives in input as a string
*/
int HostApp::get_command(const char * command) {
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
  else if(!strncmp(command, DATA_MSG, strlen(DATA_MSG)))
    return DATA_MSG_N;
  else if(!strncmp(command, START_TRACING, strlen(START_TRACING)))
    return START_TRACING_N;
  else if(!strncmp(command, STOP_TRACING, strlen(STOP_TRACING)))
    return STOP_TRACING_N;
  else
    return -1;
}
