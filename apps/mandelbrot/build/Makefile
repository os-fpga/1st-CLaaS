# Extends framework Makefile with mandelbrot-specific stuff.
# See framework/build/Makefile for usage info.

PROJ_C_SRC=$(HOST_DIR)/mandelbrot.c $(HOST_DIR)/lodepng.c $(HOST_DIR)/mandelbrot_main.cpp
PROJ_C_HDRS=$(HOST_DIR)/mandelbrot.h $(HOST_DIR)/lodepng.h

HW_SHELL_CONFIG_JSON=../../../framework/fpga/default_shell_config.json

KERNEL=mandelbrot


include ../../../framework/build/Makefile
