# The 1st CLaaS Framework

#### CLaaS: Custom Logic as a Service

![fpga-webserver header](doc/img/header.png)

## *- Unleashing the 3rd wave of cloud computing!*

  - Wave 1: CPUs
  - Wave 2: GPUs
  - **Wave 3: FPGAs**

Having FPGAs ([Field-Progammable Gate Arrays](Newbies.md)) available in the data center presents enormous potential for new and exciting compute models. But, for this emerging ecosystem to thrive, we need infrastructure to develop custom hardware accelerators for these platforms and integrate them with web applications and cloud infrastructure. The 1st CLaaS Framework brings cloud FPGAs within reach of the open-source community, startups, and everyone.



# Documentation

This document provides an overview of the project, which is valuable context for these step-by-step instructions and development guide:

For initial local development:

  - [**Getting Started**](doc/GettingStarted.md): Instructions to get up and running.
  - [**Developer's Guide**](doc/DevelopersGuide.md): Your main development resource.
  
For optimization and deployment of your custom kernel using AWS F1 with Xilinx tools.

  - [**Getting Started with F1**](doc/GettingStartedF1.md): Instructions to get up and running with AWS, F1, and Xilinx tools.
  - [**Optimization and Deployment Guide**](doc/F1Guide.md): For developing on AWS F1 with Xilinx tools.


# Further Information

  - Further documentation of the project vision, can be found in this <a href="https://drive.google.com/drive/folders/1EdhyuvQmIN18YxHsRkTGffVvuAwmHfkJ?usp=sharing" target="_ blank">Google Drive Folder</a>.
  - A short <a href="https://drive.google.com/open?id=1TAUxoCZ3SQpYha5HjXYNDSqQsSvG_ejD" target="_ blank">invited talk</a> at VSDOpen 2018 about cloud FPGAs and the impact they will have on open-source hardware and the silicon industry as a whole that is good context and motivation for this project.
  - [How 1st CLaaS came to be](doc/Story.md)



# FPGA-Webserver Project Overview

![fpga-webserver header](doc/img/simple.png)

With 1st CLaaS, you can stream bits directly to and from your custom FPGA kernel using standard web protocols (WebSockets or REST). In the simplest use case, all software is client-side in the web browser, and all server logic and data storage is implemented in the FPGA. Your kernel uses a very simple interface to stream the data, and it can be developed in Verilog (or any language compilable to Verilog).

1st CLaaS is ideal for implementing functions in hardware that are compute-limited but tolerant of internet lateny/bandwith. Applications requiring a more sophisticated partitioning of responsibilities can extend the host C++ code or Python web server to process data between the web application and FPGA.

Possible application domains might include:

  - voice/image processing/filtering
  - bioinformatics
  - simulation
  - pattern matching
  - machine learning
  - etc.

Your application might be:

  - a web application that includes a hardware-accelerated function
  - a hardware project controlled via a web interface
  - a healthy mix of custom hardware and software

1st CLaaS supports hardware kernel development using free and open source tools on Linux (Ubuntu and CentOS, currently). Deployment is currently targeted to Amazon's F1 FPGA instances. We welcome contributions to extend 1st CLaaS to other platforms and operating systems.



# Streamlining

Prior to this project, integrating FPGA hardware acceleration with web and cloud applications was a daunting undertaking requiring:

  - a full-stack developer
  - a software engineer
  - a domain expert
  - an IaaS expert
  - a hardware designer

By providing the web server, host application code, and kernel shell logic to stream the data between web application and FPGA kernel as well as automating cloud instance creation and configuration, 1st CLaaS reduces your work to:

  - web development, and
  - logic design

![fpga-webserver header](doc/img/./simplify.png)
<small><small>[CC BY-SA 2.0, <a href="http://www.lumaxart.com/" target="_blank" atom_fix="_">LuMaxArt</a>, modified]</small></small>

Infrastructure development overhead is reduced from several person-months down to hours.

Looking specifically at the Amazon F1 platform, F1 provides powerful Xilinx FPGAs and Xilinx development tools on a pay-per-use basis, which is quite compelling. But the platform is bleeding edge and requires significant expertise to utilize. Our experience with this platform has been a rather painful (and somewhat expensive) one for several reasons:

  - Documentation is often misleading as APIs and infrastructure are evolving.
  - External dependencies are poorly managed, so tutorials break at random.
  - Xilinx tools, Vivado and SDAccel, while powerful, are difficult to learn and use, slow, and arcane.
  - OpenCL is a whole other beast, built for folks who want to design hardware like it's software... which it obviously isn't.
  - Developers must understand AXI protocols and manage AXI controllers.
  - The AWS platform can be intimidating to a newcomer.

We had to go through this pain, but we bundled our work so you won't have to.

To further streamline development and avoid any dependency on the F1 platform and Xilinx tool stack, the server can be run on your local machine where the kernel is emulated with RTL simulation using the Verilator open-source RTL simulator. AWS and Xilinx tools are only required for kernel optimization and deployment. As an added bonus, Verilator simulation runs significantly (~100x?) faster than simulation using the Xilinx "hardware emulation flow," partly because Verilator is fast and partly because it need not include the shell logic surrounding the kernel.

Reducing the problem to web and RTL development is not the finish line for us. 1st CLaaS is a part of a broader effort to redefine the silicon industry and bring silicon to the masses. Getting past the complexities of RTL modeling is part of that. 1st CLaaS is driven by avid supporters of TL-Verilog, in association with Redwood EDA. TL-Verilog introduces a much-needed digital circuit design methodology shift with simpler and more powerful modeling constructs. 1st CLaaS is in no way tied to TL-Verilog. You can use Verilog/SystemVerilog or any hardware description language that can be turned into Verilog. But TL-Verilog lnguage extensions are supported out of the box, and we strongly encourage you to take advantage of them and help us drive this innovation forward. Redwood EDA provides a free, online IDE for TL-Verilog development at <a href="http://makerchip.com" target="_blank" atom_fix="_">makerchip.com</a>. You can find training materials in the IDE. Read [the more-complete story](docs/Story.md) from Redwood EDA founder, <a href="https://www.linkedin.com/in/steve-hoover-a44b607/" target="_ blank">Steve Hoover</a>.

 

# Project Components

A hardware accelerated web application utilizing this framework consists of:

  - Web Client Application: a web application, or any other agent communicating with the accelerated server via web protocols.
  - Web Server: a web server written in Python using the Tornado library.
  - Host Application: the host application written in C/C++/OpenCL which interfaces with the hardware.
  - FPGA Shell: FPGA logic provided by this framework that builds upon and simplifies the shell logic provided by Xilinx.
  - Custom Kernel: The application-specific FPGA logic.
  
![framework](doc/img/framework.png)

Data is transmitted from the Web Client Application in chunks of 512 bits (currently). JavaScript calls a send method and receives data from Custom Kernel in a callback. Custom Kernel has a simple streaming interface with a 512bit bus of input data and a 512-bit bus for output data. Data travels from JavaScript:
  - as JSON (currently) via WebSocket to Web Server,
  - as JSON (currently) via a UNIX socket to Host Application,
  - as chunks via OpenCL memory buffers to FPGA Shell,
  - as streamed chunks to Custom Kernel,
  - and back, in similar fashion.

Communication performance is not currently the focus. Applications that are well suited to this architecture are inherently compute-limited, so optimizing communication is often unimportant, but the implementation can be optimized as the need arises.

In the simple case, you provide only the green components in the diagram above, and all custom processing of data is performed by the Custom Kernel. But the C++/OpenCL Host Application and/or Python Web Server can be extended as desired.



# Status

This repository is generally working, and is under active development in the summer of 2019 with sponsorship from Google through <a href="https://summerofcode.withgoogle.com/" target="_blank" atom_fix="_">Google Summer of Code</a>. A working <a href="https://github.com/alessandrocomodi/fpga-webserver/tree/master/apps/mandelbrot" target="_ blank">Mandelbrot explorer</a> is included. This demo is hosted at <a href="http://fractalvalley.net" target="_blank" atom_fix="_">FractalValley.net</a>.



# Main Contributors

  - <a href="https://www.linkedin.com/in/steve-hoover-a44b607/" target="_ blank">Steve Hoover</a>: Project lead/lead developer.
  - <a href="https://www.linkedin.com/in/alessandro-comodi-2a522a65/" target="_ blank">Alessandro Comodi</a>: Early development, in collaboration with the NECSTLab at Politecnico di Milano, under Marco Santambrogio.
  - <a href="https://www.linkedin.com/in/akos-hadnagy/" target="_ blank">Akos Hadnagy</a>: Terraform and Verilator infrastructure as a student in Google Summer of Code, 2019.



# Related Technologies

  - We are considering a unification with [Fletcher](https://github.com/johanpel/fletcher).



# To Do

(File issues. Repo is going to move; just waiting for that.)

  - It's hard to convince a browser to hard-reload a URL that redirects, so the testbench redirect is hard to clear when a different app is started.
  - The latest SDx version is 2018.3. Instructions need to be updated since 2018.2. (It's 2019. Why are updates happening a year late?) Here are some issues observed w/ 2018.3:
  
  ```
  source ../out/hw_emu/xilinx_aws-vu9p-f1_4ddr-xpr-2pr_4.0/rtl_kernel_wiz.tcl -notrace
  ../../../framework/host/kernel.c: In member function ‘void Kernel::initialize_platform()’:
  ../../../framework/host/kernel.c:143:14: warning: ‘_cl_command_queue* clCreateCommandQueue(cl_context, cl_device_id, cl_command_queue_properties, cl_int*)’ is deprecated (declared at /usr/include/CL/cl.h:1443) [-Wdeprecated-declarations]
     commands = clCreateCommandQueue(context, device_id, 0, &err);
                ^
  ../../../framework/host/kernel.c:143:62: warning: ‘_cl_command_queue* clCreateCommandQueue(cl_context, cl_device_id, cl_command_queue_properties, cl_int*)’ is deprecated (declared at /usr/include/CL/cl.h:1443) [-Wdeprecated-declarations]
     commands = clCreateCommandQueue(context, device_id, 0, &err);
                                                                ^
  ../../../framework/host/kernel.c: In member function ‘void Kernel::start_kernel()’:
  ../../../framework/host/kernel.c:259:9: warning: ‘cl_int clEnqueueTask(cl_command_queue, cl_kernel, cl_uint, _cl_event* const*, _cl_event**)’ is deprecated (declared at /usr/include/CL/cl.h:1457) [-Wdeprecated-declarations]
     err = clEnqueueTask(commands, kernel, 0, NULL, NULL);
           ^
  ../../../framework/host/kernel.c:259:54: warning: ‘cl_int clEnqueueTask(cl_command_queue, cl_kernel, cl_uint, _cl_event* const*, _cl_event**)’ is deprecated (declared at /usr/include/CL/cl.h:1457) [-Wdeprecated-declarations]
     err = clEnqueueTask(commands, kernel, 0, NULL, NULL);
                                                        ^
  ```
  
  These are non-fatal. Maybe `-lxilinxopencl` is no longer needed?


# Immediate Issues

  - create a rdp_ec2 script similar (but simpler) to the vnc_ev2 script. It should update a config file if <IP> is given and run remmina with this config.
  - remove host from prebuilts (to support usage model where C++ is edited, but kernel is prebuilt). Also see if the prebuilt is accessible to other users. Also fix `make push` and `make pull`. (Huh, `make pull` is missing.)
