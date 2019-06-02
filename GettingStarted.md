# Overview

These instructions will get you up to speed using this framework on AWS infrastructure. While this framework eliminates substantial development complexity, setup for AWS F1 remains a lengthy process. Optional instructions are provided to get the Mandelbrot example application up and running on a local Linux machine without FPGA acceleration. Furthermore, to run with FPGA acceleration, prebuilt images are provided to initially bypass the lengthy builds. (Over time, this framework will better support local development of the custom kernel and automate deployment to F1.)

As a preview of the complete process, to get the Mandelbrot application up and running from source code with FPGA acceleration, you will need to:

  - Get an AWS account with access to F1 instances. (This requires a day or two to get approval from Amazon.)
  - Launch and configure a Development Instance on which to compile the OpenCL, Verilog, and Transaction-Level Verilog source code into an Amazon FPGA Image (AFI).
  - Launch and configure an F1 Instance on which to run: the web server, the Host Application, and the FPGA programmed with the image you created on the Development Instance.
  - Open the FPGA-Accelerated Web Application in a web browser.

F1 machines are powerful and expensive. Configured for minimal optimization, hardware compilation of a small kernel takes about an hour. These instructions assume the use of a separate Development Instance, which does not have an FPGA, to save costs. The FPGA kernel can be tested on this machine using "Hardware Emulation" mode, where the FPGA behavior is emulated using simulation and build times are minimal by comparison. For hobby projects, it is not practical to keep either EC2 Instance up and running for extended periods of time. The overhead of using two EC2 instances can sometimes result in extra cost and time of its own. So, depending upon your goals, you may prefer to simplify your life by using the F1 Instance as your Development Instance, in which case you can skip the instructions below for creating and configuring the Development Instance.

There are many similar tutorials on line to get started with F1. Many are flawed, unclear, or out-dated. We found this  <a href="https://github.com/Xilinx/SDAccel-Tutorials/blob/master/docs/aws-getting-started/RTL/README.md" target="_blank">Xilinx tutorial</a> to be the best, though we do not recommend following it to the letter. Instead, open the Xilinx tutorial in its own window, and follow the instructions below which reference this tutorial (to avoid upkeep of redundant independent instructions).



# AWS Account Setup with F1 Access

Follow the "Prerequisites" instructions, noting the following:

  - When choosing a name for your S3 bucket (in step 3 of these instructions), consider who might be sharing this bucket with you. You should use this bucket for the particular fpga-webserver project you are starting. You might share this bucket with your collaborators. The bucket name should reflect your project. You might wish to use the name of your git repository, or the name of your organization, i.e. `fpga-webserver-zcorp`. If you expect to be the sole developer, you can reflect your name (perhaps your AWS username) in the bucket name and avoid the need for a `/<username>` subdirectory.
  - The subdirectories you will use are: `/<username>` if your username is not reflected in your bucket name, and within that (if created), `/dcp`, `/log`, and `/xfer`.

