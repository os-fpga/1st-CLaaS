#!/bin/bash

vivado -mode batch -source script.tcl
cd sdx_imports

make build TARGET=hw_emu KERNEL=mandelbrot
#xdg-open mandelbrot.ppm
