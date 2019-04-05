# Extends framework Makefile with mandelbrot-specific stuff.
# See framework/build/Makefile for usage info.

##########
# TODO: Eliminate lodepng here.
PROJ_C_SRC=$(FRAMEWORK_HOST_DIR)/default_main.c ../../mandelbrot/host/lodepng.c
PROJ_C_HDRS=
PROJ_C_HDRS=../../mandelbrot/host/lodepng.h
PROJ_SW_CFLAGS=-I../../mandelbrot/host
##########

HW_SHELL_CONFIG_JSON=../../../framework/fpga/default_shell_config.json

KERNEL=vadd


include ../../../framework/build/Makefile
