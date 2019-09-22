#!/usr/bin/bash

# This script starts or restarts the webserver (using 'make live') based on configuration variables saved by Terraform. It is run by Terraform on initialization,
# and terraform configures cron to run this @reboot.
# Cron output is sent to /var/spool/mail/root.
# Running via ssh establishes the proper environment.
# TODO: Look into EC2 user_data or cloud-init to replace this mechanism.
source /home/centos/server_config.sh
WEBSERVER_LOG="/home/centos/src/project_data/fpga-webserver/apps/$KERNEL_NAME/build/webserver.log"
PASSWORD_ARG=$(if [[ -n "$ADMIN_PWD"        ]]; then echo PASSWORD=$ADMIN_PWD;        fi)
PREBUILT_ARG=$(if [[ -n "$USE_PREBUILT_AFI" ]]; then echo PREBUILT=$USE_PREBUILT_AFI; fi)

SSH_CMD="cd ~/src/project_data/fpga-webserver && source ./sdaccel_setup && cd apps/$KERNEL_NAME/build"
SSH_CMD="$SSH_CMD && make $PREBUILT_ARG $PASSWORD_ARG build && echo '$0: Going live with web server with output in: $WEBSERVER_LOG'"
SSH_CMD="$SSH_CMD && make $PREBUILT_ARG $PASSWORD_ARG live"
ssh -o 'StrictHostKeyChecking=no' localhost "$SSH_CMD"