Okay, now, follow the "FOLLOW THE INSTRUCTIONS" link under "Prerequisits". (In case you lose your place, you should be <a href="https://github.com/Xilinx/SDAccel-Tutorials/blob/master/docs/aws-getting-started/PREREQUISITES/README.md" target="_blank">here</a>.

When you are finished the Prerequisite instructions (after requesting F1 access), press "Back" in your browser.



# Running Mandelbrot Locally

There is a great deal of setup you can do while you wait for F1 access. First, if you have a Ubuntu machine (or care to provision one via AWS or Digital Ocean, etc.), you can play around with the Mandelbrot example without hardware acceleration.

On a Ubuntu 16.04 machine (or try your luck with something different, and let us know):

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



# Create Development Instance

Next you will provision a Development Instance using the "Create" part of the "1. Create, configure and test an AWS F1 instance" instructions. These instructions configure an F1 machine, but you will instead first configure a Development Instance without the FPGA (in case you are still waiting for F1 approval). You'll repeat these instructions later for the F1 Instance after getting approval.

Click the "FOLLOW THE INSTRUCTIONS" link (which take you <a href="https://github.com/Xilinx/SDAccel-Tutorials/blob/master/docs/aws-getting-started/RTL/README.md" target="_blank">here</a>). As you step through the tabs of the instance creation process in AWS, perform the following additional/modified steps:

  - In **Step 2. Choose an Instance Type** (Step3 of the tutorial instructions): Since we are creating the Development Instance first, select "c4.2xlarge" instead of "f1.2xlarge" on your first pass through these instructions.
  - In **Step 4. Add Storage** (Step 4.2. of the tutorial instructions): I found the default 5GB of Elastic Block Storage to be rather limited for doing anything more than just the tutorial. I would consider 8GB to be a minimum to support development and 12GB to be practical. (For the F1 Instance, assuming you will do most development on the Development Instance, 8GB is probably sufficient.)
  - In **Step 6. Configure Security Group** (Step 5 of the tutorial instructions):
    - Name this security group something like "fpga-webserver". When you repeat these instructions for the F1 Instance, you can simply "Select an existing security group" (this one) and you are finished with this step (Step 6).
    - Open the RDP (Remote Desktop Protocol) port according to the tutorial.
    - Open ports to make the Web Server accessible from outside. (By default, we will use port 8888, but we reserve several.)
      - **Add Rule**
      - **Type**: Custom TCP Rule (the default)
      - **Port Range**: "8880-8889"
      - **Source**: "Anywhere" or your IP address for better security
      - **Description**: e.g. "development-webserver"
    - For remote desktop, I have had issues with both RDP and VNC. (More on that below.) If you wish to be able to use VNC (from Linux), also open up ports 5901-5910.
    
    Note that when you repeat these instructions for your F1 Instance, you will be able to 

Do not proceed to **2. Connecting to the Instance with a remote desktop client** just yet.

Note that you can also make configuration changes after creating and launching the instance. Instances can be controlled via the EC2 Dashboard under "Resources", "Running Instances". To open new ports, scroll right (if necessary) and select the security group for your instance. You will use the "Running Instances" page frequently to start and stop your instances (by selecting the instance(s) and setting their state via "Actions", "Instance State").

You can also name your instance, which would be a good thing to do now by hovering over its "Name" field and clicking the pencil icon. Enter a name, like `fpga-webserver-dev-1` (or `fpga-webserver-run-1` for the F1 Instance).

Be sure not to accidentally leave instances running!!! You should configure monitoring of your resources, but the options seem very limited for catching instances you fail to stop. Also be warned that stopping an instance can fail. I have found it important to always refresh the page before changing machine state. And, be sure your instance transitions to "stopped" state (or, according to AWS support, charging stops at "stopping" state).



# One-Time Instance Setup

##Installing necessary packages

In the fpga-webserver directory run:
```sh
./installs.sh
```
It installs the Tornado webserver and some Python image processing libraries.

## Remote Desktop

For remote desktop access to the EC2 machines, I have used X11, RDP, and VNC from a Linux client. X11 is easiest, but it is far too slow to be practical. RDP and VNC required several days for me to get working initially. I suggest using RDP, but I am also including instructions for VNC as a fall-back option.

TODO: I have not figured out cut-n-paste to/from RDP.

### X11 Forwarding

This is easy and stable, so even though it is not a solution for running Xilinx tools long-term, start with X11.

```sh
ssh -X -i <AWS key pairs.pem> centos@<ip>
sudo yum install xeyes -y   # Just a GUI application to test X11.
xeyes   # You'll probably see "Error: Can't open display", so fix this with:
sudo yum install xorg-x11-xauth -y
exit
ssh -X -i <AWS key pairs.pem> centos@<ip>
xeyes  # Hopefully, you see some eyes now.
<Ctrl-C>
```

From this ssh shell, you can launch X applications that will display on your local machine. In contrast, RDP and/or VNC provide you with a desktop environment.

### RDP

#### Running RDP with Remmina Remote Desktop Client
 1) Create a new remote desktop file
 2) Give it a name and fill in the following
 3) In the "Basic" tab
   a) Server      = <IPv4 Public IP>
   b) User name   = <centos>
   c) Password    = <password generated at end of running setup_gui.sh>
   d) Color depth = True color (24 bpp)
 4) In the "Advanced" tab
   a) Security    = RDP
 5) Connect
  
 Note: that between Stopping and Starting Amazon instances the IPv4 instance changes
   

