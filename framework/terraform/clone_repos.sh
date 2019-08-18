#!/bin/sh

# Run on the EC2 instance to clone (or pull) aws-fpga and 1st-CLaaS repos.

cd /home/centos
export FPGA_WEBSERVER_DIR=/home/centos/src/project_data/fpga-webserver


# Pull or clone $AWS_FPGA_REPO_DIR
if [[ -d "$AWS_FPGA_REPO_DIR" ]]; then
	echo "Pulling AWS-FPGA"
	git pull
else
	echo "Cloning AWS-FPGA (quietly)"
	git clone https://github.com/aws/aws-fpga.git "$AWS_FPGA_REPO_DIR" > /dev/null
fi
#echo "Sourcing sdaccel_setup.sh"
#source $AWS_FPGA_REPO_DIR/sdaccel_setup.sh


# Pull or clone $AWS_WEBSERVER_DIR
if [[ -d "$FPGA_WEBSERVER_DIR" ]]; then
	echo "Pulling FPGA-WEBSERVER"
	git pull
else
	echo "Cloning FPGA-WEBSERVER (quietly)"
	git clone https://github.com/alessandrocomodi/fpga-webserver.git "$FPGA_WEBSERVER_DIR" > /dev/null
	echo "Running init"
	"$FPGA_WEBSERVER_DIR/init"
fi
#echo "Sourcing sdaccel_setup"
#source $FPGA_WEBSERVER_DIR/sdaccel_setup
