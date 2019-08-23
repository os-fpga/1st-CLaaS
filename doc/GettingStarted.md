# Getting Started with 1st CLaaS

# Overview

Getting started is easy. We'll show you a few commands to build and run the sample applications, and then you can

  - jump right into development with help from the [Developer's Guide](doc/DevelopersGuide.md), or
  - test drive AWS F1 with [Getting Started with F1](doc/GettingStartedF1.md)

> Note that F1 use requires approval, which can take a day or more, so you may want to do the first step of the [Developer's Guide](doc/DevelopersGuide.md) now, and your F1 platform will be ready when you are.

<!--
These instructions use the Mandelbrot example application to get you up to speed using 1st CLaaS on AWS infrastructure. It is important to walk through all of these steps to get properly set up for development, to become familiar with the framework, and to uncover any issues before creating your own project. You will step through:

  - [Running Locally](#RunningLocally)

Once you have completed these instructions, you can:
-->


## Platform

1st CLaaS was developed on:

  - Ubuntu 16.04
  - Ubuntu 18.04
  - Centos7
  
Please help us debug other Linux/Mac platforms. If you don't have a compatible machine, you can provision a cloud machine from AWS, Digital Ocean, or other providers as your "local" machine.


## Setup


To configure your local environment, including installation of Python, AWS CLI, Terraform, Remmina, and other packages:

```sh
cd <wherever you would like to work>
git clone https://github.com/alessandrocomodi/fpga-webserver
cd fpga-webserver
source ./init   # This will require sudo password entry, and you may be asked to update your $PATH.)
```


## Running Mandelbrot Locally

To run the sample Mandelbrot application locally, without an FPGA:

```sh
cd apps/mandelbrot/build
make launch
```

You should see that the application is running with "TARGET" = "sim", meaning Verilator RTL simulation is emulating the FPGA kernel behavior. And, you should see a message that the web server is running.

You can open `http://localhost:8888/index.html` in a local web browser and explore Mandelbrot. You can choose for the Mandelbrot images to be rendered:

  - by the Python web server
  - by the C++ host application
  - in Verilator simulation of the custom RTL kernel (by selecting "FPGA")

More instructions for the Mandelbrot application are [here](apps/mandelbrot).

Stop the web server with `<Ctrl>-C` (in the terminal window).

If you'd like to see the speedup you get from an FPGA, you can proceed to [Getting Started with F1](doc/GettingStartedF1.md).


## Running Vector Add Locally

The `vadd` example is a "hello world" example. You'll run it the same way as `mandelbrot`, but we'll start the web server on a different port so your browser isn't tempted to provide a cached mandelbrot page.

```sh
cd <repo>/apps/vadd/build
make launch PORT=8000
```

Open `http://localhost:8000/index.html`.

`vadd` uses a default web client that allows you to send raw data through the server to the custom kernel. Click send, and you'll see that the kernel returns data where each value has been incremented by 1.

Stop the web server wth `<CTRL>-C`.


<a name="CustomApp"></a>
## Making Your Own Application

Now you are ready to make an application of your own. This section is not a cookbook, but rather some pointers to get you started down your own path.

```sh
cd ~/workdisk/fpga-webserver/apps
cp -r vadd <your-proj>
```

The app name (`vadd`) is reflected in several filenames and in files for clarity, so change these to <your-proj>.


## Web Client Application

For a simple quick-and-dirty application or testbench for your kernel, you might use the existing structure to write some basic HTML, CSS, and JavaScript. If you intend to develop a real application, you probably have your own thoughts about the framework you would like to use. You can develop in a separate repo, or keep it in the same repo so it is consistently version controlled.


# Custom Kernel

The vadd kernel is a good starting point for your own kernel. It is written using TL-Verilog. A pure Verilog version is also available.


# C++ Host Application

It is not required to customize the host application, but if you need to do so, you can override the one from the framework, following the example of the mandelbrot application. (Refer to its Makefile as well as `/host` code.)


# Python Web Server

It is not required to customize the python web server, bit if you need to do so, you can overrie the one from the framewoek, following the example of the manelbrot application. (Refer to its Makefile as well as `/webserver` code.)
