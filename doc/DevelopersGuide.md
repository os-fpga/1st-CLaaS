<a name="Overview"></a>
# Developer's Guide

# Table of Contents

  - [About this Document](#about)
  - [Prerequisites](#prereq)
  - [Repository Structure](#repo)
  - [Development Strategies](#strategies)
  - [Framework Features](#framework)
  - [Web Client Development](#web_dev)
  - [Kernel Development](#kernel_dev)  



<a name="about"></a>
# About this Document

1st CLaaS is built to enable initial development on your local machine. Local development, using RTL simulation of the custom kernel is covered in this document. When it comes time to optimize and deploy your kernel, 1st CLaaS provides infrastructure to do so using AWS F2 with Xilinx tools. These are covered in separate documents. [Getting Started with F2](GettingStartedF1.md#top) will get you started, and the [Optimization and Deployment Guide](F1Guide.md#top) will be your AWS/F2 reference.



<a name="prereq"></a>
# Prerequisites

Before utilizing this development guide, you should first have an understanding of 1st CLaaS by reading the repository's [README.md](../README.md#top), and you should have gotten your environment up and running stepping through [Getting Started](GettingStarted.md#top).


<a name="repo"></a>
# Repository Structure

This Git repository contains all that is needed to develop a hardware-accelerated web application, including:

  - the generic 1st Class Framework
  - sample applications that utilize the framework

The framework supports:

  - developing a web client on a local machine (Ubuntu 16.04 for us)
  - developing the custom hardware kernel locally
  - developing your accelerated application on AWS F2 machines

The top-level file structure is:

  - `framework`: files that may be used by any or all applications
    - ***content that provides the generic 1st CLaaS framework***
  - `apps`:
    - _app_: individual applications utilizing the framework
      - ***content for this specific app***
  - `aws`: Scripts, etc. used to control AWS instances.
  - `bin`: top-level executables (not all scripts are in a `/bin` directory).
    - `regress`: a regression script that launches framework and app regression scripts
  - `doc`: documentation (including this document)
  - `init`: a script to set up the repository for development
  - `vitis_setup`: a script to set up for development using Xilinx tools on AWS

An application _`foo`_ is constructed from code in `framework` and `apps/foo`. `framework` and `apps/foo` contain files/directories using nearly identical structure:

  - `bin`: executables
    - `regress`: regression script
  - `webserver`: python web server application
  - `client`: browser application code served by web server
    - `html`: HTML
    - `js`: JavaScript
    - `css`: CSS (Cascading Style Sheets)
  - `host`: OpenCL/C++ host application
  - `fpga`: content for the FPGA kernel, including Verilog/TL-Verilog source code
    - `scripts`: (framework) utility scripts needed to create a Vivado RTL project
    - `src`: Verilog/SystemVerilog/TL-Verilog/etc. source code for the kernel
  - `terraform`: content related to platform configuration (creating/starting/stopping/destroying EC2 instances) using Terraform
  - `build`: content related to building and running
    - `Makefile`: nearly all build automation and interactive commands
  - `out`: the target directory for build results, including the host application binary and FPGA images; (not committed with the repository)
  - `prebuilt`: prebuilt host application, and public Amazon FPGA Image (AFI) identifier; these may be committed for convenience so users can run new installations without lengthy builds



<a name="strategies"></a>
# Development Strategies

![framework](img/framework.png)

Your development strategy--how you partition development tasks--will depend on your specific application, but this section describes some possible strategies and considerations, and development infrastructure provided by 1st CLaaS.

It is perfectly reasonable to develop your own web/cloud application using any technologies and infrastructure you choose and utilize this repository just for the FPGA microservice development (everything server-side). The web infrastructure provided in this repository is intentionally basic to illustrate the framework with relative simplicity. Notably, for package management this repository simply utilizes git submodules rather than using a package manager like npm. Web library content provided in this repository is not currently bundled for package managers, like npm, (but that can easily be remedied).

<!-- Web Server (Python) and Host Application (C++) can be extended as desired, but in the simplest usage, they can be directly provided by the framework. -->

An actual F2, and even AWS as a whole, are needed very little during development, especially early on. Four modes of execution are supported by the build process, controlled by the `TARGET` Make variable, and requiring different platforms:

  - Software (`sw`): An optional mode where the RTL kernel is not utilized. Custom C++ code is required to provide emulated kernel behavior.
  - Simulation (`sim`): Verilator is used for 2-state simulation of the custom RTL kernel. Verilator creates a C++ model of the kernel which is directly compiled in with the host executable. The Host Application C++ code controls the kernel clock and decides when to send/receive data to/from the kernel.
  - Hardware Emulation (`hw_emu`): This mode is supported by Xilinx Vitis on AWS. All FPGA logic is simulated, including the custom kernel and surrounding shell logic. This runs much slower than Simulation.
  - Hardware (`hw`): Runs on a real FPGA. **Note:** AWS F1 instances have been discontinued. AWS F2 instances are the replacement, but Vitis-based AFI generation is [not yet supported on F2](https://awsdocs-fpga-f2.readthedocs-hosted.com/latest/vitis/README.html). As a result, the `hw` target is currently unavailable. Development is limited to `hw_emu` mode on a Development Instance for now.

Generally, most kernel development is done in Simulation. Hardware Emulation is used to refine the implementation of the design and may catch a few new bugs because of 4-state modeling and test bench differences. Hardware compilation is primarily for testing the application at speed and for deployment.

It is often reasonable to co-develop the client and kernel as a single application. Other times it can be beneficial to develop the application and kernel separately, in which case test benches with fake FPGA kernel and fake web application will be needed.

Software development might benefit from fake FPGA behavior at various points to speed development and provide control over testing:

  - In the Web Client Application, avoiding any server-side functionality altogether. Especially when web development is in a separate repository/framework this can help to cleanly partition development
  - In the Web Server and/or Host Application (`sw` target). This enables local development without RTL. (There is currently no specific build target for Web Server without Host, but this could be added.)

FPGA Kernel development might justify test bench development at various points:

  - At the custom kernel interface: This limits the design under test to just RTL, and enables any RTL-based testing methodology and framework. Some options would be:
    - Vivado on AWS.
    - For TL-Verilog kernels, it can be natural to use a TL-Verilog test bench and, for simple test benches, [Makerchip](#makerchip).
  - At the Xilinx "Custom Logic" boundary: This is also RTL-only. A default test bench leveraging a Xilinx example is available for use (though it is not in use and is probably broken?).
  - In the Host Application: A default test bench leveraging a Xilinx example is available for use (though it is not in use and is probably broken?). This would be most useful if OpenCL or RTL shell logic changes are made.
  - In the Web Server: If you like Python.
  - In a test bench web client: A default web client test bench is provided (as used by the `vadd` example) allowing manual entry of data to send to the kernel
  - In the real Web Client Application: This would be a options in the Web Client Application to control stimulus for development.



<a name="framework"></a>
# Framework Features

## Makefile

The `Makefile` encapsulates just about every command provided by the framework for development. See header comments in `<repo>/framework/build/Makefile` for details.


## REST API

The web server provides, or can provide, the following REST API features.

  - Self identification: The web server can determine its own IP to enable direct communication in scenarios where its content is served through a proxy.
  - Starting/Stopping an F2 instance for acceleration.


<a name="web_dev"></a>
# Web Client Development

For now, follow the lead of `<repo>/framework/client/*/testbench.*`. Methods provided by `<repo>/framework/client/js/fpgaServer.js` are very much subject to change.



<a name="kernel_dev"></a>
# Kernel Development

This section describes development of custom FPGA RTL kernels using the provided Kernel API. Development that modifies the provided kernel interface is not covered here, nor elsewhere (other than in the commented code).


## Kernel Interface

A custom FPGA kernel named _`foo`_ is provided as a SystemVerilog module with the following interface. Note that this is subject to change).

```
module foo_kernel #(
    parameter integer C_DATA_WIDTH = 512 // Data width of both input and output data
                                         // (This will be instantiated with its default value of 512.)
) (
    input wire                       clk,
    input wire                       reset,

    // Input interface:
    output wire                      in_ready,
    input wire                       in_avail,
    input wire  [C_DATA_WIDTH-1:0]   in_data,

    // Output interface:
    input wire                       out_ready,
    output wire                      out_avail,
    output wire [C_DATA_WIDTH-1:0]   out_data
);
```

This includes a streaming interface at the input and another at the output. Unless there are modifications to the intervening software layers, the data streaming into the kernel is the data sent from the Web Client application (or cloud application) communicating via the WebSocket, and the data sent from the kernel is received by the Web Client.

The streaming interface includes, `ready`, `avail`, and `data`. This is similar to a standard AXI streaming interface, generally referred to as a ready/valid protocol, though the naming is chosen to be consistent with TL-Verilog naming conventions.

In a given cycle, these signals relate to the same data transfer, where:

  - `ready`: The receiver is willing to accept the data.
  - `avail`: The transmitter has data to deliver.
  - `data`: The data.



<a name="makerchip"></a>
## TL-Verilog and Makerchip

Any means of delivering this kernel can be utilized, but we are partial to developing with TL-Verilog in the <a href="http://www.makerchip.com/" target="_blank" atom_fix="_">makerchip.com</a> IDE. If you are unfamiliar, TL-Verilog and Makerchip are bleeding edge, meaning they are really cool technology, but you will experience some growing pains. We encourage you to use them and support the revolution, and we'll help as best we can.


### TL-Verilog

TL-Verilog is supported in 1st CLaaS, using Redwood EDA's SandPiper(TM) SaaS edition running as a cloud service. The `Makefile` uses this free (though as-is) service to compile `.tlv` files into `.sv` files. A local installation of SandPiper can also be used.


### Makerchip

Considerations for using Makerchip:

  - Pros:
    - No licensing; no installation; all-in-one IDE.
    - Easy: Even without a test bench, Makerchip will generate random stimulus.
    - Built for TL-Verilog: Integrates the abstractions of TL-Verilog: pipelines, transactions, etc.
  - Cons:
    - Not seamless: Cut-and-paste files to import/export.
    - For small/medium kernels: Limited to single-file editing. For large multi-file kernels, Makerchip, in its current state, would be awkward (though we do it).
    - Verilator is used for compilation, so no SystemVerilog/UVM test bench features are available, just TL-Verilog.

Expect the pros to grow and the cons to shrink over time.

To use Makerchip for development, copy `.tlv` code into the <a href="http://www.makerchip.com/" target="_blank" atom_fix="_">Makerchip/a> IDE, and copy back when finished (and features are in the plans to automate this). Development templates will be provided over time.

This link opens the
<a href="http://www.makerchip.com/sandbox?code_url=https:%2F%2Fraw.githubusercontent.com%2Fstevehoover%2F1st-CLaaS%2Fmaster%2Fapps%2Fmandelbrot%2Ffpga%2Fsrc%2Fmandelbrot_kernel.tlv" target="_blank" atom-fix="_">latest Mandelbrot Kernel from GitHub in the Makerchip IDE</a>.

A WIP library of generic TL-Verilog components which mostly utilize the ready/avail interface protocol can be found <a href="https://github.com/stevehoover/tlv_flow_lib" target="_blank" atom-fix="_">here</a>.
