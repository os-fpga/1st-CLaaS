// This file provides a default main method for the host application.
// It can be specified in the project Makefile as the PROJ_C_SRC for projects (apps) that use the default host application.

#include "server_main.h"

int main(int argc, char const *argv[])
{
  (new HostApp())->server_main(argc, argv);
}
