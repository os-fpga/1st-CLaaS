/*
BSD 3-Clause License

Copyright (c) 2018, Steven F. Hoover
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
*/


#include <cstdlib>
#include "vadd.h"


void send_data(const uint8_t *S, uint8_t S_len, const uint8_t *T, uint8_t T_len){
    // Process in FPGA.
    // assert(strlen(S) < GENOME_SIZE * MAX_GENOME_LEN);
    // assert(strlen(T)  < GENOME_SIZE * MAX_GENOME_LEN);
    for(uint i = 0 ; i < S_len/16; i+=1){
        // std::cout << "loop 1: " << i << std::endl;
        uint value = 0;
        for(int j = 0; j < 16; j++){
            // std::cout << "loop 1.1: " << j << std::endl;
            // value <<= 2;
            value |= (S[i*16+j]) << 2*j;
            // if(i*16 + j + 1 == strlen(S)){
            //     break;
            // }
        }
        // input_string[i] = value;
	      // std::cout << std::hex << &input_string[i]  << " " << std::hex  << value << std::endl;
    }
    for(uint i = 0 ; i < T_len/16; i+=1){
        // std::cout << "loop 2: " << i << std::endl;
        uint value = 0;
        for(int j = 0; j < 16; j++){
            // std::cout << "loop 2.1: " << j << std::endl;
            // value <<= 2;
            value |= T[i*16+j] << 2*j;
            // if(i*16 + j + 1 == strlen(T)){
            //     break;
            // }
        }
        // input_string[i+64] = value;
      //std::cout << std::hex << &input_string[i+64]  << " " << std::hex  << value << std::endl;
    }
    std::cout << sizeof(uint);
    // for(uint i = 0; i < 3; i++){
    //     std::cout << std::hex << input_string[i];
    // } 

//   kernel.writeKernelData(&input_string, IN_MEM_SIZE, OUT_MEM_SIZE);
  std::cout << "Wrote kernel." << std::endl;
}


void HostVAddApp::init_platform(const char* xclbin){
    auto devices = xcl::get_xil_devices();

    // read_binary_file() is a utility API which will load the binaryFile
    // and will return the pointer to file buffer.
    auto fileBuf = xcl::read_binary_file(xclbin);
    cl::Program::Binaries bins{{fileBuf.data(), fileBuf.size()}};
    bool valid_device = false;
    for (unsigned int i = 0; i < devices.size(); i++) {
        auto device = devices[i];
        // Creating Context and Command Queue for selected Device
        OCL_CHECK(err, context = cl::Context(device, nullptr, nullptr, nullptr, &err));
        OCL_CHECK(err, commands = cl::CommandQueue(context, device, CL_QUEUE_PROFILING_ENABLE, &err));

        std::cout << "Trying to program device[" << i << "]: " << device.getInfo<CL_DEVICE_NAME>() << std::endl;
        program = cl::Program(context, {device}, bins, nullptr, &err);
        if (err != CL_SUCCESS) {
            std::cout << "Failed to program device[" << i << "] with xclbin file!\n";
        } else {
            std::cout << "Device[" << i << "]: program successful!\n";
            valid_device = true;
            break; // we break because we found a valid device
        }
    }
    std::cout << "lol" << std::endl;
    if (!valid_device) {
        std::cout << "Failed to program any device found, exit!\n";
        exit(EXIT_FAILURE);
    }
}
void HostVAddApp::init_kernel(){
  OCL_CHECK(err, kernel = cl::Kernel(program, "krnl_vadd_rtl", &err));
  OCL_CHECK(err, buffer_r1 = cl::Buffer(context, CL_MEM_USE_HOST_PTR | CL_MEM_READ_ONLY, IN_MEM_SIZE,
                                        input_string.data(), &err));
  std::cout << "-2" << std::endl;
  OCL_CHECK(err, buffer_w = cl::Buffer(context, CL_MEM_USE_HOST_PTR | CL_MEM_WRITE_ONLY, OUT_MEM_SIZE,
                                      source_hw_results.data(), &err));

  // Set the Kernel Arguments
  OCL_CHECK(err, err = kernel.setArg(0, buffer_r1));
  std::cout << "-1" << std::endl;
  OCL_CHECK(err, err = kernel.setArg(1, buffer_w));
  std::cout << "0" << std::endl;
  OCL_CHECK(err, err = kernel.setArg(2, 64)); //2*GENOME_SIZE * MAX_GENOME_LEN

  return;
}
void HostVAddApp::write_data(){
    // Copy input data to device global memory
    OCL_CHECK(err, err = commands.enqueueMigrateMemObjects({buffer_r1}, 0 /* 0 means from host*/));
    std::cout << "1" << std::endl;
}

