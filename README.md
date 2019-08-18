# The 1st CLaaS Framework

#### CLaaS: Custom Logic as a Service

![fpga-webserver header](doc/img/header.png)

## *- Unleashing the 3rd wave of cloud computing*

  - Wave 1: CPUs
  - Wave 2: GPUs
  - **Wave 3: FPGAs**

Having FPGAs ([Field-Progammable Gate Arrays](Newbies.md)) available in the data center presents enormous potential for new and exciting compute models. But, for this emerging ecosystem to thrive, we need infrastructure to develop custom hardware accelerators for these platforms and integrate them with web applications and cloud infrastructure. The 1st CLaaS Framework brings cloud FPGAs within reach of the open-source community, startups, and everyone.



# Documentation

This document provides an overview of the project. After reading this, refer to the following development resources:

  <!--
  - TODO: Include AWS Setup and Running Examples in Simulation in this README. Work toward the following.
  Developer's Guide:
    (At some point) - [**Interface Definition Guide**](...): Defining the communication interface from application to kernel.
    - [**Development Overview**](framework/README.md)
    - [**Kernel Developer's Guide*](KernelDevelopersReference.md): For developing a kernel without any cloud infrastructure.
    - [**Web Developer's Guide**](WebDevReference.md): Connecting with your application.
    - [**Kernel Implementation Guide**](AWSDevelopersReference.md): Using AWS F1 platform to optimize and deploy your kernel.
  -->
  - [**Getting Started**](GettingStarted.md)
  - [**Framework Overview**](framework/README.md)
  - [**Kernel Developer's Reference**](KernelDevelopersReference.md)
  - [**Web Developer's Reference**](WebDevReference.md)


# FPGA-Webserver Project Overview

Prior to this project, integrating FPGA hardware acceleration with web and cloud applications required a full-stack developer, a software engineer, a domain expert, an IaaS expert, and a hardware designer. 1st CLaaS cuts the development overhead from several person-months down to almost nothing, bringing FPGA acceleration within reach of everyone.

![fpga-webserver header](doc/img/simple.png)

With 1st CLaaS, you can stream bits directly to and from your custom FPGA kernel using standard web protocols (WebSockets or REST). In the simplest use case, all software is client-side in the web browser, and all server logic and data storage is implemented in the FPGA. Your kernel uses a very simple interface to stream the data, and it can be developed in Verilog (or any language compilable to Verilog). The developers of this framework are advocates of using TL-Verilog and <a href="http://makerchip.com" target="_blank" atom_fix="_">makerchip.com</a> to simplify kernel development.

1st CLaaS is ideal for implementing functions in hardware that are compute-limited that but tolerant of internet lateny/bandwith. Applications requiring a more sophisticated partitioning of responsibilities can extend the host C++ code or Python web server to process data between the web application and FPGA.

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

1st CLaaS is currently implemented to utilize Amazon's F1 FPGA instances. These are very powerful FPGA instances, and having access to this power using a pay-per-use model is quite compelling. But they are bleeding edge and require significant expertise to utilize. In our experience, documentation is often wrong as APIs and infrastructure are evolving. Developers must have a deep understanding of hardware design. They must be familiar with Xilinx tools: Viviado for RTL design and SDAccel to interface the hardware with C++ code using OpenCL. They must understand AXI protocols and manage AXI controllers. And the AWS platform can be intimidating to a newcomer. By providing the web server, host application code, a kernel shell logic to stream the data between web application and FPGA kernel as well as automating cloud instance creation and configuration, 1st CLaaS hides all of this complexity.



# Project Components

A hardware accelerated web application utilizing this framework consists of:

  - Web Client Application: a web application, or any other agent communicating with the accelerated server via web protocols.
  - Web Server: a web server written in Python
  - Host Application: the host application written in C/C++/OpenCL which interfaces with the hardware.
  - FPGA Shell: FPGA logic provided by this framework that builds upon and simplifies the shell logic provided by Xilinx.
  - Custom Kernel: The application-specific FPGA logic.
  
![framework](doc/img/framework.png)

Data is transmitted from the Web Client Application in chunks of 512 bits (currently):
  - as JSON (currently) via WebSocket to Web Server,
  - as JSON (currently) via a UNIX socket to Host Application,
  - as chunks via OpenCL memory buffers to FPGA Shell,
  - as streamed chunks to Custom Kernel,
  - and back, in similar fashion.

In the simple case, all custom processing of data is performed by the Custom Kernel, but the C++/OpenCL Host Application and/or Python Web Server can be extended as desired.



# Minimal Example

This repository includes a simple Vector Add example in `apps/vadd`. 



# Development Overview

This repository contains all that is needed to develop a hardware-accelerated web application, including the generic 1st Class Framework and sample applications that utilize it. It contains content for web development on a local machine (Ubuntu 16.04 for us) as well as for building FPGA images on the remote F1 machine, so it is to be forked and cloned locally and remotely with different parts edited on each machine.

It is also perfectly reasonable to develop your own web/cloud application using any technologies and infrastructure you choose and utilize this repository just for the FPGA microservice development. The web infrastructure provided in this repository is intentionally basic. Notably, for package management it simply utilizes git submodules to minimize technology dependencies, rather than using a package manager like npm.

Development utilizes multiple machines w/ different cost/capability trade-offs.

  - Local Machine: Any platform of your choice can be utilized for web/cloud application development. Presumably this is your local machine. This repository may be utilized for simple web client applications.
  - Development Instance: An AWS machine (EC2 instance) without an FPGA on which build and simulation can be done. This includes "Hardware Emulation" mode, where the application can be tested w/ FPGA behavior running as simulation. (~$0.80/hr)
  - F1 Instance: The EC2 instance with an attached FPGA, supporting the final application. (~$1.65/hr)

(A future goal includes kernel simulation on the local machine.)

Application development might benefit from fake FPGA behavior at various points:

  - in the Web Client Application, avoiding any server-side functionality altogether
  - in the Host Application, enabling local development (running the web server locally)
  - using Hardware Emulation on the Development Instance (no extra development required)

FPGA Kernel development might justify testbench development at various points:

  - using traditional RTL development methodologies enabling use of Vivado on the Development Instance, or Makerchip for TL-Verilog kernels, etc.); a default testbench leveraging a Xilinx example is available for use (though probably broken?)
  - in the Host Application; a default testbench leveraging a Xilinx example is available for use (though, probably broken?); this would be most useful if OpenCL or RTL shell logic changes are made
  - in a testbench web client; a default web client testbench is provided allowing manual entry of data to send to the kernel
  - in the real Web Client Application; this would be customization of the Web Client Application to support development



# Status

This repository is generally working, and is under active development in the summer of 2019 with sponsorship from Google through <a href="https://summerofcode.withgoogle.com/" target="_blank" atom_fix="_">Google Summer of Code</a>. A working <a href="https://github.com/alessandrocomodi/fpga-webserver/tree/master/apps/mandelbrot" target="_ blank">Mandelbrot explorer</a> is included. This demo is hosted at <a href="http://fractalvalley.net" target="_blank" atom_fix="_">FractalValley.net</a>.



# Directory Structure

  - `framework`: The generic infrastructure for hardware-accelerated web applications.
    - `client`: Client library.
    - `webserver`: Python web server application.
    - `host`: OpenCL/C++ host application framework.
    - `fpga`: FPGA framework, including Verilog/TL-Verilog source code.
    - `terraform`: Stuff related to platform configuration (creating/starting/stopping/destroying EC2 instances) using Terraform.
  - `apps`: Hardware-accelerated web applications utilizing the framework.
    - _app_
      - `client`
      - `webserver`
      - `host`
      - `fpga`
        - `scripts`: Utility scripts needed to create a Vivado RTL project that holds all the configurations (e.g. # AXI master ports, # scalar arguments, # arguments) for the hardware.
      - `build`
        - `Makefile`
      - `out`: The target directory for build results, including the client, webserver, host application, and FPGA images. (This folder is not committed with the repository.)
      - `prebuilt`: Prebuilt client, webserver, host application, and/or FPGA images (AFIs). These may be committed for convenience so users can run new installations without lengthy builds, though the AFIs are not public.
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



# Further Information

Further documentation of the project vision, can be found in this <a href="https://drive.google.com/drive/folders/1EdhyuvQmIN18YxHsRkTGffVvuAwmHfkJ?usp=sharing" target="_ blank">Google Drive Folder</a>.

Here's a short <a href="https://drive.google.com/open?id=1TAUxoCZ3SQpYha5HjXYNDSqQsSvG_ejD" target="_ blank">invited talk</a> at VSDOpen 2018 about cloud FPGAs and the impact they will have on open-source hardware and the silicon industry as a whole that is good context and motivation for this project.



# A Personal History of this Project

Let me introduce myself, so you understand where this project is coming from. I am <a href="https://www.linkedin.com/in/steve-hoover-a44b607/" target="_ blank">Steve Hoover</a>, proud founder of <a href="http://www.redwoodeda.com" target="_blank" atom_fix="_">Redwood EDA</a>. After 18 years of banging my head against the wall designing silicon for Intel using the misguided tools this industry produces, I decided it was time to focus on making better tools. There's no reason circuit design has to be an exclusive club for experts trained in the obscurities of an arcane ecosystem. Digital logic is just 1s and 0s. It can't get any simpler. The difficulty was entirely self-inflicted. So, I set out to fix things and regain my sanity.

The first thing to fix, was the language. Verilog carries with it over 30 years of baggage, and other languages have missed the mark in various ways. So I created TL-Verilog as an incremental path to simpler and *way* better "transaction-level" design methodology. But let's not stop at language, as we've done in the past. We need web- and open-source-friendly tools. Transaction-level design needs to extend from the language into the platform, so I created the <a href="http://makerchip.com" target="_blank" atom_fix="_">Makerchip IDE</a> with the help of a few interns.

As I got more into the open-source community, and as I saw FPGAs becoming available in the cloud, I realized there was a revolution about to unfold. Why? Well, let's get some perspective. Open-source software has been going gangbusters for years, transforming the software industry time and time again. All the while, circuit design has been done using Verilog and text editors. We've been standing still. But it gets worse. Since we started using Verilog, chips have gotten a bit bigger--not physically, but in terms of transistor counts. Any guess how much "bigger"? 100x? 1000x? Not even close. 100,000x!!!

So we're ripe for change. We need circuit design to break out of its commercial fortress and discover what an open source ecosystem is capable of. And guess what. Having FPGAs in the cloud is going to release the flood gates. There have been three things holding back open source hardware:

  1. Circuit design is fundamentally harder than software. Sure, I said "it's just 1s and 0s," but, in contrast to software, the bulk of your development effort tends to focus on the implementation of the logic, not just the functionality.
  1. Access to hardware: Again, in contrast to software, you can't just download someone's RTL and use it. You have to turn it into hardware. For a hobbyist, that's not going to be an ASIC, so we're talking FPGAs. You've got to work this open-source RTL into your specific platform and your specific logic with your specific physical design constraints to make it do your bidding. You may as well start from scratch.
  1. Access to software: Unlike compilers for software, Electronic Design Automation (EDA) tools for compiling hardware are ***expensive***.

And I realized that all of these very serious obstacles were breaking down.

  1. I have greatly simplified hardware design with Redwood EDA, TL-Verilog, and Makerchip.
  2. Hardware access is totally solved by cloud FPGAs. Open source designs can be made available, packaged to run in hardware that is available to anyone! Just download, compile, and run in silicon, just like software.
  3. Other folks, like the almighty <a href="http://www.clifford.at/" target="_blank" atom_fix="_">Clifford Wolf</a>, have been developing open-source EDA tools, and FPGAs have now been designed exclusively using these open-source tools. Even commercially, with Amazon F1, Xilinx tools are now bundled with the platform using a rental model with no up-front cost. And my own Redwood EDA tools are free for open-source development at <a href="http://makerchip.com" target="_blank" atom_fix="_">makerchip.com</a> with no installation required.

This is game-changer! And it's a really refreshing one for me, having spent almost 20 years in an industry that was standing still. So I started ramping up on Amazon F1. Yikes! Holy crap! What a friggin' nightmare! The hardware platform was amazing, but the infrastructure for developing on the platform has a long way to go. So, I turned my attention elsewhere...

...until, I struck up a conversation with Marco Santambrogio at a conference. Marco heads the NECSTLab at Politecnico di Milano with reasearch on the Amazon F1 platform. We started a small collaboration leading to Alessandro Comodi's early contributions to the project. This was enough to draw my attention in this direction. And this year (2019), Google is helping the project along with Akos Hadnagy contributing through <a href="https://summerofcode.withgoogle.com/" target="_blank" atom_fix="_">Google Summer of Code</a>.

I hope you are able to benefit from the work. Please feed back into the project and become a "1st CLaaS citizen"--erg, did I really say that? Let me know what you are planning. Maybe I can help.

Happy coding!

-Steve Hoover



# Acknowledgements

I'd like to thank, in particular, Alessandro Comodi, and Akos Hadnagy for their valuable contributions, and Polytecnicnico di Milano/Marco Santambrogio and Google for helping things along. And though they provide a very powerful foundation, I feel extremely dis-compelled at the moment to thank Amazon and Xilinx, though I welcome any support that might change my attitude.



# Related Technologies

  - We are considering a unification with [Fletcher](https://github.com/johanpel/fletcher).



# To Do

  - Support an emulation flow on local machine using Verilator with no OpenCL, where a Verilator (C++) shell drives the custom kernel directly.
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
