#include "mandelbrot.h"

int main(int argc, char const *argv[])
{
  (new HostMandelbrotApp())->server_main(argc, argv);
}