void HostVAddApp::start_kernel() {
  int err;
  OCL_CHECK(err, err = commands.enqueueTask(kernel));
  std::cout << "2" << std::endl;

  // Copy Result from Device Global Memory to Host Local Memory
  OCL_CHECK(err, err = commands.enqueueMigrateMemObjects({buffer_w}, CL_MIGRATE_MEM_OBJECT_HOST));
  std::cout << "3" << std::endl;
  OCL_CHECK(err, err = commands.finish());
  // int status = 0;
}


void HostVAddApp::clean_kernel() {
  // This has to be modified by the user if the number (or name) of arguments is different
  // clReleaseMemObject(buffer_r1);
  // clReleaseMemObject(buffer_w);

  // clReleaseProgram(program);
  // clReleaseKernel(kernel);
  // clReleaseCommandQueue(commands);
  // clReleaseContext(context);
}


// void HostVAddApp::fakeKernel(size_t bytes_in, void * in_buffer, size_t bytes_out, void * out_buffer) {

// }




int HostVAddApp::server_main(int argc, char const *argv[], const char *kernel_name)
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

  #ifdef OPENCL
    // Platform initialization. These can also be initiated by commands over the socket (though I'm not sure how important that is).
    init_platform(xclbin);
    init_kernel();  // TODO: FIX size.
  #endif

  #ifdef KERNEL_AVAIL
    kernel.reset_kernel();
  #endif

    int loop_cnt = 0;
    processTraffic();
    
  // }

  return 0;
}


