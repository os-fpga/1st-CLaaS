#!/bin/bash
wget https://s3.amazonaws.com/aws-fpga-developer-ami/1.5.0/Scripts/setup_gui.sh -P /tmp/
chmod +x /tmp/setup_gui.sh
source /tmp/setup_gui.sh
echo "${CENTOS_PWD}" > centos_pwd.txt