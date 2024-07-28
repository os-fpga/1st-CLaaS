<a name="top"></a>
# Getting Started with 1st CLaaS

## Overview

Getting started is easy. We'll show you a few commands to get your feet wet, test out your platform, and write your own "Hello World" application. Then you can either:

  - jump right into development with help from the [Developer's Guide](DevelopersGuide.md#top), or
  - test drive AWS F1 with [Getting Started with F1](GettingStartedF1.md#top)
  - Alternatively, if you want to setup development environment for Hardware Emulation on your compatible machine, read [Setting up Virtual Machine on Windows for Hardware Emulation](VMsetup.md)

> Note that F1 use requires approval, which can take a day or more, so you may want to do the first step of the [Developer's Guide](doc/DevelopersGuide.md#top) now, so your F1 platform will be ready when you are.


## Platform

1st CLaaS was developed on:

  - Ubuntu 16.04
  - Ubuntu 18.04
  - Centos7
  
Please help us debug other Linux/Mac platforms. If you don't have a compatible machine, you can provision a cloud machine from AWS, Digital Ocean, or other providers as your "local" machine.


## Setup

To configure your local environment, including installation of tools for AWS development, clone and cd into this repo, then:

```sh
./init   # This will require sudo password entry, and you may be asked to update your $PATH.)
```


## Running Mandelbrot Locally

![mandelbrot](http://fractalvalley.net/img?json={%22x%22:-0.9836,%22y%22:-0.279,%22pix_x%22:0.00001906,%22pix_y%22:0.00001906,%22width%22:1018,%22height%22:74,%22max_depth%22:1225,%22modes%22:66,%22renderer%22:%22cpp%22})

To run the sample Mandelbrot application locally, without an FPGA:

```sh
cd apps/mandelbrot/build
make launch
```

You should see output indicating that the application is running with `TARGET` = `sim`, and that the web server is running. The `sim` `TARGET` uses the Verilator RTL simulation tool to emulate the FPGA kernel behavior.

Open `http://localhost:8888/index.html` in a local web browser and explore Mandelbrot. You can choose for the Mandelbrot images to be rendered:

  - by the Python web server (very slowly)
  - by the C++ host application
  - in Verilator simulation of the custom RTL kernel (by selecting "FPGA")

More instructions for the Mandelbrot application are [here](../apps/mandelbrot).

Stop the web server with `<Ctrl>-C` (in the terminal window).

You'll be able to see the speedup you get from an FPGA when you get to [Getting Started with F1](GettingStartedF1.md#top).


## Running Vector Add Locally

The `vadd` example is a "hello world" example. It simply contains a custom kernel in `<repo>/apps/vadd/fpga/src/vadd_kernel.sv` that returns each value sent in, incremented by one. The rest of the application is provided by the framework. You'll run it the same way as `mandelbrot` (but we'll start the web server on a different port so your browser isn't tempted to provide a cached mandelbrot page).

```sh
cd <repo>/apps/vadd/build
make launch PORT=8000
```

Open `http://localhost:8000/index.html`.

`vadd` uses a default web client that allows you to send raw data through the server to the custom kernel. Click send, and you'll see that the kernel returns data where each value has been incremented by 1 by the RTL kernel.

Stop the web server wth `<CTRL>-C`.


<a name="CustomApp"></a>
## Making Your Own Application

Now you are ready to make an simple application of your own.

`vadd` is a good starting point. We've provided a command to copy an application and update the application name throughout the copy.

```sh
cd <repo>/apps/vadd/build
make copy_app APP_NAME=toy
```


### Web Client Application

The web client is defined by the HTML, CSS, and JS content in `<repo>/apps/toy/client/`. In this case `<repo>/apps/toy/client/html/index.html` simply links to `<repo>/framework/client/html/testbench.html` to utilize the default test bench provided by the framework that you accessed for `vadd`. If you would like to modify the web client code, you can copy `<repo>/framework/client/*/testbench.*` into `<repo>/apps/toy/client` as a simple starting point. To develop a real application, you may have your own thoughts about the framework you would like to use. You can use what you like. Develop in a separate repo, or keep it in the same repo so it is consistently version controlled.


### Custom Kernel

The vadd kernel is a good starting point for your own kernel. Though we strongly recommend using TL-Verilog, this kernel is written in SystemVerilog, which is currently more broadly familiar. If you'd like to try TL-Verilog:

```sh
cd <repo>/apps/toy/fpga/src
cp tlv_varients/toy_kernel.tlv.disabled toy_kernel.tlv
```

We'll add some [TL-Verilog Tutorials](TLV_Tutorials.md#top).

Modify the kernel code as desired. Try subtraction or anything you like.


### Run

Build and run as before:

```sh
cd <repo>/apps/toy/build
make launch
```

The client can be modified without relaunching. Just do a forced reload in your browser (`<Ctrl>-F5` in Chrome and Firefox). Browser debug tools are quite useful: (`<Ctrl><Shift>-J` in Chrome and Firefox).


### C++ Host Application

It is not required to customize the host application, but if you would like to do so, you can override the one from the framework, following the example of the Mandelbrot application. (Refer to its `Makefile` as well as `/host` code.)


### Python Web Server

It is not required to customize the Python web server, but if you would like to do so, you can override the one from the framework, following the example of the Mandelbrot application. (Refer to its `Makefile` as well as `/webserver` code.)


## Next Steps

Now that you've got your feet wet, either:

  - continue development with help from the [Developer's Guide](DevelopersGuide.md#top), or
  - test drive AWS F1 with [Getting Started with F1](GettingStartedF1.md#top)
