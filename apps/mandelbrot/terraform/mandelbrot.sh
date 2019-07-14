#!/bin/sh

(cd /home/centos/src/project_data/fpga-webserver/apps/mandelbrot/build && make TARGET=sw PORT=80 PREBUILT=true launch_nohup && ./start_feeder)
