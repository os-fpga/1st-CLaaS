# Getting Started with F1

# Table of Contents

  - [About this Document](#about)



<a name="about"></a>
# About this Document

This guide will walk you through the steps to run 1st CLaaS sample applications using AWS F1 and other AWS resources and prepare you for development of your own accelerated application.

Development utilizes multiple machines w/ different cost/capability trade-offs.

  - Local Machine: Any platform of your choice can be utilized for web/cloud application development. Presumably this is your local machine. This repository may be utilized for simple web client applications.
  - Development Instance: An AWS machine (EC2 instance) without an FPGA on which build and simulation can be done. This includes "Hardware Emulation" mode, where the application can be tested w/ FPGA behavior running as simulation. (~$0.80/hr)
  - F1 Instance: The EC2 instance with an attached FPGA, supporting the final application. (~$1.65/hr)

# Overview

> You will be charged by Amazon for the resources required to complete these steps and to use this infrastructure. Don't come cryin' to us. We are in no way responsible for your AWS charges.

<!--
Optional instructions are provided to get the Mandelbrot example application up and running on a local Linux machine without FPGA acceleration. Furthermore, to run with FPGA acceleration, prebuilt images are provided to initially bypass the lengthy builds.

As a preview of the complete process, to get the Mandelbrot application up and running from source code with FPGA acceleration, you will need to:

  - Get an AWS account with access to F1 instances. (This requires a day or two to get approval from Amazon.)
  - Launch a Development Instance on which to compile the OpenCL, Verilog, and Transaction-Level Verilog source code into an Amazon FPGA Image (AFI).
  - Launch an F1 Instance on which to run: the web server, the Host Application, and the FPGA programmed with the image you created on the Development Instance.
  - Open the FPGA-Accelerated Web Application in a web browser.
-->

F1 machines are powerful and expensive. Configured for minimal optimization, hardware compilation of a small kernel takes about an hour. These instructions assume the use of a separate Development Instance, which does not have an FPGA, to save costs. The FPGA kernel can be tested on this machine using "Hardware Emulation" mode, where the FPGA behavior is emulated using simulation and build times are minimal by comparison. For hobby projects, it is not practical to keep either EC2 Instance up and running for extended periods of time. The overhead of using two EC2 instances can sometimes result in extra cost and time of its own. So, depending upon your goals, you may prefer to simplify your life by using the F1 Instance as your Development Instance, in which case you can skip the instructions below for creating and configuring the Development Instance.

There are many tutorials on line to get started with F1. Many are flawed, unclear, or out-dated. We found this <a href="https://github.com/Xilinx/SDAccel-Tutorials/blob/master/docs/aws-getting-started/RTL/README.md" target="_blank" atom_fix="_">Xilinx tutorial</a> to be the best. We have automated many of the steps you will find in these lengthy tutorials.


