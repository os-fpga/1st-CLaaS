# FPGA-Webserver Overview

The availability of FPGAs in the data center/cloud enables very exciting compute models for accelerated, distributed applications. Prior to this project, developing such an application required a full-stack developer, a software engineer, a domain expert, an IaaS expert, and a hardware designer. This project aims to make cloud FPGAs much more accessible for students, start-ups, and everyone.

This project provides the communication layer that enables web applications or distributed cloud applications to exchange data with custom hardware logic running on FPGAs in the data center using standard web protocols. Developers need only provide the web application and the hardware kernel and need not worry about how the bits get from one to the other. If desired, modifications can be made to the webserver and/or C++ application through which data passes, but in the simplest scenario, this is not necessary.

This project currently focuses on utilizing Amazon's F1 FPGA instances. These are very powerful FPGA instances, and having access to this power using a pay-per-use model is compelling. Unfortunately, they are bleeding edge and require significant expertise to utilize. In our experience, documentation is often wrong as APIs and infrastructure are evolving. Developers must have a deep understanding of hardware design. They must be familiar with Xilinx tools: Viviado for RTL design and SDAccel to interface the hardware with C++ code using OpenCL. They must understand AXI protocols and manage AXI controllers. And the AWS platform can be intimidating to a newcomer. In addition to hiding most of this complexity, this framework provides the webserver and host application code that hide the implementation of passing data from client to and from the FPGA.

Further documentation for the project vision, can be found in this <a href="https://drive.google.com/drive/folders/1EdhyuvQmIN18YxHsRkTGffVvuAwmHfkJ?usp=sharing" target="_ blank">Google Drive Folder</a>.

Here's a short <a href="https://drive.google.com/open?id=1TAUxoCZ3SQpYha5HjXYNDSqQsSvG_ejD" target="_ blank">invited talk</a>  at VSDOpen 2018 about cloud FPGAs and the impact they will have on open-source hardware and the silicon industry as a whole that is good context and motivation for this project.

This repository contains all that is needed to develop a hardware-accelerated web application, including the generic framework and sample applications that utilize the framework. It contains content for local development as well as for building FPGA images on the remote F1 machine, so it is to be forked and cloned locally and remotely with different parts edited on each machine.

# Status

This repository is a work-in-progress. Further development is funded for the summer of 2019 through <a href="https://summerofcode.withgoogle.com/dashboard/project/6298628153409536/overview/" target="_blank">Google Summer of Code</a>. A working <a href="https://github.com/alessandrocomodi/fpga-webserver/tree/master/apps/mandelbrot" target="_ blank">Mandelbrot explorer</a> is included. This demo is hosted at <a href="http://fractalvalley.net" target="_blank">FractalValley.net</a>.


# Project description

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


# Project Setup Overview

Setup for AWS F1 and building from scratch is a very lengthy process. Optional instructions are provided to get the Mandelbrot application up and running on a local Linux machine without FPGA acceleration. Furthermore, to run with FPGA acceleration, prebuilt images are provided to initially bypass the lengthy builds.

As a preview of the complete process, to get up and running from source code with FPGA acceleration, you will need to:

  - Get an AWS account with access to F1 instances. This requires a day or two to get approval from Amazon.
  - Launch and configure a "Build Instance" on which to compile the OpenCL, Verilog, and Transaction-Level Verilog source code into an Amazon FPGA Image (AFI).
  - Launch and configure an "F1 Server Instance" on which to run: the web server, the Host Application, and the FPGA programmed with the image you created on the Build Instance.
  - Open the Web Application in a local web browser (or host it on a web server) and connect to the running Web Server.

(Keep in mind, dispite the length of these instructions (and the ones they reference) there is a far more substantial world of hurt that this infrastructure is saving you.)

Note that F1 machines are powerful and expensive. Compilations take several hours and require a sizable Build Instance which can cost a few dollars per compilation. F1 machines cost about $1.65/hr, so it is not practical to keep a server up and running for extended periods for hobby projects.


