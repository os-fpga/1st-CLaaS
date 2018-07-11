# FPGA-Webserver Overview

This project provides a communication layer between web applications and Cloud FPGA accelerators in order to enhance the performance of compute-intensive tasks. Further documentation for this project, including the project vision, can be found in this [Google Drive Folder](https://drive.google.com/drive/folders/1EdhyuvQmIN18YxHsRkTGffVvuAwmHfkJ?usp=sharing). This project utilizes Amazon AWS F1 instances and the corresponding Xilinx tools (Vivado, SDAccel).

This repository contains the generic framework as well as sample applications that utilize the framework.

# Status

While the layer is intended to be generic, in its current form, this repo contains both generic functionality and components that are specific to the initial demonstration application -- a Mandelbrot image generator.


# Project description

A hardware accelerated web application utilizing this framework consists of:
  - Web Client: a web application, or any other agent communicating with the accelerated server via web protocols.
  - Web Server: a web server written in Python
  - Host Application: the host application written in C/C++/OpenCL which interfaces with the hardware.

The WebSocket or REST communication between the Web Application and the FPGA passes through:
  1. The Web Client application, written in JavaScript running in a web browser, transmits JSON (for now), via WebSocket or GET, to the Web Server. The communication is currently simple commands containing:
      1. type: describes the command that has to be performed by the host application and dispatched to the FPGA;
      1. data: a data value to be sent to the FPGA.
  1. The Web Server, a Python web server, echoes commands via UNIX socket to the Host Application.
  1. The Host Application, written in C/C++/OpenCL, transmits the commands to the FPGA Shell through OpenCL calls.
  1. The FPGA Shell, written in Verilog and configured by scripts, communicates between memory and the Custom Kernel via AXI and FIFOs.
  1. The Custom Kernel, provided as Verilog, and for Mandelbrot written in TL-Verilog, processes the data stream from the FPGA Shell and produces a data stream returned to the FPGA Shell
  1. The FPGA Shell transmits the data stream to the Host Application. For Mandelbrot, this data is depth values for each pixel.
  1. The Host Application, for Mandelbrot, processes pixel depths into colors, and into a `.png` data stream, which is returned over the UNIX socket to the Web Server.
  1. The Web Server echoes the data stream to the client via the WebSocket or as a GET response.
  1. The Web Cient displays the image.


# Directory Structure

  - `framework`: The generic infrastructure for hardware-accelerated web applications.
    - `client`: Client library.
    - `webserver`: Python web server application.
    - `host`: OpenCL/C++ host application framework.
    - `fpga`: FPGA framework, including Verilog/TLV source code.
    - `f1`: Specific to Amazon F1.
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
    - `echo`: A template application that simply echoes data on a websocket
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


# Project Setup Overview

Setup for AWS F1 and building from scratch is a very lengthy process. Optional instructions are provided to get the Mandelbrot application up and running on a local Linux machine without FPGA acceleration. Furthermore, to run with FPGA acceleration, prebuilt images are provided to initially bypass the lengthy builds.

As a preview of the complete process, to get up and running from source code with FPGA acceleration, you will need to:
  - Get an AWS account with access to F1 instances. This is a lengthy process requiring a few days to get approval from Amazon.
  - Launch a "Build Instance" on which to compile the OpenCL, Verilog, and Transaction-Level Verilog source code into an FPGA image.
  - Launch an "F1 Server Instance" on which to run: the web server, the Host Application, and the FPGA programmed with the image you created on the Build Instance.
  - Open the Web Application in a local web browser (or host it on a web server) and connect to the running Web Server.

(Keep in mind, there is a far more substantial world of hurt that this infrastructure is saving you.)

Note that F1 machines are powerful and expensive. Compilations take several hours and require a sizable Build Instance which can cost a few dollars per compilation. F1 machines cost about $1.50/hr, so it is not practical to keep a server up and running for extended periods.


# AWS Account Setup with F1 Access

Instructions can be found <a href="https://github.com/aws/aws-fpga/blob/master/SDAccel/README.md#iss" target="_ blank">here</a>.

If you are new to AWS, you might find it to be quite complicated. Here are some specific steps to get you going, though they likely need refinement. Be sure to correct these docs based on your experience.
  - Create a <a href="https://aws.amazon.com/free/" target="_ blank">free tier account</a> and await approval.
  - Login to your console. Be sure you are logging in as root, not as an IAM user. (Your account has no "IAM" users until you create them (which is not necessary to get going).)
  - Now, you'll need access to F1 resources (and possibly the Amazon Machine Image (AMI) for the Build Instance). Unless policies change, you must apply for this. You can try skipping ahead to confirm.
    - Under "Support" (upper left) open "Support Center".
    - Create a case.
      - Regarding: "Service Limit Increase".
      - Limit Type: "EC2 Instances"
      - Region: "N. Virginia" (and possibly other options)
      - Primary Instance Type: "f1.2xlarge"
      - Use Case Description: Something like, "Development of hardware-accelerated web applications using this framework (https://github.com/alessandrocomodi/fpga-webserver)"
      - Wait ~2 business days :(

        
# Running Mandelbrot Locally

While you wait for F1 access, you can play around with the Mandelbrot example without hardware acceleration.

On a Linux machine:
```sh
cd <wherever you would like to work>
git clone https://github.com/alessandrocomodi/fpga-webserver
cd apps/mandelbrot/build
make launch
```


# F1 Instance Setup

Now let's provision an F1 Instance.
  - From the dashboard, click "Launch Instance".
  - Click "AWS Marketplace" on the left.
  - Enter "FPGA" in the search box.
  - "Continue".
  - Select f1.2xlarge (in "North Virginia").
  - Click through default options to launch.
  - (SSH key instructions here)
  - `chmod 600 ~/.ssh/AWS_<my_machine>.pem`
  - Click new instance link to find IP address.
  - You can view your instances from the left panel. Go to your EC2 Dashboard and clicking "Running Instances" or under "Instances", select "Instances". From here, you can, among other things, start and
  stop your instances ("Actions", "Instance State"). Be sure not to accidentally leave them running!!! You should configure monitoring of your resources, but the options are very limited for catching instances you fail to stop. Also be warned that stopping an instance can fail. Be sure your instance transitions to "stopped" state (or Amazon tells me charging stops at "stopping" state).
  - Log into your instance: `ssh -i ~/.ssh/<AWS_my_machine>.pem centos@<ip>`

If all went well, you are now logged into your F1 Instance.

The AWS F1 instance has to allow TCP connections on port 8888 (or the one you choose to serve the GET or WebSocket requests):
  1. Go to the EC2 Dashboard.
  1. On the left, under "Network & Security", click on "Security Group".
  1. Select the one related to your F1 instance.
  1. Go to the "Inbound" tab and click on "Edit".
  1. "Add".
  1. Select "Custom TCP Rule" as "Type" and insert "8888" as port range.
  1. Provide "Source" as the IP from which you will launch your client, or leave it as zeros to allow any IP to connect.
  1. You can set "Description" to "webserver".
  1. Save


# Running on FPGA

Prebuilt files are included in the repository. Try to run using those first, so you can see the FPGA in acction.

```sh
cd
git clone https://github.com/alessandrocomodi/fpga-webserver
cd ~/fpga-webserver/apps/mandlebrot/build
make PREBUILT=true launch
```

Point a web browser at `http://<IP>:8888` and play with the application.

When you are done, <ctrl-c>, `exit`, and stop your instance.


# Build Instance Setup

You can build on your F1 instance, but building takes a long time, and its cheaper to build on a machine that does not have the FPGA.

Provision a build instance as you did the F1 Instance, but use instance type "c4.4xlarge" (as recommended by Amazon, or we have found "c4.2xlarge" to suffice, though it's slower). `ssh` into this instance. It wouldn't hurt to open port 8888 on this instance as well in case you want to test on this instance without the FPGA.


# Building from Source

Now, build both the FPGA image and host application.

## FPGA Build

First, clone this GitHub repository and the aws-fpga GitHub repository and source the sdaccel_setup.sh script.

```sh
cd
git clone https://github.com/alessandrocomodi/fpga-webserver
git clone https://github.com/aws/aws-fpga.git $AWS_FPGA_REPO_DIR  
cd $AWS_FPGA_REPO_DIR
source ./sdaccel_setup.sh
```

OLD INSTRUCTIONS:

Once the environment is set up copy the `apps/mandelbrot/fpga` folder into your workspace and build:

```sh
cd
mkdir work
cd work
cp -r ~/fpga-webserver/apps/mandelbrot/fpga .
cd mandelbrot_hw/sdx_imports
make build TARGET=hw KERNEL=mandelbrot -j8 > out.txt &
```

NEW INSTRUCTIONS to try:

```sh
cd ~/fpga-webserver/apps/mandelbrot/build
make build TARGET=hw KERNEL=mandelbrot -j8 ../out/out.log &
```

Once the build process is complete you'll have a host application and an Amazon FPGA Image (AFI) that the host application will load onto the FPGA.
You'll need to get these files to your F1 instance. You can do this through an S3 Bucket.

AWS CLI configuration:

Configure by providing your credentials. These can be found in in the Security Credentials page, which I'm not sure how to navigate to, but here's a <a href="https://console.aws.amazon.com/iam/home?#/security_credential" target="_ blank">direct link</a>.

Use region: `us-east-1` and output: `json`.

```sh
aws configure
```

S3 Bucket creation:

```sh
aws s3 mb s3://<bucket-name> --region us-east-1  # Create an S3 bucket (choose a unique bucket name)
aws s3 mb s3://<bucket-name>/<dcp-folder-name>   # Create folder for your tarball files
touch FILES_GO_HERE.txt                          # Create a temp file
aws s3 cp FILES_GO_HERE.txt s3://<bucket-name>/<dcp-folder-name>/  # Which creates the folder on S3
rm FILES_GO_HERE.txt  # cleanup
```

Once the setup is complete you can generate the .awsxclbin binary file that will configure the FPGA:

```sh
cd ~/work
mkdir build
cd build
$SDACCEL_DIR/tools/create_sdaccel_afi.sh -xclbin=../fpga/sdx_imports/hw/xilinx_aws-vu9p-f1_4ddr-xpr-2pr_4.0/mandelbrot.xclbin -o=mandelbrot \
    -s3_bucket=<bucket-name> -s3_dcp_key=<dcp-folder-name> -s3_logs_key=<logs-folder-name>
```

When the process completes you will have the bitstream configuration file ready to use.


## Host Application compilation

The host program is needed to interface with the FPGA.
Copy all files from the "host_app" folder into a new one and run the following command:

```sh
cd ~/work
cp -r ../fpga-webserver/srcs/host_app .
cd host_app
make host TARGET=hw_emu KERNEL=mandelbrot
```

This will compile the host application and you can find the executable in the `hw_emu/xilinx_aws-vu9p-f1_4ddr-xpr-2pr_4.0/` folder.

## Bundle Result Files

Now, you have all the files you will need to run the F1 web server on an F1 Instance. First, bundle the files that you will
need on that server and store them in your S3 bucket, in a new key, called "deploy". The files include: the python files found in the `web_server` folder,
the executable and the `.awsxclbin` image

```sh
cd ~/work
mkdir deploy
cp -r ~/fpga-webserver/srcs/web_server/* .
cp ~/work/host_app/hw_emu/xilinx_aws-vu9p-f1_4ddr-xpr-2pr_4.0/host .
cp ~/work/build/mandelbrot.awsxclbin .
aws s3 mb s3://stevehoover-afi-bucket/deploy
aws s3 cp --recursive ./deploy s3://<bucket>/deploy
```

## File Transfer to F1

Transfer the "deploy" files to your F1 machine.

`ssh` into your F1 machine, as you did your Build Instance.

Configure, as before using your access keys, and region: `us-east-1` and output: `json`.

```sh
aws configure
```

Copy "deploy" files from your S3 bucket.

```sh
mkdir ~/deploy
cd ~/deploy
aws s3 cp --recursive s3://<bucket>/deploy .
chmod +x ./host  # Seems to lose execute permission along the way.
```

## Web Server usage

Now, you can run the server and the host application. We'll do so from two different terminals.

Run the host application (with a listening socket):
Run:

```sh
cd /home/centos/deploy
sudo sh
source /opt/Xilinx/SDx/2017.1.rte.4ddr/setup.sh   # Use 2017.1.rte.1ddr or 2017.1.rte.4ddr_debug when using AWS_PLATFORM_1DDR or AWS_PLATFORM_4DDR_DEBUG. Other runtime env settings needed by the host app should be setup after this step
./host mandelbrot.awsxclbin mandelbrot
```
  
`ssh` in from the second terminal (for the web server).

The webserver is written in Python. You'll need the following prerequisites:
  - Python 2.7 or higher;
  - tornado python library
  ```sh
  sudo pip install tornado
  ```

Run the WebServer:

```sh
cd ~/deploy
sudo python2.7 server.py
```

You can access client.html from any web browser using `http://<IP>:8888/client.html`.

Current usage of client.html requires: host IP, click "Open", click "Init FPGA", enter coords, like 0, 0, zoom: 1, depth 100, "GET IMAGE" or "Start".

You can run the Mandelbrot explorer from any web browser using `http://<IP>;8888/index.html`.


# Makerchip and TL-Verilog

The Mandelbrot set accelerator has been developed in the [Makerchip](https://makerchip.com/) IDE using the TL-Verilog language extension.
After the kernel has been designed in Makerchip we retrieved the Verilog files by clicking on "E" -> "Open Results" in the Editor tab. From the new browser tab the files that host the Verilog code are called "top.sv" and "top_gen.sv".
The content of these files has to be copied and pasted inside of the file "mandelbrot_example_adder.sv" found in the "fpga/imports" folder.


# X11 Forwarding

It's important to be able to run X11 applications on your instance and display them on your machine. Unfortunately I got a `DISPLAY not set` message when first trying `ssh -X`. I was able to get this to work with help from <a href="https://forums.aws.amazon.com/thread.jspa?messageID=574740" target="_ blank">this post</a> though I'm not sure exactly what did the trick.


# To Do

Make instructions more explicit, as a cookbook recipe, and provide information and pointers about the more general use of the commands. After this provide other helpful general information about working with the design. New users should walk through the cookbook as quickly as possible, then learn more about what they have done.
  - Incorporate web_server/launch command into instructions.
  - First launch just web server, then web server + host app, then web server + host app + FPGA.
  - Choose specific file/folder names, and stick with them.
  - Create small scripts to further automate. Scripts should be useful in production use, not just for cookbook, otherwise we're hiding useful information.
  - Probably want to use workspace folders inside this with .gitignored contents, so this repo can provide work structure.
  - Structure the repo to support multiple examples, where mandelbrot is one.
  - Automate export from Makerchip by providing a script that uses `curl` to access result files via `http://makerchip.com/compile/<compile-id>/results/<filename>`.