void HostVAddApp::processTraffic() {

  /////////////////////////////////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////// PLASMA - GET THE OBJECT /////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////////////////////////

  // Start up and connect a Plasma client.
  PlasmaClient client;
  ARROW_CHECK_OK(client.Connect("/tmp/plasma"));

  ObjectID object_id = ObjectID::from_binary("dddddddddddddddddddd");
  cout << "Host App receives the object1 with object ID: " << object_id.hex() << endl;

  // Get from the Plasma store by Object ID.
  ObjectBuffer object_buffer;
  ARROW_CHECK_OK(client.Get(&object_id, 1, -1, &object_buffer));

  // Retrieve object data.
  auto buffer = object_buffer.data;
  const uint8_t* rcv_data1 = buffer->data();
  int64_t rcv_data_size1 = buffer->size();

  int test_data[16];

  test_data[0] = 3;
  test_data[1] = 3;
  test_data[2] = 2;
  test_data[3] = 1;

  test_data[4] = 1;
  test_data[5] = 2;
  test_data[6] = 0;
  test_data[7] = 3;

  test_data[8] = 0;
  test_data[9] = 1;
  test_data[10] = 3;
  test_data[11] = 2;

  test_data[12] = 1;
  test_data[13] = 3;
  test_data[14] = 2;
  test_data[15] = 3;

  // Check that the data agrees with what was written in the other process.
  for (int64_t i = 0; i < 16; i++) {
      cout << ARROW_CHECK(rcv_data1[i] == static_cast<uint8_t>(test_data[i]));
  }

  cout << endl;

  /////////////////////////////////

  object_id = ObjectID::from_binary("eeeeeeeeeeeeeeeeeeee");
  cout << "Host App receives the object2 with object ID: " << object_id.hex() << endl;

  // Get from the Plasma store by Object ID.
  object_buffer;
  ARROW_CHECK_OK(client.Get(&object_id, 1, -1, &object_buffer));

  // Retrieve object data.
  auto buffer2 = object_buffer.data;
  const uint8_t* rcv_data2 = buffer2->data();
  int64_t rcv_data_size2 = buffer2->size();

  // int test_data[16];

  test_data[0] = 3;
  test_data[1] = 3;
  test_data[2] = 2;
  test_data[3] = 1;

  test_data[4] = 1;
  test_data[5] = 2;
  test_data[6] = 0;
  test_data[7] = 3;

  test_data[8] = 0;
  test_data[9] = 1;
  test_data[10] = 3;
  test_data[11] = 2;

  test_data[12] = 1;
  test_data[13] = 3;
  test_data[14] = 2;
  test_data[15] = 3;


  send_data(rcv_data1, rcv_data_size1, rcv_data2, rcv_data_size2);

  // Check that the data agrees with what was written in the other process.
  for (int64_t i = 0; i < 16; i++) {
      cout << ARROW_CHECK(rcv_data2[i] == static_cast<uint8_t>(test_data[i]));
  }

  cout << endl;

  // Disconnect the Plasma client.
  ARROW_CHECK_OK(client.Disconnect());

  try {
    cout << "Does it reach here " << endl;
    const int DATA_WIDTH_UINT32 = DATA_WIDTH_BYTES / 4;
    // Allocate in/out data buffers.
    // size_t size = data_json["size"];
    // size_t resp_size = data_json["resp_size"];
    // cout << "Data JSON" << data_json << endl;
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

      // Send data to FPGA, or do fake FPGA processing.
      // #ifdef KERNEL_AVAIL
      // Process in FPGA.
      write_data();
      if (verbosity > 2) {cout << "Wrote kernel." << endl;}


      start_kernel();
      if (verbosity > 2) {cout << "Started kernel." << endl;}

      cout_line() << "Kernel produced:" << endl;
      int match = 0;
      std::cout << "Result:\n";
      for (int i = 0; i < 64; i++) {
          for (int j = 0; j < 16; j++) {
              std::bitset<8> set(source_hw_results[i*16+j]);
              // std::bitset<32> set2(output_string[i]);
              std::cout << std::dec << int(source_hw_results[i*16+j]) << " ";
              // std::cout << "SW: " << set2 << "\n";
          }
          std::cout << "\n";
      }

      ////////////////////////////////////////////////////////////////////////////////////////////////////////
      /////////////////////////////////////////// PLASMA /////////////////////////////////////////////////////
      ////////////////////////////////////////////////////////////////////////////////////////////////////////

      // Start up and connect a Plasma client.
      PlasmaClient client;
      ARROW_CHECK_OK(client.Connect("/tmp/plasma"));

      // Randomly generate an Object ID.
      ObjectID object_id = ObjectID::from_binary("wwwwwwwwwwwwwwwwwwww");
      //ObjectID object_id = 6464646464646464646464646464646464646464
      cout << "object_id (host app - c) " << object_id.hex() << endl;

      // Create Plasma Object
      int64_t data_size = 100;
      // The address of the buffer allocated by the Plasma store will be written at
      // this address.
      shared_ptr<Buffer> data;
      // Create a Plasma object by specifying its ID and size.
      ARROW_CHECK_OK(client.Create(object_id, data_size, NULL, 0, &data));

      ////////////////////////////////////////////////////////////////////////////////////////////////////////
      /////////////////////////////////////////// WRITE TO OBJECT ////////////////////////////////////////////
      ////////////////////////////////////////////////////////////////////////////////////////////////////////

      //Mutable it
      auto d = data->mutable_data();

      char test_data[16];

      // we get this from yeshu
      test_data[0] = 'T';
      test_data[1] = 'G';
      test_data[2] = 'T';
      test_data[3] = 'C';

      test_data[4] = 'G';
      test_data[5] = 'T';
      test_data[6] = 'C';
      test_data[7] = 'A';

      test_data[8] = 'T';
      test_data[9] = 'A';
      test_data[10] = 'G';
      test_data[11] = 'C';

      test_data[12] = 'C';
      test_data[13] = 'G';
      test_data[14] = 'T';
      test_data[15] = 'T';


      // Write some data for the Plasma object.
      for (int64_t i = 0; i < 16; i++) {
          d[i] = static_cast<uint8_t>(test_data[i]);
      }

      // Seal the object. This makes it available for all clients.
      client.Seal(object_id);

      // Disconnect the Plasma client.
      ARROW_CHECK_OK(client.Disconnect());
}