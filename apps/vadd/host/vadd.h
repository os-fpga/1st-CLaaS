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
** TODO: There's still a lot of image-specific content here. Partition cleanly.
*/

// THIS CODE NOT YET ENABLED
// ERROR

#ifndef VADD_H
#define VADD_H

#include <string>
#include <time.h>


#include "server_main.h"
#include "xcl2.hpp"
#include <plasma/client.h>
#include "arrow/util/logging.h"
using namespace plasma;
using namespace std;

#define DATA_SIZE 256
const unsigned int MAX_GENOME_LEN = 256;
const unsigned int GENOME_SIZE = 2;
const unsigned int IN_MEM_SIZE = 2*MAX_GENOME_LEN*GENOME_SIZE;
const unsigned int OUT_MEM_SIZE = MAX_GENOME_LEN*20;
std::vector<uint, aligned_allocator<uint> > input_string(2*GENOME_SIZE * MAX_GENOME_LEN);
std::map<char, uint> _char_to_bits { {'A', 0}, {'C', 1}, {'G', 2}, {'T', 3}};
std::vector<uint8_t, aligned_allocator<uint8_t> > source_hw_results(DATA_SIZE);
// ---------------------------------------------------------------------------------------------------------
class HostVAddApp : public HostApp {

public:
cl_int err;
cl::CommandQueue commands;
cl::Context context;
cl::Kernel kernel;
cl::Program program;
cl::Buffer buffer_r1;
cl::Buffer buffer_w;
void init_platform(const char* xclbin);
void init_kernel();
void write_data();
void start_kernel();
void clean_kernel();
int server_main(int argc, char const *argv[], const char *kernel_name);
void processTraffic();
  // Without OpenCL, define fake vadd kernel behavior for testing the client.
  // Othersize, default passthrough behavior is fine.
  // void fakeKernel(size_t bytes_in, void * in_buffer, size_t bytes_out, void * out_buffer);
};


#endif
