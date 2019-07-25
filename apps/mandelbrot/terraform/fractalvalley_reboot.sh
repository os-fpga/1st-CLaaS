#!/bin/bash

# This script is run by terriform on initialization to pre-build, and configured to run by cron @reboot to automatically start the webserver.
# Cron output is sent to /var/spool/mail/root.
# Running via ssh establishes the proper environment.
ssh -o 'StrictHostKeyChecking no' localhost 'cd ~/src/project_data/fpga-webserver && source ./sdaccel_setup && cd apps/mandelbrot/build && make PREBUILT=false build && echo "$0: Going live with webserver with output in: /home/centos/src/project_data/fpga-webserver/apps/mandelbrot/build/webserver.log" && (make PREBUILT=false live &> webserver.log < /dev/null &)'
