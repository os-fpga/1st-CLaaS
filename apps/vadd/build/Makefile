# Extends framework Makefile with mandelbrot-specific stuff.
# See framework/build/Makefile for usage info.

##########
# TODO: lodepng.[c/h] is used in framework. Use should be moved to mandelbrot.
EXTRA_C_SRC=$(FRAMEWORK_HOST_DIR)/default_main.c ../../mandelbrot/host/lodepng.c
EXTRA_C_HDRS=../../mandelbrot/host/lodepng.h
PROJ_SW_CFLAGS=-I../../mandelbrot/host
##########


include ../../../framework/build/Makefile
