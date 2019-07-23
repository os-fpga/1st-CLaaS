#!/bin/bash

# This script is run by cron @reboot to automatically start the webserver.
# Output is sent to /var/spool/mail/root.
# Running via ssh establishes the proper environment.
echo "$0: Output logged in: /home/centos/src/project_data/fpga-webserver/apps/mandelbrot/build/make.log"
ssh localhost 'cd ~/src/project_data/fpga-webserver && source ./sdaccel_setup && cd apps/mandelbrot/build && (make TARGET=hw PREBUILT=true live &> make.log < /dev/null &)'