# AWS Account Setup with F1 Access

There are many similar tutorials on line to get started with F1. Many are flawed or unclear. In our experience Xilinx instructions are generally better than those from AWS. I found the "Prerequisites" instructions of <a href="https://github.com/Xilinx/SDAccel-Tutorials/blob/master/docs/aws-getting-started/RTL/README.md" target="_ blank">this tutorial</a> to be the best starting point, but before starting, note the following:

  - When choosing a name for your S3 bucket (in step 3 of these instructions), consider who might be sharing this bucket with you. It makes sense to create a separate bucket for each fpga-webserver project you work on. You might share this bucket with your collaborators. The bucket name should reflect your project. You might wish to use the name of your git repository, or the name of your organization, i.e. `fpga-webserver-zcorp`. If you expect to be the sole developer, you can reflect your name (perhaps your AWS username) in the bucket name and avoid the need for a `/<username>` subdirectory.
  - The subdirectories you will use are: `/<username>` if your username is not reflected in your bucket name, and within that (if created), `/dcp`, `/log`, and `/xfer`.

Okay, now, <a href="https://github.com/Xilinx/SDAccel-Tutorials/blob/master/docs/aws-getting-started/PREREQUISITES/README.md" target="_ blank">do these prerequisits</a>.

# Running Mandelbrot Locally

There is a great deal of setup you can do while you wait for F1 access. First, if you have access to a Ubuntu machine (or care to try your luck with an untested platform or provision a Ubuntu machine via Digital Ocean or similar cloud provider), you can play around with the Mandelbrot example without hardware acceleration.

On a Ubuntu (16.04 in my case) machine:
```sh
sudo apt-get update
sudo apt-get install make g++ python python-pip python-pil python-tornado
# On centos: sudo yum install make g++ python python-pip python-pillow python-tornado (unconfirmed)
cd <wherever you would like to work>
git clone https://github.com/alessandrocomodi/fpga-webserver
cd fpga-webserver
git submodule update --init --recursive  # or ./init
cd apps/mandelbrot/build
make launch
```

The webserver is running. You can open `http://localhost:8888/index.html` in a local web browser and explore Mandelbrot generated in the Python webserver or in the C++ host application.

You can also open `http://localhost:8888/client.html`. Click "Open", click "Init FPGA", enter coords, like 0, 0, zoom: 1, depth 100, "GET IMAGE" or "Start" for a flythrough.

