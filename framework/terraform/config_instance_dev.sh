#!/usr/bin/bash

# An EC2 instance configuration script for a development instance.
# It sets up RDP.

# TODO: This setup_gui.sh script is currently broken, apparently due to:
# https://bugzilla.redhat.com/show_bug.cgi?id=1738669
# Hoping this resolves itself soon enough.
#wget https://s3.amazonaws.com/aws-fpga-developer-ami/1.5.0/Scripts/setup_gui.sh -P /tmp/
#chmod +x /tmp/setup_gui.sh
#sed -i 's|^setup_password$|#setup_password|' /tmp/setup_gui.sh
#/tmp/setup_gui.sh
