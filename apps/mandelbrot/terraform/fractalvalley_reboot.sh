#!/bin/bash

# This script is run by terriform on initialization to pre-build, and configured to run by cron @reboot to automatically start the webserver.
# Usage: $0:     Run in foreground (for both use cases)
#        $0 '&': Run webserver in background (for no use cases).
# Cron output is sent to /var/spool/mail/root.
# Running via ssh establishes the proper environment.
echo "$0: Output logged in: /home/centos/src/project_data/fpga-webserver/apps/mandelbrot/build/make.log"
ssh -o 'StrictHostKeyChecking no' localhost 'cd ~/src/project_data/fpga-webserver && source ./sdaccel_setup && cd apps/mandelbrot/build && (make TARGET=hw PREBUILT=false live &> make.log < /dev/null $1)'
