# Extends framework Makefile with mandelbrot-specific stuff.
# See framework/build/Makefile for usage info.

KERNEL=matrix_mult

##########
# TODO: Eliminate lodepng here.
EXTRA_C_SRC=$(FRAMEWORK_HOST_DIR)/default_main.c ../../mandelbrot/host/lodepng.c
EXTRA_C_HDRS=../../mandelbrot/host/lodepng.h
PROJ_SW_CFLAGS=-I../../mandelbrot/host
##########

HW_SHELL_CONFIG_JSON=../../../framework/fpga/default_shell_config.json


include ../../../framework/build/Makefile
