# Extends framework Makefile with mandelbrot-specific stuff.
# See framework/build/Makefile for usage info.

ADDITIONAL_SRC=    #$(HOST_DIR)/_main.cpp  # Provided as additional source to allow for other projects to provide a different main.

PROJ_C_SRC=$(HOST_DIR)/vadd.c $(ADDITIONAL_SRC)
PROJ_C_HDRS=     # $(HOST_DIR)/mandelbrot.h $(HOST_DIR)/lodepng.h

HW_SHELL_CONFIG_JSON=../../../framework/fpga/default_shell_config.json

KERNEL=vadd


include ../../../framework/build/Makefile
