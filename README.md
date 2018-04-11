# fpga-webserver

This project targets the problem of creating a communication layer between Web Applications and Clous FPGA accelerators in order to enhance the performance of compute-intensive tasks.

The files are organized as follows:
  - srcs: this folder contains software needed to perform the communication. It includes a webserver written in python, a simple web-client needed for testing purposes and the host application written in C and OpenCL which interfaces with the hardware.
  - scripts: this folder contains utility scripts needed to create a Vivado RTL project that holds all the configurations (e.g. # AXI master ports, # scalar arguments, # arguments) for the hardware.
  - hw: this folder contains the hardware project of the first example. We have implemented a Mandelbrot set hardware accelerator that provides images of the Mandelbrot set.

As Cloud FPGA platform we have adopted the AWS F1 instances and the tools (Vivado, SDAccel) and hardware are provided by Xilinx.

# Project description

The communication of data and commands between the Web Application and the FPGA happens in three different steps:

  1) The WebClient performs a WebSocket connection or a Get request to the WebServer. The WebSocket requests have to be in JSON format and contain two different fileds:
    - type: describes the command that has to be performed by the host application and dispatched to the FPGA;
    - data: holds the data to be sent to the FPGA.
  2) The WebServer intercepts all the requests coming from the WebClient and, through a UNIX socket link passes all the requests to the Host Application which will analyses the content of the message and performs the dedicated function.
  3) The Host Application interfaces with the FPGA through OpenCL calls. Once the calls have been performed the host application waits for the results and sends the response back to the Web Application following the same path.

# Prerequisites

In order to test the infrastructure the following prerequisites are needed:
  - AWS account, and accessibility to AWS F1 instances.
  - On the AWS EC2 instance:
    - Python 2.7 or higher;
    - tornado python library

        sudo pip install tornado

  - The AWS F1 instance has to allow TCP connections on port 8080 (or the one you choose to serve the get or websocket requests):
    1) Go to the EC2 Dashboard;
    2) Click on "Security Group";
    3) Select the one related to your F1 instance;
    4) Go to the "Inbound" tab and click on "Edit";
    5) Select "Custom TCP Rule" as "Type" and insert 8080 as port range.
    6) Save

# Kernel implementation steps

The hardware provided is ready to be implemented on an AWS EC2 FPGA instance. Be sure that the instance is one of those found in the FPGA Developer AMI from the AWS Marketplace.

First of all clone the aws-fpga GitHub repository and source the sdaccel_setup.sh script
  

    $ git clone https://github.com/aws/aws-fpga.git $AWS_FPGA_REPO_DIR  
    $ cd $AWS_FPGA_REPO_DIR                                         
    $ source sdaccel_setup.sh


Once the environment is setup copy the "mandelbrot_hw" folder in your workspace.
Enter in the "sdx_imports" folder and run the following make command:


    make build TARGET=hw KERNEL=mandelbrot -j8 > out.txt &


Once the build process is complete you can generate an Amazon FPGA Image to load onto the FPGA.
First you have to setup your AWS CLI and the S3 Bucket where to save the generated files:

AWS CLI configuration:

     $ aws configure         # to set your credentials (found in your console.aws.amazon.com page), region (us-east-1) and output (json) 


S3 Bucket creation:

      $ aws s3 mb s3://<bucket-name> --region us-east-1  # Create an S3 bucket (choose a unique bucket name)
      $ aws s3 mb s3://<bucket-name>/<dcp-folder-name>   # Create folder for your tarball files
      $ touch FILES_GO_HERE.txt                          # Create a temp file
      $ aws s3 cp FILES_GO_HERE.txt s3://<bucket-name>/<dcp-folder-name>/  # Which creates the folder on S3


Once the setup is complete you can generate the .awsxclbin binary file that will configure the FPGA:


    $ mkdir build
    $ cd build
    $ $SDACCEL_DIR/tools/create_sdaccel_afi.sh -xclbin=<input_xilinx_fpga_binary_xclbin_filename> 
                -o=<output_aws_fpga_binary_awsxclbin_filename_root> \
                -s3_bucket=<bucket-name> -s3_dcp_key=<dcp-folder-name> -s3_logs_key=<logs-folder-name>


When the process completes you will have at disposal the bitstream configuration file ready to use.

# Host files compilation

The host program is needed to interface with the FPGA.
Copy all files from the "host_app" folder in a new one and run the following command:


     $ make host TARGET=hw_emu KERNEL=mandelbrot


This will compile the host application and you can find the executable in the "hw/xilinx_aws-vu9p-f1_4ddr-xpr-2pr_4.0/" folder.

# Web server usage

Once you have both the executable and the FPGA Image you can run the server.

You need to access to two different terminals, one to run the server and one to run the host application.
  - First is best to move both the python files found in the "web_server" folder, the executable and the .awsxclbin image into the same folder.
  - On one terminal run the following commands:

      $ cd $AWS_FPGA_REPO_DIR
      $ source sdaccel_setup.sh
      $ sudo sh
      $ source /opt/Xilinx/SDx/2017.1.rte.4ddr/setup.sh   # Use 2017.1.rte.1ddr or 2017.1.rte.4ddr_debug when using AWS_PLATFORM_1DDR or AWS_PLATFORM_4DDR_DEBUG. Other runtime env settings needed by the host app should be setup after this step
      $ ./host mandelbrot.awsxclbin mandelbrot

  These will run the host application and create the SOCKET communication
  - On the second terminal run the WebServer:

      $ sudo sh
      $ python2.7 server.py

Now you can access the server through the WebClient in the web_client folder
