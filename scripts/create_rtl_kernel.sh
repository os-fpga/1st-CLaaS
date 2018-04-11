#!/bin/bash

# 
# Script that authomatically generates a new RTL project to insert a custom HDL kernel
# The user has to modify the generated files in order to fit the HDL kernel inside of the
# communication infrastracture (AXI Master)
#

if [[ -z "${LIB_DIR}"  ]]; then
    echo "Usage: export default directory with the scripts in LIB_DIR environment variable"
    exit -1
fi

if [[ -z "${1}" || -z "${2}" || -z "${3}" ]]; then
    echo "Usage:"
    echo "  - first argument    --> kernel name"
    echo "  - second argument   --> workspace directory"
    echo "  - third argument    --> json file containing kernel configuration"
    exit -1
fi

# Creating tcl script for the kernel configuration
# The third argument contains the JSON description of the core that has to be implemented.
python $LIB_DIR/src/produce_tcl_file.py $3

# Creating the rtl kernel wizard project
vivado -mode batch -nojournal -nolog -notrace -source $LIB_DIR/src/tcl/rtl_kernel_wiz.tcl -tclargs $1 $2

# Moving the Makefile necessary for Hardware emulation and build into the sdx_imports directory
cp $LIB_DIR/src/Makefile $2/${1}_ex/sdx_imports/
