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
#include <assert.h>

char *genomeS = "ATCG";
char *genomeT = "GTAG";
const int MAX_GENOME_LEN = 1024;
const int GENOME_SIZE = 2;
const IN_MEM_SIZE = 2*MAX_GENOME_LEN*GENOME_SIZE;
const OUT_MEM_SIZE = MAX_GENOME_LEN*20;
constexpr std::bitset<IN_MEM_SIZE> input_string;


std::map<char, std::bitset<2>> _char_to_bits { {"A", "00"}, {"C", "01"}, {"T", "10"}, {"G", "11"}};

void HostVAddApp::send_data(char *S, char *T){
    // Process in FPGA.
  assert(S.size() < GENOME_SIZE * MAX_GENOME_LEN);
  assert(T.size() < GENOME_SIZE * MAX_GENOME_LEN);
  for(int i = 0 ; i < S.size(); i++){
    input_string[i*GENOME_SIZE] |= _char_to_bits[S[i]];
  }
  for(int i = 0 ; i < T.size(); i++){
    input_string[(i+MAX_GENOME_LEN)*GENOME_SIZE] |= _char_to_bits[T[i]];
  }


  kernel.writeKernelData(&input_string, IN_MEM_SIZE, OUT_MEM_SIZE);
  if (verbosity > 2) {cout << "Wrote kernel." << endl;}
}

void HostVAddApp::processTraffic() {
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
            send_data(genomeS, genomeT)
            // kernel.writeKernelData(int_data_p, size * DATA_WIDTH_BYTES, resp_size * DATA_WIDTH_BYTES);
            // if (verbosity > 2) {cout << "Wrote kernel." << endl;}


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


void HostVAddApp::fakeKernel(size_t bytes_in, void * in_buffer, size_t bytes_out, void * out_buffer) {
  if (bytes_out != bytes_in) {
    cerr_line() << "VAdd fakeServer expects bytes_out (" << bytes_out << ") == bytes_in (" << bytes_in << "). Exiting." << endl;
    exit(1);
  }
  if (bytes_in & 0x3) {
    cerr_line() << "VAdd fakeKernel expects uint32's, but received " << bytes_in << " bytes." << endl;
  }
  
  for (int i = 0, uint32 * in = (uint32 *)in_buffer, uint32 * out = (uint32 *)out_buffer; i < bytes_in >> 2; i++, in++, out++) {
    *out = *in + 1;
  }
}