More instructions for the Mandelbrot application are [here](https://github.com/alessandrocomodi/fpga-webserver/tree/master/apps/mandelbrot).


# Create Build Instance

Now let's provision a Build Instance. Continue with the next section of the Xilinx tutorial: <a href="https://github.com/Xilinx/SDAccel-Tutorials/blob/master/docs/aws-getting-started/RTL/README.md" target="_ blank">Create, configure, and test an AWS F1 instance</a>, at least for the "Create" part (section 1), noting a few things first. These instruction configure an F1 machine, but you will first configure a Build Instance without the FPGA (in case you are still waiting for F1 approval). You'll repeat these instructions later for the F1 Instance. As you step through the tabs of the instance creation process in AWS, perform the following additional steps:

  - In "Step 2. Choose an Instance Type" (Step3 of the tutorial instructions): Since we are creating the build instance first, select "c4.2xlarge" instead of "f1.2xlarge" on your first pass through these instructions.
  - In "Step 4. Add Storage" (Step 4.2. of the tutorial instructions): I found the default 5GB of Elastic Block Storage to be rather limited for doing anything more than just the tutorial. I would consider 8GB to be a minimum to support development and 12GB to be practical. (For the F1 Instance, assuming you will do most development on the Build Instance, 8GB is probably sufficient.)
  - In "Step 6. Configure Security Group" (Step 5 of the tutorial instructions): after opening the RDP (Remote Desktop Protocol) port, open additional ports to make the Web Server accessible from outside. Under "Inbound":

    - "Add Rule"
    - For "Type" select "Custom TCP Rule" (should be the default), and enter "8880-8889" as port range (by default, we will use port 8888, but let's reserve several).
    - Select or enter a "Source", e.g. "Anywhere" or your IP address for better security.
    - Set "Description", e.g. "development-webserver".
    - For remote desktop, I have had issues with both RDP and VNC. (More on that below.) If you wish to be able to use VNC (from linux), also open up ports 5901-5910.

Note that you can also make configuration changes after creating and launching the instance. Instances can be controlled via the EC2 Dashboard under "Resources", "Running Instances". To open new ports, scroll right (if necessary) and select the security group for your instance. You will use the "Running Instances" page frequently to start and stop your instances (by selecting the instance(s) and setting their state via "Actions", "Instance State").

You can also name your instance, which would be a good thing to do now by clicking the pencil icon, and entering a name, like `fpga-webserver-run-1`.

Be sure not to accidentally leave instances running!!! You should configure monitoring of your resources, but the options seem very limited for catching instances you fail to stop. Also be warned that stopping an instance can fail. I have found it important to always refresh the page before changing machine state. And, be sure your instance transitions to "stopped" state (or, according to AWS support, charging stops at "stopping" state).

## Remote Desktop

For remote desktop access to the EC2 machines, I have used X11, RDP, and VNC from a Linux client. X11 easiest, but it is far too slow to be practical. RDP and VNC required several days to get working. They are usable, but neither has been ideal for me. RDP has a strange issue where dark pixel colors have transparency to windows behind them. With VNC I experienced periodic stalls of several seconds at a time (which may have something to do with my client machine).

### X11 Forwarding

This is easy and stable, so even though it is not a solution for running Xilinx tool long-term, start with X11. You will probably get a `DISPLAY not set` message when first trying X forwarding with `ssh -X` and running an X application. I was able to fix this with:

```sh
ssh -X -i <AWS key pairs.pem> centos@<ip>
sudo yum install xeyes -y   # Just a GUI application to test X11.
xeyes   # You'll probably see a "Display not set" error.
sudo yum install xorg-x11-xauth
exit
ssh -X -i <AWS key pairs.pem> centos@<ip>
xeyes  # Hopefully, you see some eyes now.
```

### RDP

For RDP, I followed instructions <a href="https://github.com/Xilinx/SDAccel-Tutorials/blob/master/docs/aws-getting-started/RTL/STEP1.md#2-connecting-to-the-instance-with-a-remote-desktop-client" target="_blank">here</a> (just Step 2). I encountered the following issues:

  - The `curl`ed script produced an error that `/usr/src/kernels/3.10.0-957.10.1.el7.x86_64` couldn't be found. I changed the link to point to `/usr/src/kernels/3.10.0-862.11.6.el7.x86_64`.
  
  - I was unable to connect from Linux and Windows 7 (for which support ends in Jan. 2020, so stop using it). I found the following fix.

  ```sh
  sudo cp /etc/xrdp/xrdp.ini /etc/xrdp/xrdp.ini.bak  # create a backup
  sudo sed -i s/security_layer=negotiate/security_layer=rdp/ /etc/xrdp/xrdp.ini  # change "security_layer"
  sudo diff /etc/xrdp/xrdp.ini /etc/xrdp/xrdp.ini.bak  # just to see that something changed
  ```

### RDP Desktop (DELETE ME if the above works)

(I first tried following an [AWS tutorial from Reinvent 2017](https://github.com/awslabs/aws-fpga-app-notes/tree/master/reInvent17_Developer_Workshop) that used RDP, but I was unsuccessful. (Note, that participants were provided a custom AMI to start from.))

In case it helps to debug issues, or in case you need to connect from Windows, this is what I did following the Reinvent 2017 instructions:

In place of:
```sh
source <(curl -s https://s3.amazonaws.com/aws-ec2-f1-reinvent-17/setup_script/setup_reinvent.sh)
```

I extracted the following commands:
```sh
sudo yum install -y kernel-devel # Needed to re-build ENA driver
sudo yum groupinstall -y "Server with GUI"
sudo systemctl set-default graphical.target

sudo yum -y install epel-release
sudo rpm -Uvh http://li.nux.ro/download/nux/dextop/el7/x86_64/nux-dextop-release-0-5.el7.nux.noarch.rpm
sudo yum install -y xrdp tigervnc-server
sudo yum install -y chromium
sudo systemctl start xrdp
sudo systemctl enable xrdp
sudo systemctl disable firewalld  # Probably non-existent
sudo systemctl stop firewalld     #  "
```

And I attepted to connect using Remmina from my Ubuntu machine without success.


### VNC from Linux Client

After much struggling, I was able to get VNC working with the Xfce desktop environment.

On the EC2 Instance:

```sh
sudo yum install tigervnc-server
vncpasswd  # Provide password for VNC desktop (and, optionally, a different password for view-only access)
```

```sh
sudo yum install -y epel-release  # (should already be installed)
sudo yum groupinstall -y "Xfce"
```
(I do not think a reboot is necessary.)

Edit ~/.vnc/xstartup to contain:

```sh
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
/etc/X11/xinit/xinitrc
[ -x /etc/vnc/xstartup ] && exec /etc/vnc/xstartup
[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources
vncconfig -iconic &
#xterm -geometry 80x24+10+10 -ls -title "$VNCDESKTOP Desktop" &
startxfce4 &
```

And make it executable:

```sh
chmod +x ~/.vnc/xstartup
```

The VNC Server can be started with:

```sh
vncserver  # Optionally -geometry XXXXxYYYY.
```

The output of this command indicates a log file. You should take a look. I got a number of warnings and a DBus permission error, but they did not appear to be fatal.

And kill with:
```sh
vncserver -kill :1
```

Any number of clients can be connected to this server while it is running. Closing the client connection does not terminate the server.

The script `vnc_ec2` (at the top level of the repo) can be used to connect:

```sh
vnc_ec2 -gXXXXxYYYY <IP>   # where -g is the VNC --geometry argument specifying desktop size.
```


Or, to use the command line, I defined:

```sh
alias vnc_ec2="vncviewer $1 passwd=<home>/.vnc/passwd"
```

and use this as:

```sh
vnc_ec2 <IP>:1
```

# Running on FPGA

Prebuilt files are included in the repository. Try to run using those first, so you can see the FPGA in action.

```sh
cd
git clone https://github.com/alessandrocomodi/fpga-webserver
cd fpga-webserver
git submodule update --init --recursive  # or ./init
cd apps/mandelbrot/build
make PREBUILT=true TARGET=hw KERNEL=mandelbrot launch
```

Point a web browser at `http://<IP>:8888` and play with the application.

When you are done, _`ctrl-C`_, `exit`, and stop your instance.


# One-Time Instance Setup

Log into your instance:

```sh
ssh -i <AWS key pairs.pem> centos@<ip>`
```

## S3 Storage

We will share files between instances using Amazon S3 through folders of the form `s3://<bucket-name>[/<unique-username>]/<kernel-name>`. If your bucket is to be shared by multiple users, you should choose a `<unique-username>`, such as your Amazon IAM username.

Configure your `.bashrc` for your bucket and username:

```sh
echo 'export S3_BUCKET=<bucket-name>' >> ~/.bashrc
echo 'export S3_USER=<unique-username>' >> ~/.bashrc   # Exclude this if the bucket is for a single user.
source ~/.bashrc
```

These settings are recognized by the Makefile. Use the same bucket name and user name for all your instances.

## Workdisk

Because disk space is limited, unlike other instructions online, I chose to use the ESB disk for my work:

```sh
ln -s /home/centos/src/project_data workdisk
cd ~/workdisk
```

## AWS CLI Configuration

Configure by providing your credentials. These can be found in in the Security Credentials page, which I'm not sure how to navigate to, but here's a <a href="https://console.aws.amazon.com/iam/home?#/security_credential" target="_ blank">direct link</a>.

Use region: `us-east-1` and output: `json`.

```sh
aws configure
```

## SSH keys

If you happen to be using private git repositories or need passwordless authentication from your instance for any other reason, you may need to generate ssh access keys for your instance.

```sh
ssh-keygen -o -t rsa -b 4096 -C "<machine-identifying comment>"
sudo yum install xclip
xclip -sel clip < ~/.ssh/id_rsa.pub
```

And paste this SSH key into the settings of your other account (e.g. gitlab).

## Clone Necessary Repos

```sh
cd ~/workdisk
git clone https://github.com/aws/aws-fpga.git $AWS_FPGA_REPO_DIR
git clone https://github.com/alessandrocomodi/fpga-webserver
cd fpga-webserver
git submodule update --init --recursive  # or ./init
```


# With Each Login

```sh
source fpga-webserver/sdaccel_setup
```


## FPGA Build

On your Build Instance, build host and Amazon FPGA Image (AFI) that the host application will load onto the FPGA.

```sh
cd ~/workdisk/fpga-webserver/apps/mandelbrot/build
mkdir ../out
make build TARGET=hw KERNEL=mandelbrot -j8 > ../out/out.log &
```

TODO: What about hw_emu target and running in emulation?

This produces output files in `/fpga-webserver/apps/mandelbrot/out/hw/xilinx_aws-vu9p-f1_4ddr-xpr-2pr_4.0/`. Additionally, the final step, the AFI creation, produces a `.tar` file on S3 storage asynchronously in `s3://fpga-webserver/<user-id>/mandelbrot/AFIs/*.tar`. (You configured `<user-id>` in your `~/.bashrc`). You can see it with:

```sh
aws s3 ls s3://fpga-webserver/<user-id>/mandelbrot/AFIs/
```

It also produces `/fpga-webserver/apps/mandelbrot/out/hw/xilinx_aws-vu9p-f1_4ddr-xpr-2pr_4.0/mandelbrot.awsclbin` which references the S3 tarball.


# F1 Instance Setup

Once you have been granted access to F1, provision an F1 Instance as you did the Build Instance. Use instance type "f1.2xlarge". `ssh` into this instance. It is useful to provision each machine similarly, as you might find yourself doing builds on the F1 Instance as well as on the Build Instance.


# Building from Source

Now, build both the FPGA image and host application, transfer them to the F1 instance, and run as follows.

## Check Version

These instructions were last debugged with SDx v2018.2. Check to see what you are in for:

```sh
sdx -version
```

# Transfer files and Run

All development is done on the Build Instance. The F1 Instance is just used to run. `fpga-webserver/apps/mandelbrot/` is transferred from the Build Instance to the F1 Instance in its entirety through S3 storage.

## Push

You can transfer your app directory to run on the FPGA using the `push` Make target (which runs an `aws s3 sync` command) and by explicitly running an `aws s3 sync` command to pull. Though the whole directory is copied, the files of importance are:

  - the python webserver (including client content) (everything in `fpga-webserver/apps/mandelbrot/webserver`)
  - the host application (built via intermediate Make target `host`)
  - the `.awsxclbin` (AFI) image (which references `s3://fpga-webserver/<user-id>/mandelbrot/AFIs/`)
  - `launch` script in `fpga-webserver/apps/mandelbrot/build`

```sh
cd ~/workdisk/fpga-webserver/apps/mandelbrot/build
make push TARGET=hw KERNEL=mandelbrot &
```

## Pull

Now, start and log into your F1 Instance, initialize and configure AWS and pull these files:

```sh
mkdir ~/work
cd ~/work
mkdir mandelbrot
cd mandelbrot
aws s3 sync s3://fpga-webserver/<user-id>/mandelbrot/xfer .
```


## Launch

```sh
cd ~/mandelbrot_work/build
chmod +x launch ../out/*/*/host # execute privs lost in transfer
./launch hw
```

## Run

As you did locally, you can access `http://<IP>:8888/index.html`. Now you can utilize the FPGA to generate images.


# Development Using this Framework

## Makerchip and TL-Verilog

The Mandelbrot set accelerator has been developed in the [Makerchip](https://makerchip.com/) IDE using the TL-Verilog language extension.
You can copy into Makerchip, or use this link to
[open the design in makerchip](http://www.makerchip.com/sandbox?code_url=https:%2F%2Fraw.githubusercontent.com%2Falessandrocomodi%2Ffpga-webserver%2Fmaster%2Fapps%2Fmandelbrot%2Ffpga%2Fmandelbrot.tlv).
After the kernel has been designed in Makerchip we retrieved the Verilog files by clicking on "E" -> "Open Results" in the Editor tab. From the new browser tab the files that host the Verilog code are called "top.sv" and "top_gen.sv".
The content of these files has to be copied and pasted inside of the file "mandelbrot_example_adder.sv" found in the "fpga/imports" folder.


# Development of this Framework

These are WIP notes:

## SDAccel

This is how I was able to generate an RTL kernel in SDAccel manually and run hardware emulation. This is scripted as part of the build process, but not with the ability to run in SDAccel. These are notes to help figure that out.

 - `cd ~/workdisk/fpga-webserver`
 - `source sdaccel_setup`
 - `sdx`
 - `echo $AWS_PLATFORM` (You will need to know this path.)
 - On Welcome screen "Add Custon Platform".
   - Add (+) `$AWS_PLATFORM/..` .
 - "New SDxProject":
   - Application.
   - name it, select only platform, accept linux on x86 and OpenCL runtime, and "Empty Application". "Finish".
 - Menu "Xilinx", "Create RTL Kernel".
   - name it; 2 clocks (independent kernel clock); 1 reset?
   - default scalars (or change them)
   - default AXI master (Global Memory) options (or change them)
   - wait for Vivado
 - In Vivado:
   - "Generate RTL Kernel"
   - wait
   - Close
 - Back in SDAccel:
   - in projects.sdx:
     - Add binary container under "Hardware Functions" by clicking the lightning bolt icon. There should be only one function identified as the target for the kernel. Click "OK". You will get "binary_container_1".
     - Select "Emulation-HW"
  - Menu "Run", "Run Configuration"
    - Tab "Main", "Kernel Debug", Check "Use RTL waveform...", and check "Launch live waveform".
    - Tab "Arguments", check "Automatically add binary container(s) to arguments"
    - Click "Run" (or "Apply" and click green circle w/ play arrow).


# Related Technologies

  - [Fletcher](https://github.com/johanpel/fletcher) might make a good foundation for this framework.

# To Do

  - Figure out how to generate .xo.
    - `framework/fpga/scripts/create_rtl_kernel.sh` creates parts of `mandelbrot/fpga/mandelbrot_hw` (`imports`?) which should be built through Makefile, not included in repo. (Paths have changed, so scripts are broken).
    - `mandelbrot/fpga/mandelbrot_hw/imports/package_kernel.tcl` produces `.xo` from `mandelbrot_hw`. (Not sure if it runs xocc itself or if that should be done in Makefile.)
  - hw_emu instructions.
  - Include initialization steps in host application automatically. (For `client.html`, no explicit commands to `open` and `Init FPGA`.)
  - provide information and pointers about the more general use of the commands.
  - Automate export from Makerchip by providing a script that uses `curl` to access result files via `http://makerchip.com/compile/<compile-id>/results/<filename>`.
  - Split mandelbrot Makefile to provide some parts in framework.


# Immediate Issues

  - apps/mandelbrot/out/ does not exist for make command above.
  - no pre-built files in apps/mandelbrot/prebuilt
  - still need to initialize FPGA w/ client.html?
  - failing w/ "ERROR: Failed to load xclbin" (sdx_imports/main.c). Solved by stopping & starting F1 Instance (not by rebooting).
