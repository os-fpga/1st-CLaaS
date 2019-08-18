# Overview

These instructions use the Mandelbrot example application to get you up to speed using 1st CLaaS on AWS infrastructure. It is important to walk through all of these steps to get properly set up for development, to become familiar with the framework, and to uncover any issues before creating your own project. You will step through:

  - [AWS Account Setup with F1 Access](#AWS-Acct) (requires a day or two for approval from Amazon)
  - [Running Locally](#RunningLocally)
  - [Provisioning EC2 Instances](#ProvisionInstances)
  - [FPGA Emulation Build](#EmulationBuild)
  - [FPGA Build](#FPGABuild)
  - [Making Your Own Application](#CustomApp)

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



<a name="AWS-Acct"></a>
# AWS Account Setup with F1 Access

<!--
TODO: The S3 steps should be automated using the AWS CLI, and the remaining instructions should be provided here, inline.
-->
Follow the "Prerequisites" instructions, noting the following:

  - When choosing a name for your S3 bucket (in step 3 of these instructions), consider who might be sharing this bucket with you. You should use this bucket for the particular fpga-webserver project you are starting. You might share this bucket with your collaborators. The bucket name should reflect your project. You might wish to use the name of your git repository, or the name of your organization, i.e. `fpga-webserver-zcorp`. If you expect to be the sole developer, you can reflect your name (perhaps your AWS username) in the bucket name and avoid the need for a `/<username>` subdirectory.
  - The subdirectories you will use are: `/<username>` if your username is not reflected in your bucket name, and within that (if created), `/dcp`, `/log`, and `/xfer`.

Okay, now, follow the "FOLLOW THE INSTRUCTIONS" link under "Prerequisits", except steps 3 and 4. (In case you lose your place, you should be <a href="https://github.com/Xilinx/SDAccel-Tutorials/blob/master/docs/aws-getting-started/PREREQUISITES/README.md" target="_blank" atom_fix="_">here</a>.

When you are finished the Prerequisite instructions (after requesting F1 access), press "Back" in your browser.



<a name="RunningLocally"></a>
# Running Mandelbrot Locally

There is a great deal you can do while you wait for F1 access. 

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



<a name="ProvisionInstances"></a>
# Create Development Instance

## AWS Configuration

In order for scripts to interface with your AWS resources, you'll need to provide your AWS credentials. You can generate Access Keys on the AWS console under IAM Management, then.

```sh
aws configure
```

And provide:

```
AWS Access Key ID [None]: <your access key>
AWS Secret Access Key [None]: <your secret key>
Default region name [None]: <your AWS region, for instance us-east-1 for northern Virginia>
Default output format [None]: json
```

This creates files under `~/.aws`.

Terraform uses the same information in a different format, so create a file outside of the repository, which we'll assume to be `~/aws_credentials.tfvars`, containing:

```
aws_access_key_id="<your access key>"
aws_secret_access_key="<your secret key>"
region="<your AWS region>"
```


## Create and Launch the Instance

We use <a href="https://www.terraform.io/" target="_blank" atom_fix="_">Terraform</a> to automate provisioning and configuring instances.

The following script creates your Development Instance. To initialize the instance, it clones and initializes all the necessary repositories, and sets up the Remote Desktop Protocol (RDP) agent. Be patient, this takes around 10 minutes.

> IMPORTANT: The instance created below is left running, and bleeding $. Be sure not to accidentally leave instances running!!! You should configure monitoring of your resources, but the options, though plentiful, seem very limited for catching instances you fail to stop. Also be warned that stopping an instance can fail. We have found it important to always refresh the page before changing machine state. And, be sure your instance transitions to "stopped" state (or, according to AWS support, charging stops at "stopping" state). We'll get to [Stopping Instances](#StopInstances) shortly.

```sh
cd <repo>/framework/terraform/development
source deploy.sh ~/aws_credentials.tfvars
```

The instance that is created allows TCP/IP traffic through on port 80 for running a production web server and certain ports for development. Once the script finishes, you will see the public IP address of your Development Instance in the terminal, and you can find all the instance parameters in `terraform.tfstate`. Note that this file contains the private TLS key.

<!-- Make terraform.tfstate privs 400. --> 

A TLS keypair and a temporary RDP password is also generated during the process. You can find these in the same directory. You'll use these credentials to connect to the machine using SSH or RDP.

<!-- temp_pwd_### is for RDP only? How is it changed? -->


<a name="StopInstances"></a>
## Stop the Instance

You can stop (shutdown) the instance on the AWS console, under Service -> EC2 -> Instances. (Terraform does not have a way to stop instances, only terminate (destroy) them.)

The following commands terminate the instance:

```sh
cd <repo>/framework/terraform/development
source destroy.sh
```

Note that this also deletes the created storage. (This step can be disabled in the f1.tfvars file.)


## Accessing Your Instance

### Remote Desktop

Terraform installed a Remote Desktop Protocol agent on the Development Instance, and the `<repo>/init` script installed Remmina, for remote desktop access. Run:

```sh
remmina
```

  1. Click "New", and fill in the following:
    1. Name: (as you like)
    1. In the "Basic" tab
      1. Server: [IPv4 Public IP]
      1. User name: centos
      1. Password: [leave blank]
      1. Color depth: True color (24 bpp)
    1. In the "Advanced" tab
      1. Security: RDP
    1. Connect

Note that between stopping and starting Amazon instances the IPv4 Public IP of the instance changes and will need to be reassigned in Remmina.

The temporary password you will need to enter is in the `centos_pwd.txt` file. You may wish to delete this file for security reasons, and preferably you should assign a more secure password. <!-- instructions -->

<!--
### X11 Forwarding

This is easy and stable, so even though it is not a solution for running Xilinx tools long-term, start with X11.

```sh
ssh -X -i <AWS key pairs.pem> centos@<ip>   # (.pem created in "Prerequisit" instructions)
sudo yum install xeyes -y   # Just a GUI application to test X11.
xeyes   # You'll probably see "Error: Can't open display", so fix this with:
sudo yum install xorg-x11-xauth -y
exit
ssh -X -i <AWS key pairs.pem> centos@<ip>
xeyes  # Hopefully, you see some eyes now.
<Ctrl-C>
```

From this ssh shell, you can launch X applications that will (slowly) display on your local machine. In contrast, RDP and/or VNC provide you with a desktop environment.

-->

### SSH Access

A TLS keypair is generated every time you run the Terraform startup script. You can use this keypair to log into the instance.
`-X` will forward X11 traffic, so you can use GUI tools, but performance will be inadequate for the Xilinx tools.

```sh
ssh -X -i <repo>/framework/terraform/development/private_key.pem centos@<public IP address of EC2 instance>
```

## SSH keys

In case you want to set up passwordless authentication from your Development Instance for git access or any other reason, you may need to generate ssh keys for your instance.

```sh
ssh-keygen -o -t rsa -b 4096 -C "<machine-identifying comment>"
sudo yum install xclip -y
xclip -sel clip < ~/.ssh/id_rsa.pub
```

And paste this SSH key into the settings of your other account (e.g. gitlab/github).


<!--
## Clone Necessary Repos

```sh
cd ~/workdisk
git clone https://github.com/aws/aws-fpga.git $AWS_FPGA_REPO_DIR
git clone https://github.com/alessandrocomodi/fpga-webserver
cd fpga-webserver
source ./init
```
-->



# Waiting for Access

This completes the instance build and configuration, which will be repeated for the F1 Instance. Assuming you are still waiting for access, you can continue and do some builds on the Development Instance.



# With Each Login

```sh
source fpga-webserver/sdaccel_setup
```



<a name="EmulationBuild"></a>
# FPGA Emulation Build

TODO: Instructions for using a specific AMI version and checking the latest version.

These instructions were last debugged with SDx v2018.3. Check to see what version you have. If it differs, you might get to help us debug a new platform.

```sh
sdx -version
```

On your Development Instance, build the host application and Amazon FPGA Image (AFI) that the host application will load onto the FPGA.

```sh
cd ~/workdisk/fpga-webserver/apps/mandelbrot/build
make TARGET=hw_emu -j8 launch   # (-j8 is optional; it's for parallel build)
```

This produces output files in `../out/hw_emu/xilinx_aws-vu9p-f1_4ddr-xpr-2pr_4.0/`, and it starts the application.

Point a web browser at: `http://<IP>:8888` (or from outside: `http://<IP>:8888`). Be aware, as you use the application, that the FPGA is emulated, so it is running several orders of magnitude slower than a real FPGA. Be careful not to ask it to do too much. Make the image small, and set the depth to be minimal before selecting "FPGA" rendering.



<a name="FPGABuild"></a>
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
   "Code" : "Available"
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

TODO: Prebuilt AFI is not publicly accessible.

Prebuilt files are included in the repository. Try to run using those first, so you can see the FPGA in action. (TODO: You probably won't have permission to do this. This is probably something to look into.)

```sh
cd
git clone https://github.com/alessandrocomodi/fpga-webserver
cd fpga-webserver
source ./init
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



<a name="CustomApp"></a>
# Making Your Own Application

Now you are ready to make an application of your own. This section is not a cookbook, but rather some pointers to get you starte in down your own path.


## Getting Started

You may want to work locally to avoid AWS charges. But you would need to transfer your work in order to test it. We are working to enable local simulation, but for now, we will assume you are running on a Development Instance using Xilinx tools.

Start with an existing project.

```sh
cd ~/workdisk/fpga-webserver/apps
cp -r vadd <your-proj>
```

The app name (`vadd`) is reflected in several filenames for clarity, so change these to <your-proj>.


## Web Client Application

For a simple quick-and-dirty application or testbench for your kernel, you might use the existing structure to write some basic HTML, CSS, and JavaScript. If you intend to develop a real application, you probably have your own thoughts about the framework you would like to use. You can develop in a separate repo, or keep it in the same repo so it is consistently version controlled.


# Custom Kernel

The vadd kernel is a good starting point for your own kernel. It is written using TL-Verilog. A pure Verilog version is also available.


# C++ Host Application

It is not required to customize the host application, but if you need to do so, you can override the one from the framework, following the example of the mandelbrot application. (Refer to its Makefile as well as `/host` code.)


# Python Web Server

It is not required to customize the python web server, bit if you need to do so, you can overrie the one from the framewoek, following the example of the manelbrot application. (Refer to its Makefile as well as `/webserver` code.)



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



# To Do

  - Transition to a workflow where edits are made on local machine, and `scp -rp` syncs to EC2 machines.
  - Further transition to using aws cli and ssh in Makefile to start/stop and launch build/run commands remotely.
