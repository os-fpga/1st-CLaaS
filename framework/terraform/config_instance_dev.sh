#!/bin/bash
sudo yum -y update   # This takes forever, but without it, there is a dependency issue.
wget https://s3.amazonaws.com/aws-fpga-developer-ami/1.5.0/Scripts/setup_gui.sh -P /tmp/
chmod +x /tmp/setup_gui.sh
source /tmp/setup_gui.sh
echo "${CENTOS_PWD}" > centos_pwd.txt