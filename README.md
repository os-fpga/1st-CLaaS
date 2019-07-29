![fpga-webserver header](doc/img/header.png)

# *- Accelerating the Web -*

# About this Document

This document provides an overview of the project. After reading this, find details in:

  - [**Getting Started**](GettingStarted.md)
  - [**Framework Overview**](framework/README.md)
  - [**Kernel Developer's Reference**](KernelDevelopersReference.md)
  - [**Web Developer's Reference**](WebDevReference.md)


# FPGA-Webserver Project Overview

This project brings data-center [FPGAs](Newbies.md) within reach for students, start-ups, and everyone. With a singular focus on simplifying, it enables FPGA hardware acceleration to be easily integrated with web and cloud applications in an FPGAs-as-a-Service (FPGAaaS) model. The goal, modestly, is to enable an <a href="https://drive.google.com/open?id=1TAUxoCZ3SQpYha5HjXYNDSqQsSvG_ejD" target="_ blank">***open-source hardware revolution***</a>!

Having FPGAs in the cloud enables very exciting compute models for accelerated, distributed applications, but these platforms have not been easy to use. Prior to this project, developing such an application required a full-stack developer, a software engineer, a domain expert, an IaaS expert, and a hardware designer, making them out-of-reach for individuals and small enterprises.

![fpga-webserver header](doc/img/simple.png)

With this framework, you can accelerate a web application using web protocols (WebSockets or REST) to stream bits directly to and from your custom FPGA kernel using a very simple interface. It can be developed in Verilog (or any language compilable to Verilog). In the spirit of open-source and simplicity, we advocate for TL-Verilog development using <a href="http://makechip.com" target="_blank" atom_fix="_">makechip.com</a>.

This framework is ideal for applications that are compute-limited, not communication limited. In this simplest use case, all software is client-side in the web browser, all server logic is implemented in the FPGA, and all data storage utilizes the FPGA memory. Applications requiring a more sophisticated partitioning of responsibilities can extend the host C++ code to process data between the web application and FPGA.

Possible application domains might include:

  - voice/image processing/filtering
  - bioinformatics
  - simulation
  - pattern matching
  - machine learning
  - etc.

This project currently focuses on utilizing Amazon's F1 FPGA instances. These are very powerful FPGA instances, and having access to this power using a pay-per-use model is compelling. Unfortunately, they are bleeding edge and require significant expertise to utilize. In our experience, documentation is often wrong as APIs and infrastructure are evolving. Developers must have a deep understanding of hardware design. They must be familiar with Xilinx tools: Viviado for RTL design and SDAccel to interface the hardware with C++ code using OpenCL. They must understand AXI protocols and manage AXI controllers. And the AWS platform can be intimidating to a newcomer. By providing the webserver, host application code, and kernel shell logit to stream the data between web application and FPGA kernel, this framework hides this complexity.

Further documentation of the project vision, can be found in this <a href="https://drive.google.com/drive/folders/1EdhyuvQmIN18YxHsRkTGffVvuAwmHfkJ?usp=sharing" target="_ blank">Google Drive Folder</a>.

Here's a short <a href="https://drive.google.com/open?id=1TAUxoCZ3SQpYha5HjXYNDSqQsSvG_ejD" target="_ blank">invited talk</a> at VSDOpen 2018 about cloud FPGAs and the impact they will have on open-source hardware and the silicon industry as a whole that is good context and motivation for this project.



# Status

This repository is generally working, and is under active development in the summer of 2019 with sponsorship from Google through <a href="https://summerofcode.withgoogle.com/dashboard/project/6298628153409536/overview/" target="_blank" atom_fix="_">Google Summer of Code</a>. A working <a href="https://github.com/alessandrocomodi/fpga-webserver/tree/master/apps/mandelbrot" target="_ blank">Mandelbrot explorer</a> is included. This demo is hosted at <a href="http://fractalvalley.net" target="_blank" atom_fix="_">FractalValley.net</a>.


# Project Components

A hardware accelerated web application utilizing this framework consists of:

  - Web Client: a web application, or any other agent communicating with the accelerated server via web protocols.
  - Web Server: a web server written in Python
  - Host Application: the host application written in C/C++/OpenCL which interfaces with the hardware.

The WebSocket or REST communication between the Web Application and the FPGA passes through:

  1. The Web Client application, written in JavaScript running in a web browser, transmits JSON (for now), via WebSocket or GET, to the Web Server. The communication is currently simple commands containing:
      - type: describes the command that has to be performed by the host application and dispatched to the FPGA;
      - data: a data value to be sent to the FPGA.
  1. The Web Server, a Python web server, echoes commands via UNIX socket to the Host Application.
  1. The Host Application, written in C/C++/OpenCL, transmits the commands to the FPGA Shell through OpenCL calls.
  1. The FPGA Shell, written in Verilog and configured by scripts, communicates between memory and the Custom Kernel via AXI and FIFOs.
  1. The Custom Kernel, provided as Verilog, and for Mandelbrot written in TL-Verilog, processes the data stream from the FPGA Shell and produces a data stream returned to the FPGA Shell
  1. The FPGA Shell transmits the data stream to the Host Application. For Mandelbrot, this data is depth values for each pixel.
  1. The Host Application, for Mandelbrot, processes pixel depths into colors, and into a `.png` data stream, which is returned over the UNIX socket to the Web Server.
  1. The Web Server echoes the data stream to the client via the WebSocket or as a GET response.
  1. The Web Cient displays the image.


# Development Overview

This repository contains all that is needed to develop a hardware-accelerated web application, including the generic framework and sample applications that utilize the framework. It contains content for web development on a local machine (Ubuntu 16.04 for us) as well as for building FPGA images on the remote F1 machine, so it is to be forked and cloned locally and remotely with different parts edited on each machine.

It is also perfectly reasonable to develop your own web/cloud application using any technologies and infrastructure you choose, and utilize this repository for the FPGA development. The web infrastructure provided in this repository is intentionally basic. Notably, for package management it simply utilizes git submodules to minimize technology dependencies, rather than using a package manager like npm.

Development utilizes multiple machines w/ different cost/capability trade-offs.

  - Local Machine: Any platform of your choice can be utilized for web/cloud application development. Presumably this is your local machine. This repository may be utilized for simple web clients.
  - Development Instance: An AWS machine (EC2 instance) without an FPGA on which build and simulation can be done. This includes "Hardware Emulation" mode, where the application can be tested w/ FPGA behavior running as simulation. (~$0.80/hr)
  - F1 Instance: The EC2 instance with an attached FPGA, supporting the final application. (~$1.65/hr)

(A future goal includes kernel emulation on the local machine.)

Application development might benefit from fake FPGA behavior at various points:

  - in the Web Client, avoiding any C++/OpenCL/RTL in the client application development
  - in the Host Application, enabling local development
  - using Hardware Emulation on the Development Instance (no extra development required)

FPGA Kernel development might justify testbench development at various points:

  - using traditional RTL development methodologies enabling use of Vivado on the Development Instance, or Makerchip for TL-Verilog kernels, etc.); a default testbench leveraging a Xilinx example is available for use (though probably broken)
  - in the Host Application; a default testbench leveraging a Xilinx example is available for use (though, probably broken); this would be most useful if OpenCL or RTL shell logic changes are made
  - in a testbench web client; a default web client testbench is provided allowing manual entry of data to send to the kernel
  - in the real Web Client; this would be customization of the Web Client to support development


# Directory Structure

  - `framework`: The generic infrastructure for hardware-accelerated web applications.
    - `client`: Client library.
    - `webserver`: Python web server application.
    - `host`: OpenCL/C++ host application framework.
    - `fpga`: FPGA framework, including Verilog/TLV source code.
    - `terraform`: Stuff related to platform configuration (creating/starting/stopping/destroying EC2 instances) using Terraform.
  - `apps`: Hardware-accelerated web applications utilizing the framework.
    - _app_
      - `client`
      - `webserver`
      - `host`
      - `fpga`: FPGA kernel, including Verilog/TLV source code.
        - `scripts`: Utility scripts needed to create a Vivado RTL project that holds all the configurations (e.g. # AXI master ports, # scalar arguments, # arguments) for the hardware.
      - `build`
        - `Makefile`
      - `out`: The target directory for build results, including the client, webserver, host application, and FPGA images. (This folder is not committed with the repository.)
      - `prebuilt`: Prebuilt client, webserver, host application, and/or FPGA images. These may be committed for convenience so users can run new installations without lengthy builds.
    - _(specific apps)_
    - `echo`: (To be created.) A template application that simply echoes data on a websocket
      - `client`
      - `host`
      - `fpga`
      - `build`
        - `Makefile`
    - `mandelbrot`
      - `client`
      - `webserver`
      - `host`
      - `fpga`
      - `build`
        - `Makefile`


# A Personal History of this Project

Let me introduce myself. I am <a href="https://www.linkedin.com/in/steve-hoover-a44b607/" target="_ blank">Steve Hoover</a>, proud founder of <a href="http://www.redwoodeda.com" target="_blank" atom_fix="_">Redwood EDA</a>. After 18 years of banging my head against the wall designing silicon for Intel using the garbage this industry produces to do so, I decided it was time to focus on making better tools. There's no reason circuit design has to be an exclusive club for experts trained in the obscurities of an arcane ecosystem. It's just 1s and 0s. It can't get any simpler. The difficulty was entirely self-inflicted. So, let's fix it.

The first thing to fix, was the language. Verilog carries with it over 30 years of baggage, and other languages have missed the mark in various ways. So I created TL-Verilog as an incremental path to simpler and *way* better "transaction-level" design methodology. But let's not stop at language, as we've done in the past. We need web- and open-source-friendly tools, and transaction-level design needs to extend from the language into the platform, so I created the <a href="http://makechip.com" target="_blank" atom_fix="_">Makerchip IDE</a>.

As I got more into the open-source community, and as I saw FPGAs becoming available in the cloud, I realized there was a revolution about to unfold. Why? Well, let's get some perspective. Open-source software has been going gangbusters for years, transforming the software industry time and time again. All the while, circuit design has been done using Verilog and text editors. We've been standing still. But it gets worse. Since we started using Verilog, chips have gotten a bit bigger--not physically, but in terms of transistor counts. Any guess how much "bigger"? 100x? 1000x? Not even close. 100,000x!!!

So we're ripe for change. We need circuit design to break out of its commercial fortress and discover what an open source ecosystem is capable of. And guess what. Having FPGAs in the cloud is going to release the flood gates. There have been three things holding back open source hardware:

  1. Circuit design is fundamentally harder than software. I know. I said "1s and 0s". But, unlike software, your logic is physically constrained. And, like I said, Verilog and commercial tools aren't making life much easier.
  1. Access to software: Electronic Design Automation (EDA) tools are ***expensive***.
  1. Access to hardware: You can't just download someone's RTL and use it. You have to turn it into hardware. For a hobbyist, that's not going to be an ASIC, so we're talking FPGA. You've got to work this open-source RTL into your specific platform and your specific logic with your specific physical design constraints to make it do your bidding. You may as well start from scratch.

And I realized that all of these very serious obstacles were breaking down.

  1. I had been focused on simplifying hardware design with Redwood EDA, TL-Verilog, and Makerchip.
  2. Other folks, like the almighty <a href="http://www.clifford.at/" target="_blank" atom_fix="_">Clifford Wolf</a>, have been developing open-source EDA tools, and FPGAs have been designed using purely open-source tools. Even commercially, with Amazon F1, Xilinx tools are bundled with the platform using a rental model with no up-front cost. And my own Redwood EDA tools are free for open-source development at <a href="http://makechip.com" target="_blank" atom_fix="_">makechip.com</a>, and you don't even need to install them.
  3. Hardware access is totally solved by cloud FPGAs. Open source designs can be made available, packaged to run in hardware that is available to anyone! Just download, compile, and run in silicon, just like software.

This is awesome! So a started ramping up on Amazon F1. Holy crap! What a friggin' nightmare! I've been working with others now for over a year to develop this framework using F1--very painful for me, but there's no need for you to experience that pain. I hope you are able to get up and running with this platform much easier using this framework. And, I hope you choose to feed back into the effort.

Happy coding!

-Steve Hoover


# Related Technologies

  - [Fletcher](https://github.com/johanpel/fletcher) might make a good foundation for this framework.



# To Do

  - Support an emulation flow on local machine using Verilator with no OpenCL, where a Verilator (C++) shell drives the user kernel directly.
  - Automate waiting for AFI creation to complete and deleting the tarball (and update GettingStarted.md).
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
  - apps/mandelbrot/out/ does not exist for make command above. (FIXED?)
  - remove host from prebuilts (to support usage model where C++ is edited, but kernel is prebuilt). Also see if the prebuilt is accessible to other users. Also fix `make push` and `make pull`. (Huh, `make pull` is missing.)
