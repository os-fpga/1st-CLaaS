#!/bin/sh

cd /home/centos
export FPGA_WEBSERVER_DIR=/home/centos/src/project_data/fpga-webserver


# Pull or clone $AWS_FPGA_REPO_DIR
if [[ -d $AWS_FPGA_REPO_DIR ]]; then
	echo "Pulling AWS-FPGA"
	git pull
else
	echo "Cloning AWS-FPGA"
	git clone https://github.com/aws/aws-fpga.git $AWS_FPGA_REPO_DIR
fi
echo "Sourcing sdaccel_setup.sh"
source $AWS_FPGA_REPO_DIR/sdaccel_setup.sh


# Pull or clone $AWS_WEBSERVER_DIR
if [[ -d $FPGA_WEBSERVER_DIR ]]; then
	echo "Pulling FPGA-WEBSERVER"
	git pull
else
	echo "Cloning FPGA-WEBSERVER"
	git clone https://github.com/alessandrocomodi/fpga-webserver.git $FPGA_WEBSERVER_DIR
	echo "Sourcing init"
	source $FPGA_WEBSERVER_DIR/init
fi
echo "Sourcing sdaccel_setup"
source $FPGA_WEBSERVER_DIR/sdaccel_setup
