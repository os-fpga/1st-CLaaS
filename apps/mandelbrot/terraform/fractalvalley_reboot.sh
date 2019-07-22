#!/bin/bash

# This script is run by cron @reboot to automatically start the webserver.
cd /home/centos/src/project_data/fpga-webserver && source ./sdaccel_setup && cd apps/mandelbrot/build && /usr/bin/make TARGET=hw PREBUILT=true live &> make.log &
