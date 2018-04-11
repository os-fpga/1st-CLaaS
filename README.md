# fpga-webserver

This project targets the problem of creating a communication layer between Web Applications and Clous FPGA accelerators in order to enhance the performance of compute-intensive tasks.

The files are organized as follows:
  - srcs: this folder contains software needed to perform the communication. It includes a webserver written in python, a simple web-client needed for testing purposes and the host application written in C and OpenCL which interfaces with the hardware.
  - scripts: this folder contains utility scripts needed to create a Vivado RTL project that holds all the configurations (e.g. # AXI master ports, # scalar arguments, # arguments) for the hardware.
  - hw: this folder contains the hardware project of the first example. We have implemented a Mandelbrot set hardware accelerator that provides images of the Mandelbrot set.

As Cloud FPGA platform we have adopted the AWS F1 instances and the tools (Vivado, SDAccel) and hardware are provided by Xilinx.

