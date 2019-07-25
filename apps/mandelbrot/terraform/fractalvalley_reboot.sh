#!/bin/bash

# This script is run by terriform on initialization to pre-build, and configured to run by cron @reboot to automatically start the webserver.
# Cron output is sent to /var/spool/mail/root.
# Running via ssh establishes the proper environment.
WEBSERVER_LOG='/home/centos/src/project_data/fpga-webserver/apps/mandelbrot/build/webserver.log'
PASSWORD_ARG=$(if [[ -e "$passwd_file" ]]; then echo PASSWORD=$(cat "$passwd_file"); fi)
PREBUILT=true

SSH_CMD='cd ~/src/project_data/fpga-webserver && source ./sdaccel_setup && cd apps/mandelbrot/build'
SSH_CMD="$SSH_CMD && make PREBUILT=$PREBUILT build && echo '$0: Going live with webserver with output in: $WEBSERVER_LOG'"
SSH_CMD="$SSH_CMD && make PREBUILT=$PREBUILT $PASSWORD_ARG live"
ssh -o 'StrictHostKeyChecking=no' localhost "$SSH_CMD"
