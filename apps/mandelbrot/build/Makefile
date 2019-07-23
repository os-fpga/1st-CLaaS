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


# Make a new static EC2 F1 instanace to be used by Mandelbrot content webserver to serve fractals.
# WARNING: This target launches a new instance. Be sure it is not left running!
# Specify:
#   TF_ARGS: (opt) Additional arguments for Terraform. These should provide AWS credentials and admin_pwd variable. See Usage below.
#            (You'll be prompted for unspecified variables.)
#   EC2_TYPE: Use c4 for testing without FPGA.
# Usage:
#    make f1_instance PASSWORD=funkytown "TF_ARGS=-var-file=$HOME/aws_cred.tfvars"
TF_ARGS=
EC2_TYPE=f1
ifdef PASSWORD
  ADMIN_PWD=-var 'admin_pwd=$(PASSWORD)'
endif
.PHONY: f1_instance
f1_instance:
	cd ../../../framework/terraform/deployment && ../../../terraform/terraform init && ../../../terraform/terraform apply -auto-approve $(ADMIN_PWD) -var 'app_launch_script=/home/centos/src/project_data/fpga-webserver/apps/mandelbrot/terraform/fractalvalley_f1_init.sh' '-var-file=$(EC2_TYPE).tfvars' $(TF_ARGS)

LAUNCH_W :=python ../webserver/mandelbrot_server.py --port=<<PORT>> $(SERVER_ARGS)

include ../../../framework/build/Makefile
