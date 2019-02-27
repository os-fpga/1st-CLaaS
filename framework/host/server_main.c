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
#include "mandelbrot.h"

using namespace std;
using namespace lodepng;



int HostApp::server_main(int argc, char const *argv[])
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

  
  #ifdef OPENCL
    // Platform initialization. These can also be initiated by commands over the socket (though I'm not sure how important that is).                            
    cl = init_platform(cl, NULL);
    cl = init_kernel(cl, NULL, xclbin, kernel_name, COLS * ROWS * sizeof(int));
  #endif


  int data_array[262144];  // TODO: YIKES!!!

  for (unsigned int i = 0; i < sizeof(data_array) / sizeof(int); i++)
    data_array[i] = 0;

  char msg[MSG_LENGTH];
  
  int command;
  int err;
  int exit_status;


  while (true) {
    if ((sock = accept(server_fd, (struct sockaddr *)&address, (socklen_t*)&addrlen)) < 0) {
      printf("%d\n", sock);
      perror("SOCKET: Accept Failure");
      exit(1);
    }

    int loop_cnt = 0;
    while(true) {
      //cout << "C++ Main loop" << endl;
      loop_cnt++;
      if (loop_cnt > 10000) {
        cout << "." << flush;
        loop_cnt = 0;
      }
      
      if(!(err = recv(sock, msg, sizeof(msg), 0))){
        printf("Error %d: Client disconnected. Exiting.\n", err);
        exit(1);
      }
      
      //cout << "Main loop\n";
      //cout << "Msg: " << msg << endl;

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
          //cout << "C++ received " << array_struct.data_size << " parameters. Sending 7 to FPGA." << endl;
          if (array_struct.data_size < 7) {
            cerr << "Error: C++ received " << array_struct.data_size << " parameters, but needed 7." << endl;
            exit(1);
          }
          cl = write_kernel_data(cl, array_struct.data, 7 * sizeof array_struct.data);  // TODO: Should be sizeof double.
          //cerr << "Received WRITE_DATA_N\n";
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
            
 #ifdef OPENCL
           cl = get_image(cl, sock);
#else
           get_image(sock);
#endif
          }
          break;
        default:
#ifdef OPENCL
          cout << "Calling handle_command(.., " << command << ", ..)" << endl;
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


void HostApp::perror(const char * error) {
  printf("%s\n", error);
  exit(EXIT_FAILURE);
}

#ifdef OPENCL

// A wrapper around initialize_platform that reports errors.
// Use NULL response to report errors.
// TODO: cl_data_types is defined in kernel.h and its members should become members of HostApp, and it should not be passed all over the place.
cl_data_types HostApp::init_platform(cl_data_types cl, char * response) {
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
cl_data_types HostApp::init_kernel(cl_data_types cl, char * response, const char *xclbin, const char *kernel_name, int memory_size) {
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

cl_data_types HostApp::handle_command(int socket, int command, cl_data_types cl, const char *xclbin, const char *kernel_name, int memory_size) {
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
** Read JSON from client.
** Return: A new JSON object.
*/
json HostApp::read_json(int socket) {
  uint16_t json_str_len;
  
  // Receive size of the JSON string.
  if(!recv(socket, &json_str_len, sizeof(uint16_t), 0))
    printf("Data size receive error: Client disconnected\n");
  json_str_len = ntohs(json_str_len);  // Correct byte order.
  //cout << "Host receiving JSON string of " << json_str_len << " bytes." << endl;
  
  // Receive JSON string.
  char *str = (char *)malloc(json_str_len + 1);
  if (!recv(socket, str, json_str_len, 0))
    printf("Data size receive error (2): Client disconnected\n");
  // Terminate JSON string
  str[json_str_len] = '\0';

  //cout << "C++ received JSON: " << str << endl;
  
  // Sending ACK to state that data was correctly received
  send(socket, ACK_DATA, strlen(ACK_DATA), MSG_NOSIGNAL);
  
  // Parse JSON.
  return json::parse(str);
}

/*
** Paramters
** socket: reference to the socket channel with the webserver
*/
HostApp::dynamic_array HostApp::handle_write_data(int socket) {
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
int HostApp::handle_read_data(int socket, unsigned char data[], int data_size) {
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
int HostApp::handle_read_data(int socket, int data[], int data_size) {
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
*/
cl_data_types HostApp::handle_get_image(int socket, int ** data_array_p, input_struct * input_p, cl_data_types cl) {
  cout << "handle_get_image(..) input_struct: [" <<
          input_p->coordinates[0] << ", " <<
          input_p->coordinates[1] << ", " <<
          input_p->coordinates[2] << ", " <<
          input_p->coordinates[3] << ", " <<
          input_p->width << ", " <<
          input_p->height << ", " <<
          input_p->max_depth << "]" <<
          endl;
  cl = write_kernel_data(cl, input_p, sizeof(input_struct));
  cout << "Wrote kernel." << endl;

  // check timing
  struct timespec start, end;
  uint64_t delta_us;
  
  // getting start time
  clock_gettime(CLOCK_MONOTONIC_RAW, &start);

  cl = start_kernel(cl);
  cout << "Started kernel." << endl;

  *data_array_p = (int *) malloc(input_p->width * input_p->height * sizeof(int));

  cl = read_kernel_data(cl, *data_array_p, input_p->width * input_p->height * sizeof(int));
  cout << "Read kernel data." << endl;

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
int HostApp::get_command(char * command) {
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
