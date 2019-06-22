#!/bin/sh

cd /home/centos
export FPGA_WEBSERVER_DIR=/home/centos/src/project_data/fpga-webserver
if [[ -d $AWS_FPGA_REPO_DIR ]]; then
	echo "Pulling AWS-FPGA"
	git pull
	echo "Sourcing sdaccel_setup.sh"
	source $AWS_FPGA_REPO_DIR/sdaccel_setup.sh
else
	echo "Cloning AWS-FPGA"
	git clone https://github.com/aws/aws-fpga.git $AWS_FPGA_REPO_DIR  
	echo "Sourcing sdaccel_setup.sh"                                         
	source $AWS_FPGA_REPO_DIR/sdaccel_setup.sh
fi


if [[ -d $FPGA_WEBSERVER_DIR ]]; then
	echo "Pulling FPGA-WEBSERVER"
	git pull
	echo "Sourcing installs.sh"
	source $FPGA_WEBSERVER_DIR/installs.sh
	echo "Sourcing sdaccel_setup"
	source $FPGA_WEBSERVER_DIR/sdaccel_setup
else
	echo "Cloning FPGA-WEBSERVER"
	git clone -b terraform-devel https://github.com/alessandrocomodi/fpga-webserver.git $FPGA_WEBSERVER_DIR
	cd $FPGA_WEBSERVER_DIR && git submodule update --init --recursive  # or ./init
	echo "Sourcing installs.sh"
	source $FPGA_WEBSERVER_DIR/installs.sh
	echo "Sourcing sdaccel_setup"
	source $FPGA_WEBSERVER_DIR/sdaccel_setup
fi


