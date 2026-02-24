<a name="Overview"></a>
# Getting Started with AWS and F2


# Table of Contents

  - [Overview](#Overview)
  - [AWS Account Setup with F2 Access](#AWS-Acct)(requires a day or two for approval from Amazon)
  - [1st CLaaS Configuration for AWS](#config)
  - [Using Your Development Instance](#DevInstance)
  - [FPGA Emulation Build](#EmulationBuild)
  - [FPGA Build](#FPGABuild)



<a name="Overview"></a>
# Overview

This guide will get you set up and give you a feel for using AWS EC2 for 1st CLaaS development. You'll walk you through the steps to run 1st CLaaS sample applications on AWS F2 and prepare for optimization and deployment of your own accelerated microservices.

> **Note:** AWS F1 instances have been discontinued and replaced by F2 instances, which deliver up to 60% better price performance.

> **Disclaimer:** You will be charged by Amazon for the resources required to complete these steps and to use this infrastructure. Don't come cryin' to us. We are in no way responsible for your AWS charges.

1st CLaaS provides automation for provisioning and developing on two classes of AWS EC2 instance:

  - **Development Instance**: An EC2 c4.4xlarge instance, without an FPGA. Xilinx tools and flows are available for simulation using "Hardware Emulation" (`hw_emu`) mode. This instance is ideal for optimizing the implementation of the custom kernel. (~$0.80/hr)
  - **F2 Instance**: An EC2 f2.6xlarge instance with an attached AMD Virtex UltraScale+ HBM VU47P FPGA (16 GB HBM), supporting final testing and deployment. (~$1.98/hr)

<!--
Optional instructions are provided to get the Mandelbrot example application up and running on a local Linux machine without FPGA acceleration. Furthermore, to run with FPGA acceleration, prebuilt images are provided to initially bypass the lengthy builds.

As a preview of the complete process, to get the Mandelbrot application up and running from source code with FPGA acceleration, you will need to:

  - Get an AWS account with access to F2 instances. (This requires a day or two to get approval from Amazon.)
  - Launch a Development Instance on which to compile the OpenCL, Verilog, and Transaction-Level Verilog source code into an Amazon FPGA Image (AFI).
  - Launch an F2 Instance on which to run: the web server, the Host Application, and the FPGA programmed with the image you created on the Development Instance.
  - Open the FPGA-Accelerated Web Application in a web browser.
-->

Configured for minimal optimization, hardware compilation of a small kernel takes about an hour. Compilation for Hardware Emulation mode is relatively fast. To save cost, you can do as much development as possible on your local machine, then optimize implementation on a Development Instance, then deploy on F2. (If cost is not an obstacle, you can save some headache by using the F2 Instance as your Development Instance.)

AWS F2 is relatively new, and third-party tutorials are scarce. The best official resources are the <a href="https://github.com/aws/aws-fpga" target="_blank" atom_fix="_">AWS FPGA Development Kit on GitHub</a> and the <a href="https://awsdocs-fpga-f2.readthedocs-hosted.com/latest/vitis/README.html" target="_blank" atom_fix="_">AWS FPGA F2 Documentation</a>. We have automated many of the setup steps in 1st CLaaS to simplify the process.



<a name="AWS-Acct"></a>
# AWS Account Setup with F2 Access

## Create an AWS account

If you do not already have an AWS account, create one here: [https://aws.amazon.com/](https://aws.amazon.com)

Copy the access keys (AWS Access Key ID and AWS Secret Access Key) you create through this process for later reference.

> If you are using an **AWS SSO or university/organization-assigned AWS account** instead of a personal account, the setup differs. See the [detailed SSO setup instructions](F1Guide.md#SSO) in the Optimization and Deployment Guide.

## Select a region

AWS F2 instances are currently available in US East (N. Virginia). Check the [AWS Regional Services](https://aws.amazon.com/about-aws/global-infrastructure/regional-product-services/) page for the latest region availability. You must select a supported region in the AWS Management Console.

  - Log in to the AWS Management Console: [https://console.aws.amazon.com](https://console.aws.amazon.com)
  - Select your region from the dropdown in the upper right corner of the console

## Request access to AWS F2 instances

By default, AWS users do not have access to F2 instances. You need to request access.

  - Open the Service Limit Increase form: [http://aws.amazon.com/contact-us/ec2-request](http://aws.amazon.com/contact-us/ec2-request).
  - Make sure your account name is correct.
  - Submit a 'Service Limit Increase' for 'EC2 Instances'.
  - Select the region where you want to access F2 instances: US East (N. Virginia) (or other supported regions as they become available).
  - Select 'f2.6xlarge' as the primary instance type. (You may choose larger, but 1st CLaaS scripts assumes f2.6xlarge.).
  - Set the 'New limit value' to 1 or more based on your expected needs.
  - Complete the form and click 'Submit'.

Access will take a day or two, so we will be bringing you up to speed first on the Development Instance.

## Create a new user

It is recommended to create a new AWS user with new access keys using AWS Identity and Access Management rather than using `root` access credentials, but instructions for that are left as an exercise to the reader for now. <!-- TODO: add instructions. -->


<a name="config"></a>
# 1st CLaaS Configuration for AWS

To configure 1st CLaaS with AWS credentials and other information:

```sh
cd <repo>/framework/build
make config
```

Enter information, using:

  - "default" AWS profile
  - your AWS access keys created and region selected above
  - default output format: `json`
  - an S3_USER and S3_BUCKET_TAG of your choice (lowercase alphanumeric only), used only to create a unique bucket name (global address for AWS data storage).
  - if desired, a default administrative webserver password (as described).

This creates:

  - AWS configuration files under `~/.aws` for the default AWS profile
  - 1st CLaaS configuration referencing this default AWS profile in `~/1st-CLaaS_config.mk`.



<a name="DevInstance"></a>
# Using Your Development Instance

## Provisioning your Development Instance

Have the EC2 Dashboard open in a web browser (accessible from the AWS Management Console, under "Services" -> "EC2").

The command below uses <a href="https://www.terraform.io/" target="_blank" atom_fix="_">Terraform</a> to provision and configure a 1st CLaaS Development Instance. It runs for about 10 minutes, and, if all goes well (and perhaps even if it doesn't), your new instance will be up and running (and bleeding money) upon completion.

> **IMPORTANT:** Be sure not to accidentally leave instances running!!! You should configure monitoring of your resources, but the options, though plentiful, seem very limited for catching instances you fail to stop. Also be warned that stopping an instance can fail. We have found it important to always refresh the page before changing machine state. And, be sure your instance transitions to "stopped" state (or, according to AWS support, charging stops at "stopping" state).

You must choose a Linux password for your new instance (which must not contain single/double quotes nor backslash). **Make Sure to use a strong password probably with more than 8 characters and having alphabets + numbers + special characters** .Obviously, since you are typing it here in plain text, be sure it is not visible to wandering eyes, and perhaps run `clear` after command completion.

```sh
make development_instance LINUX_PASSWORD=<password-for-your-instance>
```

This creates:

  - An EC2 instance, which you can see, once it is created under "Instances"::"Instances" or "Running Instances".
  - Other EC2 resources associated with these instances, like TLS key pairs, security profiles, and storage. Note that there is a nominal **recurring cost** for the storage even when the instances are not running.
  - Local copies of the TLS key pairs in `~/.ssh/<instance-name>/`, for SSH access to your instances.
  - A Terraform state file describing this instance (or, more generically, a "1st CLaaS Setup"), stored on your S3 disk. (These can be viewed with: `aws s3 ls 1st-claas.<S3_USER>.<S3_BUCKET_TAG>/tf_setups/`.)

An instance setup, including all the above resources can be destroyed with a single `make destroy INSTANCE_NAME=<instance_name` command (reported upon completion of the creation command). Resources that are managed as part of a 1st CLaaS Setup have names beginning with `1st-CLaaS_`. These should be managed (destroyed) via `make ...` commands, not via the EC2 Console.

For more information about managing these instance setups, refer to the [**Optimization and Deployment Guide**](F1Guide.md#top).


## Accessing Your Development Instance

### Remote Desktop

The Development Instance has a Remote Desktop Protocol (RDP) agent installed, and the `init` script installed an RDP client, called Remmina. We've made them easy to use.

To open the RDP desktop for your single currently-running EC2 instance (your Development Instance at the moment), run:

```sh
make desktop
```

Enter your Linux password. (We do not register your password with Remmina because Remmina must be carefully configure to keep your password secure.)

If you have Windows installed, you can use RDC (Remote Desktop Connection). If you want to access the remote server manually, type the Public IP Address in the field.

![RDC sample](/doc/img/RDC.png "RDC Window")

If you face any color depth issue when using Remote Desktop especially with Xilinx Tools (they get blurry and test is none to visible), you can set High Colour to **16 bit**

![RDC color](/doc/img/RDC_color.png "RDC Colour")

### SSH Access

Note that you can also connect to your instance using ssh. X11 traffic will be forwarded to your local machine, so you can use GUI tools, but performance for many tools, including the Xilinx tools, will be inadequate.

```sh
make ssh
```

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

-->



<a name="EmulationBuild"></a>
# FPGA Emulation Build

## Open Terminal

Open a new terminal in your remote desktop. Each time you do so, you must:

```sh
cd ~/1st-CLaaS  # (~/1st-CLaaS is a symbolic link.)
source vitis_setup
```


## Hardware Emulation of Mandelbrot Application

As you did on your local machine, you can run Mandelbrot in simulation.

```sh
cd ~/1st-CLaaS/apps/mandelbrot/build
make TARGET=sim launch
```

Point a web browser at: `http://<IP>:8888` (or from outside: `http://<IP>:8888`). The IP address was reported in the output of `make development_instance` and `make desktop`. The command `make ip` (from your local machine) will also report it, or you can find it in the EC2 Dashboard, "Running Instances" page. Note that each time the instance is booted, it gets a new IP address.

`<Ctrl>-C` to stop the web server.

On this instance, you can also run the Xilinx "hardware emulation" (`hw_emu`) mode. In this mode, unlike simulation mode, OpenCL is used, and RTL for *all* FPGA logic is simulated, not just the custom kernel. This is 4-state simulation, so it may catch issues that went unnoticed in 2-state Verilator simulation. It also will exhibit different timing and will see a different patter of cycles with valid and invalid data at the input to the kernel as well as different timing of backpressure to the kernel.

On your Development Instance, build the host application and Amazon FPGA Image (AFI) that the host application will load onto the FPGA. But it would take close to an hour to build the AFI, so below, we are specifying `PREBUILT=true` to utilize a prebuilt public AFI referenced in the repository.

```sh
cd ~/1st-CLaaS/apps/mandelbrot/build
make PREBUILT=true launch   # Note: Since this instance supports TARGET=hw_emu, this mode will be the default.
```

This produces output files in `../out/hw_emu/xilinx_aws-vu47p-f2/`, and it starts the application.

Reload `http://<IP>:8888` in your browser (with `<Ctrl>-F5` in Chrome and Firefox). This mode runs about two orders of magnitude slower than simulation mode, so be careful not to ask it to do too much. Make the image small, and set the depth to be minimal before selecting "FPGA" rendering.

`<Ctrl>-C` to stop the web server.

**Stop the instance** in the EC2 Console (under "Running Instances", select the running instance, and under "Actions"::"Instance State", choose "Stop", and confirm).

If you had been doing actual development, and you were ready to run on F2, you would commit your work and prebuilt AFI by running:

```sh
make prebuild
git commit ...
git push   # If not to master, you would pull from corresponding branch on F1 instance.
```

> Note: Sourcing `vitis_setup` currently breaks `git gui` and `gitk`, so use these in a separate shell without `vitis_setup`.


# Note: The commands given below do not work on F2 instances.

<a name="FPGABuild"></a>
# FPGA Build

If you have gotten approval from Amazon, you can now run on an actual FPGA if you would like to see Mandelbrot at full speed. There is little risk of encountering issues at this point, so F1 is generally needed for deployment or testing at production speeds only.

```sh
make ssh INSTANCE_NAME=<name> SSH_CMD="'source ~/1st-CLaaS/vitis_setup && cd ~/1st-CLaaS/apps/mandelbrot/build && make launch PREBUILT=true'"   # TARGET=hw is the default on F1.
```
**NOTE** : The first quotes of the command gets ignored. If you face any issue running the SSH_CMD, it would be better to `make ssh` into the instance and run the command manually.

As before, open `http://<IP>:8888` in your browser (using the new IP). Now you can select renderer "FPGA", and navigate at FPGA speed. (Try "velocity" nagivation mode.)

When you are done, `<Ctrl>-C`, and **stop your instance**.

> **Note:** Vitis-based AFI generation is **not currently supported** on AWS F2 instances. As a result, a full hardware (`hw`) target build and run on F2 is not possible at this time. For the latest status and updates on F2 Vitis support, see the [AWS FPGA F2 Vitis Documentation](https://awsdocs-fpga-f2.readthedocs-hosted.com/latest/vitis/README.html). Until Vitis support is available for F2, development is limited to hardware emulation (`hw_emu`) mode on a Development Instance as described above.
