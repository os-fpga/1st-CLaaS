# Developer's Guide

# Table of Contents

  - [About this Document](#about)
  - [Prerequisites](#prereq)
  - [Repository Structure](#repo)
  - [Development Overview](#overview)
  - [Web Client Development](#web_dev)
  - [Kernel Development](#kernel_dev)  



<a name="about"></a>
# About this Document

1st CLaaS is built to enable initial development on your local machine. Local development, using RTL simulation of the custom kernel is covered in this document.

When it comes time to optimize and deploy your kernel, 1st CLaaS provides infrastructure to do so using AWS F1 with Xilinx tools. These are covered in separate documents. [Getting Started with F1](doc/GettingStartedF1.md) will get you started, and the [Optimization and Deployment Guide](doc/F1Guide.md) will be your AWS/F1 reference.



<a name="prereq"></a>
# Prerequisites

Before utilizing this development guide, you should first have an understanding of 1st CLaaS by reading the repository's [README.md](../README.md), and you should have gotten your environment up and running stepping through [Getting Started](doc/GettingStarted.md).

<a name="repo"></a>
# Repository Structure

This Git repository contains all that is needed to develop a hardware-accelerated web application, including:

  - the generic 1st Class Framework
  - sample applications that utilize the framework

It contains infrastructure for:

  - developing a web client on a local machine (Ubuntu 16.04 for us)
  - developing the hardware kernel locally
  - building and optimizing FPGA images on the remote F1 machine

The top-level file structure is:

  - `framework`: files that may be used by any or all applications
    - ***content that provides the generic 1st CLaaS framework***
  - `apps`:
    - _app_: individual applications utilizing the framework
      - ***content for this specific app***
  - `bin`
    - `regress`: a regression script that launches framework and app regression scripts
  - `doc`: documentation (including this document)
  - `init`: a script to set up the repository for development
  - `sdaccel_setup`: a script to set up for development using Xilinx tools on AWS

An application _`foo`_ is constructed from code in `framework` and `apps/`_`foo`_ and these contain files/directories using nearly identical structure:

  - `bin`: executables
    - `regress`: regression script
  - `webserver`: python web server application
  - `client`: web application code served by web server
    - `html`: HTML code
    - `js`: JavaScript code
    - `css`: CSS (Cascading Style Sheets) code
  - `host`: OpenCL/C++ host application
  - `fpga`: content for the FPGA kernel, including Verilog/TL-Verilog source code
    - `scripts`: (framework) utility scripts needed to create a Vivado RTL project
    - `src`: Verilog/SystemVerilog/TL-Verilog/etc. source code for the kernel
  - `terraform`: content related to platform configuration (creating/starting/stopping/destroying EC2 instances) using Terraform
  - `build`: content related to building and running
    - `Makefile`: nearly all build automation
  - `out`: the target directory for build results, including the client, webserver, host application, and FPGA images (not committed with the repository)
  - `prebuilt`: prebuilt client, web server, host application, and/or FPGA images (AFIs). These may be committed for convenience so users can run new installations without lengthy builds, though the AFIs are not public



<a name="overview"></a>
# Development Overview

## Web Development Overview

It is perfectly reasonable to develop your own web/cloud application using any technologies and infrastructure you choose and utilize this repository just for the FPGA microservice development (everything server-side). The web infrastructure provided in this repository is intentionally basic to illustrate the framework with relative simplicity. Notably, for package management this repository simply utilizes git submodules rather than using a package manager like npm.

Application development might benefit from fake FPGA behavior at various points:

  - in the Web Client Application, avoiding any server-side functionality altogether
  - in the Host Application, enabling local development (running the web server locally)
  - using Hardware Emulation on the Development Instance (no extra development required)

FPGA Kernel development might justify testbench development at various points:

  - using traditional RTL development methodologies enabling use of Vivado on the Development Instance, or Makerchip for TL-Verilog kernels, etc.); a default testbench leveraging a Xilinx example is available for use (though probably broken?)
  - in the Host Application; a default testbench leveraging a Xilinx example is available for use (though, probably broken?); this would be most useful if OpenCL or RTL shell logic changes are made
  - in a testbench web client; a default web client testbench is provided allowing manual entry of data to send to the kernel
  - in the real Web Client Application; this would be customization of the Web Client Application to support development



<a name="framework"></a>
# Framework Features

## REST API

The webserver provides, or can provide, the following REST API features.

  - Self identification: The webserver can determine its own IP to enable direct communication in scenarios where its content is served through a proxy.
  - Starting/Stopping an F1 instance for acceleration.


<a name="ernel_dev"></a>
# Kernel Development

This section describes development of custom FPGA RTL kernels using the provided Kernel API. Development that modifies the provided kernel interface is not covered here, nor elsewhere (other than in the commented code).


## Kernel Interface

A custom FPGA kernel named "foo" is provided as a SystemVerilog module with the following interface. Note that this is subject to change).

```
module foo_kernel #(
    parameter integer C_DATA_WIDTH = 512 // Data width of both input and output data
                                         // (This will be instantiated with its default value of 512.)
) (
    input wire                       clk,
    input wire                       reset,

    output wire                      in_ready,
    input wire                       in_avail,
    input wire  [C_DATA_WIDTH-1:0]   in_data,

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


## TL-Verilog and Makerchip

Any means of delivering this kernel can be utilized, but we are partial to developing with TL-Verilog in  [Makerchip](https://makerchip.com/) IDE.

You can copy `.tlv` code into Makerchip and copy back when finished. The Makefile will compile this into Verilog/SystemVerilog using
Redwood EDA's SandPiper(TM) SaaS edition running as a cloud service. (This link opens the
<a href="http://www.makerchip.com/sandbox?code_url=https:%2F%2Fraw.githubusercontent.com%2Falessandrocomodi%2Ffpga-webserver%2Fmaster%2Fapps%2Fmandelbrot%2Ffpga%2Fsrc%2Fmandelbrot_kernel.tlv" target="_blank" atom-fix="_">latest Mandelbrot Kernel from GitHub in the Makerchip IDE</a>.

A WIP library of generic TL-Verilog components which mostly utilize the ready/avail interface protocol can be found <a href="https://github.com/stevehoover/tlv_flow_lib" target="_blank">here</a>.

