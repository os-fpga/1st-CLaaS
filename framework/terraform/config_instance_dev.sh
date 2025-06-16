#!/usr/bin/bash

# An EC2 instance configuration script for a development instance.
# It sets up RDP.

# TODO: This setup_gui.sh script is currently broken, apparently due to:
# https://bugzilla.redhat.com/show_bug.cgi?id=1738669
# Hoping this resolves itself soon enough.

#The given below script is no longer supported as it uses centos and aws instance that we use shifted to ubuntu
#wget https://s3.amazonaws.com/aws-fpga-developer-ami/1.5.0/Scripts/setup_gui.sh -P /tmp/ 

#chmod +x /tmp/setup_gui.sh
#sed -i 's|^setup_password$|#setup_password|' /tmp/setup_gui.sh
#/tmp/setup_gui.sh
# TODO:
#echo 'We have not enabled password authentication, so you will need to do that.'

# Old Script ends here
## New script for trial purposes

#!/usr/bin/env bash
set -e

# An EC2 instance configuration script for a development instance.
# It runs your local setup_gui.sh (which must be in the same directory).

# Determine the directory this script lives in
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

LOCAL_SETUP="$SCRIPT_DIR/setup_gui_trial.sh"

if [[ ! -f "$LOCAL_SETUP" ]]; then
  echo >&2 "ERROR: cannot find $LOCAL_SETUP - put your updated setup_gui.sh alongside this script."
  exit 1
fi

chmod +x "$LOCAL_SETUP"
echo "Running local GUI setup script: $LOCAL_SETUP"
"$LOCAL_SETUP"

echo
echo "Reminder: if you need password-auth over SSH, make sure to enable it in /etc/ssh/sshd_config and restart sshd."