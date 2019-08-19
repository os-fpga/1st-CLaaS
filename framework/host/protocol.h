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
** This header file contains the definition of the protocol used 
** to synchronize and understand the various commands that are sent
** to the host application.
**
** Author: Alessandro Comodi, Politecnico di Milano
**
*/

#ifndef PROTOCOL_H
#define PROTOCOL_H

// Types of commands
// TODO: Rethink protocol.
#define INIT_PLATFORM "INIT_PLATFORM"
#define INIT_KERNEL   "INIT_KERNEL"
#define START_KERNEL  "START_KERNEL"
#define WRITE_DATA    "WRITE_DATA"
#define READ_DATA     "READ_DATA"
#define CLEAN_KERNEL  "CLEAN_KERNEL"
#define CLOSE_CONN    "CLOSE_CONN"
#define GET_IMAGE     "GET_IMAGE"
#define DATA_MSG      "DATA_MSG"  // Generic data message containing JSON array of 16-entry arrays of unsigned integer (32-bit) data to be sent to FPGA.
#define START_TRACING "START_TRACING"
#define STOP_TRACING  "STOP_TRACING"


#define INIT_PLATFORM_N   1
#define INIT_KERNEL_N     2
#define START_KERNEL_N    3
#define WRITE_DATA_N      4
#define READ_DATA_N       5
#define CLEAN_KERNEL_N    6
#define GET_IMAGE_N       7
#define DATA_MSG_N        8
#define START_TRACING_N   9
#define STOP_TRACING_N    10

// Types of messages
#define DATA_MSG "DATA_MSG"
#define COMMAND_MSG "COMMAND_MSG"

#endif