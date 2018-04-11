# fpga-webserver

This project targets the problem of creating a communication layer between Web Applications and Clous FPGA accelerators in order to enhance the performance of compute-intensive tasks.

The files are organized as follows:
  - srcs: this folder contains software needed to perform the communication. It includes a webserver written in python, a simple web-client needed for testing purposes and the host application written in C and OpenCL which interfaces with the hardware.
  - scripts: this folder contains utility scripts needed to create a Vivado RTL project that holds all the configurations (e.g. # AXI master ports, # scalar arguments, # arguments) for the hardware.
  - hw: this folder contains the hardware project of the first example. We have implemented a Mandelbrot set hardware accelerator that provides images of the Mandelbrot set.

As Cloud FPGA platform we have adopted the AWS F1 instances and the tools (Vivado, SDAccel) and hardware are provided by Xilinx.

# Project description

The communication of data and commands between the Web Application and the FPGA happens in three different steps:

  1) The WebClient performs a WebSocket connection or a Get request to the WebServer. The WebSocket requests have to be in JSON format and contain two different fileds:
    - type: describes the command that has to be performed by the host application and dispatched to the FPGA;
    - data: holds the data to be sent to the FPGA.
  2) The WebServer intercepts all the requests coming from the WebClient and, through a UNIX socket link passes all the requests to the Host Application which will analyses the content of the message and performs the dedicated function.
  3) The Host Application interfaces with the FPGA through OpenCL calls. Once the calls have been performed the host application waits for the results and sends the response back to the Web Application following the same path.

# Prerequisites

In order to test the infrastructure the following prerequisites are needed:
  - AWS account, and accessibility to AWS F1 instances.
  - On the AWS EC2 instance:
    - Python 2.7 or higher;
    - tornado python library
        ```sh
        sudo pip install tornado
        ```
  - The AWS F1 instance has to allow TCP connections on port 8080 (or the one you choose to serve the get or websocket requests):
    1) Go to the EC2 Dashboard;
    2) Click on "Security Group";
    3) Select the one related to your F1 instance;
    4) Go to the "Inbound" tab and click on "Edit";
    5) Select "Custom TCP Rule" as "Type" and insert 8080 as port range.
    6) Save

