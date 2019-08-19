#!/bin/bash
wget https://s3.amazonaws.com/aws-fpga-developer-ami/1.5.0/Scripts/setup_gui.sh -P /tmp/
chmod +x /tmp/setup_gui.sh
sed -i 's|^setup_password$|#setup_password|' /tmp/setup_gui.sh
/tmp/setup_gui.sh
