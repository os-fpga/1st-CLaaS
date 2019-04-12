# Extends framework Makefile with mandelbrot-specific stuff.
# See framework/build/Makefile for usage info.

PROJ_C_SRC=$(HOST_DIR)/mandelbrot.c $(HOST_DIR)/lodepng.c $(HOST_DIR)/mandelbrot_main.cpp
PROJ_C_HDRS=$(HOST_DIR)/mandelbrot.h $(HOST_DIR)/lodepng.h
PROJ_FPGA_EXTRA_SRCS=../fpga/src/clk_gate.vs ../fpga/src/mandelbrot_kernel_gen.vh ../fpga/src/sandpiper_gen.vh ../fpga/src/sandpiper.vh ../fpga/src/sp_default.vh

HW_SHELL_CONFIG_JSON=../../../framework/fpga/default_shell_config.json

KERNEL=mandelbrot


include ../../../framework/build/Makefile