Next you will continue through **2. Connecting to the Instance with a remote desktop client**. (In case you got lost, that's <a href="https://github.com/Xilinx/SDAccel-Tutorials/blob/master/docs/aws-getting-started/RTL/STEP1.md#2-connecting-to-the-instance-with-a-remote-desktop-client" target="_blank">here</a>.)

The `curl` command in these instructions produces a great deal of output, and there were a couple of issues the first time I tried it. It would be wise to capture the output by appending ` 2>&1 | tee /tmp/rdp_curl.log` onto the command.

The remaining issue for some users:

  - Connecting from Linux and Windows 7 (for which support ends in Jan. 2020, so stop using it) fails with:
  
  ```
  SSL_connect: error:1408F10B:SSL routines:SSL3_GET_RECORD:wrong version number
  Error: protocol security negotiation or connection failure
  ```
  
  I found the following fix:

  ```sh
  sudo cp /etc/xrdp/xrdp.ini /etc/xrdp/xrdp.ini.bak  # create a backup
  sudo sed -i s/security_layer=negotiate/security_layer=rdp/ /etc/xrdp/xrdp.ini  # change "security_layer"
  sudo diff /etc/xrdp/xrdp.ini /etc/xrdp/xrdp.ini.bak  # just to see that something changed
  ```

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

From the client:

```sh
vncpasswd   # Enter the password used on the server.
vncviewer <IP>:1 passwd=<home>/.vnc/passwd
```

And, on the remote instance, kill the VNC server with:
```sh
vncserver -kill :1
```

Any number of clients can be connected to this VNC server while it is running. Closing the client connection does not terminate the server.

After you see that these commands are working, the script `vnc_ec2` (at the top level of the repo) can be used locally to launch a server on the remote instance and connect to it. Note the prerequisite "Assumptions" in the header comments of this file.

```sh
vnc_ec2 -gXXXXxYYYY <IP>   # where -g is the VNC --geometry argument specifying desktop size.
```

This running VNC server can be killed using:

```sh
vnc_ec2 -k <IP>   # <IP> can be omitted to use the IP of the last server launched w/ vnc_ec2.
```


## AWS CLI Configuration

Configure by providing your credentials you saved in a secure location earlier. (Your Secret Access Key is not accessible within the AWS Console, so if you lost this information you will have to visit the <a href="https://console.aws.amazon.com/iam/home?#/security_credential" target="_blank">Security Credentials</a> page, which you can find under your account menu (your username in the upper-right) and generate new credentials.)

```sh
aws configure
```

Use region: `us-east-1` and output: `json`.


## S3 Storage

We will share files between instances using Amazon S3 through folders of the form `s3://<bucket-name>[/<unique-username>]/<kernel-name>`. If your bucket is to be shared by multiple users, you should choose a `<unique-username>`, such as your Amazon IAM username.

Configure your `.bashrc` for your bucket and username. From your ssh shell or remote desktop terminal:

```sh
echo 'export S3_BUCKET=<bucket-name>' >> ~/.bashrc
echo 'export S3_USER=<unique-username>' >> ~/.bashrc   # Exclude this if the bucket is for a single user.
source ~/.bashrc
```

These settings are recognized by the Makefile. Use the same bucket name and user name for all your instances.


## Workdisk

Because disk space is limited, unlike other online instructions, I chose to use the ESB disk for my work:

```sh
ln -s /home/centos/src/project_data workdisk
cd ~/workdisk   # Work here.
```


## SSH keys

If you happen to be using private git repositories or need passwordless authentication from your instance for any other reason, you may need to generate ssh access keys for your instance.

```sh
ssh-keygen -o -t rsa -b 4096 -C "<machine-identifying comment>"
sudo yum install xclip -y
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



# Waiting for Access

This completes the instance build and configuration, which will be repeated for the F1 Instance. Assuming you are still waiting for access, you can continue and do some builds on the Development Instance.



# With Each Login

```sh
source fpga-webserver/sdaccel_setup
```


# FPGA Emulation Build

These instructions were last debugged with SDx v2018.2. Check to see what version you have. If it differs, you might get to help us debug a new platform.

```sh
sdx -version
```

On your Development Instance, build the host application and Amazon FPGA Image (AFI) that the host application will load onto the FPGA.

```sh
cd ~/workdisk/fpga-webserver/apps/mandelbrot/build
make TARGET=hw_emu -j8 launch   # (-j8 is optional; it's for parallel build)
```

This produces outputs files in `../out/hw_emu/xilinx_aws-vu9p-f1_4ddr-xpr-2pr_4.0/`, and it starts the application.

Point a web browser at: `http://<IP>:8888` (or from outside: `http://<IP>:8888`). Be aware, as you use the application, that the FPGA is emulated, so it is running several orders of magnitude slower than a real FPGA. Be careful not to ask it to do too much. Make the image small, and set the depth to be minimal before selecting "FPGA" rendering.



# FPGA Build

Now, build both the FPGA image and host application for the real FPGA. The FPGA build will take about an hour.

Still on your Development Instance and in the same `/build` directory:

```sh
make TARGET=hw -j8 launch &
```

This will produce an Amazon FPGA Image (AFI) and a host application that will load it. The final step of AFI creation runs asynchronously after the `make` command completes, fed by a "Design Check-Point" (DCP) "tarball" stored on S3 in `s3://fpga-webserver/<user-id>/mandelbrot/dcp/*.tar`. (You configured `<user-id>` in your `~/.bashrc`). To the best of my understanding the actual AFI is stored permanently by AWS at no cost.

The above step generates:

  - `../out/hw/xilinx_aws-vu9p-f1_4ddr-xpr-2pr_4.0/mandelbrot.awsxclbin` which identifies the AFI
  - `../out/hw/xilinx_aws-vu9p-f1_4ddr-xpr-2pr_4.0/<timestamp>_afi_id.txt` containing the ID of your AFI.
  
The AFI ID can be used to check the status of the AFI generation process. View the ID with:

```sh
cat ../out/hw/*/<timestamp>_afi_id.txt
```

To check the status of the AFI generation process:

```sh
aws ec2 describe-fpga-images --fpga-image-ids <AFI ID>
```

The command will show `Available` when the AFI is ready use. Otherwise, the command will show `Pending`.

```json
State: {
   "Code" : Available"
}
```

The tarball is taking up space on the S3 disk. It seems it is only needed during AFI creation. So after AFI creation completes, you probably want to delete the tarball. These commands will delete all tarballs and logs (including any previous builds).

```sh
aws s3 ls -recursive s3://<bucket-name>[/<user-id>]/mandelbrot/dcp  # Check first.
aws s3 ls -recursive s3://<bucket-name>[/<user-id>]/mandelbrot/log
aws s3 rm -recursive s3://<bucket-name>[/<user-id>]/mandelbrot/dcp  # Then delete.
aws s3 rm -recursive s3://<bucket-name>[/<user-id>]/mandelbrot/log
```

(TODO: This should be automated. These commands will delete the directories, which may need to exist?)



# F1 Instance Setup

Once you have been granted access to F1, provision an F1 Instance as you did the Development Instance. Use instance type "f1.2xlarge". `ssh` into this instance. It is useful to provision each machine similarly, as you might find yourself doing builds on the F1 Instance as well as on the Development Instance.


# Running Prebuilt Files on FPGA

Prebuilt files are included in the repository. Try to run using those first, so you can see the FPGA in action. (TODO: You probably won't have permission to do this. This is probably something to look into.)

```sh
cd
git clone https://github.com/alessandrocomodi/fpga-webserver
cd fpga-webserver
git submodule update --init --recursive  # or ./init
cd apps/mandelbrot/build
make PREBUILT=true TARGET=hw -j8 launch
```

Point a web browser at `http://<IP>:8888` (or from outside `http://<IP>:8888`) and play with the application.

When you are done, _`ctrl-C`_, `exit`, and stop your instance.



# Transfer files and Run

Running the AFI built above on the F1 Instance requires the `.awsxclbin` file from the Development Instance. There are many options for how to transfer this file. It should be transferred into the right location, either `../prebuilt/hw/xilinx_aws-vu9p-f1_4ddr-xpr-2pr_4.0/mandelbrot.awsxclbin` or `../out/hw/xilinx_aws-vu9p-f1_4ddr-xpr-2pr_4.0/mandelbrot.awsxclbin`. Transfer options are:

  - Through S3 using Makefile build targets. There are targets for `push` (from the Development Instance) and `pull` (on the F1 Instance) (but these currently require some updates).
  - Through the Git repository. The `/prebuilt` directory is part of the repository, so you can `git push` on the Development Instance and `git pull` on the F1 Instance, and build from `/prebuilt` as above.
  - Any other file transfer method.

And run

```sh
make PREBUILT=true TARGET=hw -j8 launch   # Or without `PREBUILT=true` if you placed the `.awsxclbin` in `\out` instead of `prebuilt`.
```

And open: `http://localhost:8888`, or from outside `http://<IP>:8888`.



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


