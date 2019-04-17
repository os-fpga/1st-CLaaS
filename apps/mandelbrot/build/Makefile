# Extends framework Makefile with mandelbrot-specific stuff.
# See framework/build/Makefile for usage info.

PROJ_C_SRC=$(HOST_DIR)/mandelbrot.c $(HOST_DIR)/lodepng.c $(HOST_DIR)/mandelbrot_main.cpp
PROJ_C_HDRS=$(HOST_DIR)/mandelbrot.h $(HOST_DIR)/lodepng.h
PROJ_FPGA_EXTRA_SRCS=../fpga/src/clk_gate.vs ../fpga/src/mandelbrot_kernel_gen.vh ../fpga/src/sandpiper_gen.vh ../fpga/src/sandpiper.vh ../fpga/src/sp_default.vh

HW_SHELL_CONFIG_JSON=../../../framework/fpga/default_shell_config.json

KERNEL=mandelbrot


include ../../../framework/build/Makefile



# A target to run SandPiper to make mandelbrot_kernel*.
# This target must be run in isolation. It does not carry proper dependencies intentionally
# so that SandPiper installation is not required, and mandelbrot_kernel* can be treated as source code
# for other build targets.
PHONY: sv
sv:
	sandpiper --iArgs --m4out /tmp/mandelbrot.m4out.tlv -i ../fpga/mandelbrot.tlv -o ../fpga/src/mandelbrot_kernel.sv
	# Vivado requires includes to be of .vh files, so change file name.
	mv ../fpga/src/mandelbrot_kernel_gen.sv ../fpga/src/mandelbrot_kernel_gen.vh
	sed -i s/mandelbrot_kernel_gen\\.sv/mandelbrot_kernel_gen\\.vh/ ../fpga/src/mandelbrot_kernel.sv