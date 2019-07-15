#!/bin/sh

# Initialization script for fractalvalley F1 server.
# Compile and start webserver for manual testing at <IP>:80.
# If all's well, manually rename server to "fractalvalley.net-F1" and this will be the server used by fractalvaalley.net.
(cd /home/centos/src/project_data/fpga-webserver/apps/mandelbrot/build && make TARGET=hw PORT=80 PREBUILT=true launch_nohup)
