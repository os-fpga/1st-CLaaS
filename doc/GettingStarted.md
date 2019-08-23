# Getting Started with 1st CLaaS

# Overview

These instructions use the Mandelbrot example application to get you up to speed using 1st CLaaS on AWS infrastructure. It is important to walk through all of these steps to get properly set up for development, to become familiar with the framework, and to uncover any issues before creating your own project. You will step through:

  - [Running Locally](#RunningLocally)

Once you have completed these instructions, you can:

  - jump right into development with help from the [Developer's Guide](doc/DevelopersGuide.md), or
  - test drive AWS F1 with [Getting Started with F1](doc/GettingStartedF1.md)

Note that F1 use requires approval, which can take a day or more, so you may want to do that first step of the [Developer's Guide](doc/DevelopersGuide.md) now.



<a name="RunningLocally"></a>
# Running Mandelbrot Locally


First, you'll need a compatible local machine. We use Ubuntu 16.04. Please help to debug other platforms. If you do not have a compatible Linux (or Mac?) machine, you can provision a cloud machine from AWS, Digital Ocean, or other providers as your "local" machine.

To configure your local environment, including installation of Python, AWS CLI, Terraform, Remmina, and other packages:

```sh
cd <wherever you would like to work>
git clone https://github.com/alessandrocomodi/fpga-webserver
cd fpga-webserver
source ./init   # This will require sudo password entry, and you may be asked to update your $PATH.)
```

And to run the Mandelbrot application locally, without an FPGA:

```sh
cd apps/mandelbrot/build
make launch
```

You should see a message that the web server is running. You can open `http://localhost:8888/index.html` in a local web browser and explore Mandelbrot generated in the Python web server or in the C++ host application.

More instructions for the Mandelbrot application are [here](apps/mandelbrot).


