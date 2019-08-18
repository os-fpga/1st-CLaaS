#!/bin/bash
#sudo yum -y update   # This takes forever, but without it, there is a dependency issue.
sudo yum install -y xrdp --enablerepo=cr
wget https://s3.amazonaws.com/aws-fpga-developer-ami/1.5.0/Scripts/setup_gui.sh -P /tmp/
chmod +x /tmp/setup_gui.sh
sed -i 's|^setup_password$|#setup_password' /tmp/setup_gui.sh
/tmp/setup_gui.sh
