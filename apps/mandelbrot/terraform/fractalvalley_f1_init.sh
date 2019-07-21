#!/bin/sh

# Initialization script for fractalvalley F1 server.
# Compile and start webserver for manual testing at <IP>:80.
# If all's well, manually rename server to "fractalvalley.net-F1" and this will be the server used by fractalvaalley.net.
(echo && echo "Running fractalvalley_f1_init.sh" && echo && cd /home/centos/src/project_data/fpga-webserver && source ./sdaccel_setup && echo && echo "Done SDAccel Setup" && echo && cd apps/mandelbrot/build && make TARGET=hw PREBUILT=true live && echo && echo "Done $0" && echo)
