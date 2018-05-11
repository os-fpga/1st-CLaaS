# fpga-webserver

This project provides a communication layer between web applications and Cloud FPGA accelerators in order to enhance the performance of compute-intensive tasks. Further documentation for this project, including the project vision, can be found in this [Google Drive Folder](https://drive.google.com/drive/folders/1EdhyuvQmIN18YxHsRkTGffVvuAwmHfkJ?usp=sharing). This project utilizes Amazon AWS F1 instances and the corresponding Xilinx tools (Vivado, SDAccel).

While the layer is intended to be generic, in its current form, this repo contains both generic functionality and components that are specific to the initial demonstration application -- a Mandelbrot image generator.

The files are organized in the following folders:
  - `srcs`: contains source code for:
    1. Web Client: a simple Mandelbrot web client needed for testing purposes
    2. Web Server: a web server written in Python
    3. Host Application: the host Mandelbrot application written in C and OpenCL which interfaces with the hardware.
  - `scripts`: utility scripts needed to create a Vivado RTL project that holds all the configurations (e.g. # AXI master ports, # scalar arguments, # arguments) for the hardware.
  - `hw`: the hardware project of the Mandelbrot example.


# Project description

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


# Project Setup

To get up and running from source code, you will need to:
  - Get an AWS account with access to F1 instances.
  - Launch a "Build Instance" on which to compile the OpenCL, Verilog, and Transaction-Level Verilog source code into an FPGA image.
  - Launch an "F1 Server Instance" on which to run: the web server, the Host Application, and the FPGA programmed with the image you created on the Build Instance.
  - Open the Web Application in a local web browser (or host it on a web server) and connect to the running Web Server.

Note that F1 machines are powerful and expensive. Compilations take several hours and require a sizable Build Instance which can cost a few dollars per compilation. F1 machines cost about $1.50/hr, so it is not practical to keep a server up and running for extended periods.


# Installation

## AWS Account with F1 access

Instructions can be found <a href="https://github.com/aws/aws-fpga/blob/master/SDAccel/README.md#iss" target="_ blank">here</a>.

If you are new to AWS, you might find it to be quite complicated. Here are some specific steps to get you going, though they likely need refinement. Be sure to correct these docs based on your experience.
  - Create a <a href="https://aws.amazon.com/free/" target="_ blank">free tier account</a> and await approval.
  - Login to your console. Be sure you are logging in as root, not as an AIM user. (Your account has no "AIM" users until you create them (which is not necessary to get going).)
  - Now, you'll need access to F1 resources (and possibly the Amazon Machine Image (AMI) for the Build Instance). Unless policies change, you must apply for this. You can try skipping ahead to confirm.
    - Under "Support" (upper left) open "Support Center".
    - Create a case.
      - Regarding: "Service Limit Increase".
      - Limit Type: "EC2 Instances"
      - Region: "N. Virginia" (and possibly other options)
      - Primary Instance Type: "f1.2xlarge"
      - Use Case Description: Something like, "Development of hardware-accelerated web applications using this framework (https://github.com/alessandrocomodi/fpga-webserver)"
      - Wait ~2 business days :(


## AWS Build Instance Setup

Now let's provision a Build Instance on which you can build your Amazon FPGA Image (AFI).
  - From the dashboard, click "Launch Instance".
  - Click "AWS Marketplace" on the left.
  - Enter "FPGA" in the search box.
  - "Continue".
  - Select c4.4xlarge (as recommended by Amazon, or we have found c4.2xlarge to suffice, though slower).
  - Click through default options to launch.
  - (SSH key instructions here)
  - `chmod 600 ~/.ssh/AWS_<my_machine>.pem`
  - Click new instance link (never to be able to return?) to find IP address.
  - `ssh -i ~/.ssh/<AWS_my_machine>.pem centos@<ip>`

If all went well, you are now logged into your Build Instance.

The AWS F1 instance has to allow TCP connections on ports 8080 and 8888 (or the one you choose to serve the get or websocket requests):
  1. Go to the EC2 Dashboard.
  1. On the left, under "Network & Security", click on "Security Group".
  1. Select the one related to your F1 instance.
  1. Go to the "Inbound" tab and click on "Edit".
  1. "Add".
  1. Select "Custom TCP Rule" as "Type" and insert "8080" as port range.
  1. Provide "Source" as the IP from which you will launch your client, or leave it as zeros to allow any IP to connect.
  1. You can set "Description" to "webserver".
  1. Save
  1. Repeat for port 8888.

## FPGA Build Process

First, clone this GitHub repository and the aws-fpga GitHub repository and source the sdaccel_setup.sh script

```sh
cd
git clone https://github.com/alessandrocomodi/fpga-webserver
git clone https://github.com/aws/aws-fpga.git $AWS_FPGA_REPO_DIR  
cd $AWS_FPGA_REPO_DIR
source ./sdaccel_setup.sh
```

Once the environment is set up copy the "mandelbrot_hw" folder into your workspace and build:

```sh
cd
mkdir work
cd work
cp -r ~/fpga-webserver/hw/mandelbrot_hw .
cd mandelbrot_hw/sdx_imports
make build TARGET=hw KERNEL=mandelbrot -j8 > out.txt &
```

Once the build process is complete you can generate an Amazon FPGA Image to load onto the FPGA.
First you have to setup your AWS CLI and the S3 Bucket where to save the generated files:

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
$SDACCEL_DIR/tools/create_sdaccel_afi.sh -xclbin=../mandelbrot_hw/sdx_imports/hw/xilinx_aws-vu9p-f1_4ddr-xpr-2pr_4.0/mandelbrot.xclbin -o=mandelbrot \
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

## F1 Instance Setup

You will need an F1 machine (w/ an FPGA) on which to run the files you have generated.

Create this machine as you did the Build Instance, but use instance type "f1.2xlarge" (in North Virginia).


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

Now, you can run the server. You need access to two different terminals, one to run the server and one to run the host application. (Can't we run them in the background??)

Run the host application and the listening socket:
terminal run the following commands:

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
sudo python2.7 server_v2.py
```

You can access client.html from any web browser using `http://<IP>:8888/client.html`.

Current usage of client.html requires: host IP, click "Open", click "Init FPGA", enter coords, like 0, 0, zoom: 1, depth 100, "GET IMAGE" or "Start".

You can run the Mandelbrot explorer from any web browser using `http://<IP>;8888/index.html`.


# Makerchip and TL-Verilog

The Mandelbrot set accelerator has been developed in the [Makerchip](https://makerchip.com/) IDE using the TL-Verilog language extension.
After the kernel has been designed in Makerchip we retrieved the Verilog files by clicking on "E" -> "Open Results" in the Editor tab. From the new browser tab the files that host the Verilog code are called "top.sv" and "top_gen.sv".
The content of these files has to be copied and pasted inside of the file "mandelbrot_example_adder.sv" found in the "mandelbrot_hw/imports" folder.
# To Do

Make instructions more explicit, as a cookbook recipe, and provide information and pointers about the more general use of the commands. After this provide other helpful general information about working with the design. New users should walk through the cookbook as quickly as possible, then learn more about what they have done.
  - Choose specific file/folder names, and stick with them.
  - Create small scripts to further automate. Scripts should be useful in production use, not just for cookbook, otherwise we're hiding useful information.
  - Probably want to use workspace folders inside this with .gitignored contents, so this repo can provide work structure.
  - Structure the repo to support multiple examples, where mandelbrot is one.
  - Automate export from Makerchip by providing a script that uses `curl` to access result files via `http://makerchip.com/compile/<compile-id>/results/<filename>`.


# X11 Forwarding

It's important to be able to run X11 applications on your instance and display them on your machine. Unfortunately I got a `DISPLAY not set` message when first trying `ssh -X`. I was able to get this to work with help from <a href="https://forums.aws.amazon.com/thread.jspa?messageID=574740" target="_ blank">this post</a> though I'm not sure exactly what did the trick.
