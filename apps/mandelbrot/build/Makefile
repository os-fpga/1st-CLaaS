# Extends framework Makefile with mandelbrot-specific stuff.
# See framework/build/Makefile for usage info, with the following additions:
#   To associate F1, use:
#      make INSTANCE=i-xxxxxxx PASSWORD=<password> PROFILE=<aws-profile> ...

PROJ_C_SRC=$(HOST_DIR)/mandelbrot.c $(HOST_DIR)/lodepng.c $(HOST_DIR)/mandelbrot_main.cpp
PROJ_C_HDRS=$(HOST_DIR)/mandelbrot.h $(HOST_DIR)/lodepng.h

HW_SHELL_CONFIG_JSON=../../../framework/fpga/default_shell_config.json

KERNEL=mandelbrot

SERVER_ARGS :=
ifdef INSTANCE
  SERVER_ARGS :=$(SERVER_ARGS) --instance $(INSTANCE)
endif
ifdef PASSWORD
  SERVER_ARGS :=$(SERVER_ARGS) --password $(PASSWORD)
endif
ifdef PROFILE
  SERVER_ARGS :=$(SERVER_ARGS) --profile $(PROFILE)
endif


LAUNCH_W :=python ../webserver/mandelbrot_server.py --port=<<PORT>> $(SERVER_ARGS)

include ../../../framework/build/Makefile
