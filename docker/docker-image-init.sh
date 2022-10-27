#!/bin/bash
echo "Cloning 1st-CLaaS repo..."
git clone https://github.com/stevehoover/1st-CLaaS
cd 1st-CLaaS
echo "Instaling verilator..."
./bin/install_verilator
echo "Initializing 1st-CLaaS..."
./init
echo "Running Mandelbrot example..."
cd apps/mandelbrot/build
make launch
