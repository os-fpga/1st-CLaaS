# Extends framework Makefile with mandelbrot-specific stuff.
# See framework/build/Makefile for usage info.

ADDITIONAL_SRC=$(HOST_DIR)/mandelbrot_main.cpp  # Provided as additional source to allow for other projects to provide a different main.

PROJ_C_SRC=$(HOST_DIR)/mandelbrot.c $(HOST_DIR)/lodepng.c $(ADDITIONAL_SRC)
PROJ_C_HDRS=$(HOST_DIR)/mandelbrot.h $(HOST_DIR)/lodepng.h

HW_SHELL_CONFIG_JSON=../fpga/shell_config.json

KERNEL=mandelbrot


include ../../../framework/build/Makefile
