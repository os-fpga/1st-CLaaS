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
#define INIT_PLATFORM "INIT_PLATFORM"
#define INIT_KERNEL   "INIT_KERNEL"
#define START_KERNEL  "START_KERNEL"
#define WRITE_DATA    "WRITE_DATA"
#define READ_DATA     "READ_DATA"
#define CLEAN_KERNEL  "CLEAN_KERNEL"
#define CLOSE_CONN    "CLOSE_CONN"
#define GET_IMAGE     "GET_IMAGE"


#define INIT_PLATFORM_N   1
#define INIT_KERNEL_N     2
#define START_KERNEL_N    3
#define WRITE_DATA_N      4
#define READ_DATA_N       5
#define CLEAN_KERNEL_N    6
#define GET_IMAGE_N       7

// Types of messages
#define DATA_MSG "DATA_MSG"
#define COMMAND_MSG "COMMAND_MSG"

#endif