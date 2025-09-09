# BSD 3-Clause License
#
# Copyright (c) 2018, alessandrocomodi
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# * Neither the name of the copyright holder nor the names of its
#   contributors may be used to endorse or promote products derived from
#   this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


#
# Terminology (TODO: Move to README):
#   1st CLaaS User Configuration:
#         Development using 1st CLaaS requires AWS resources, and the user configuration provides access
#         to these resources. Generally, the same configuration can be used for all development by a given
#         user, even development of different applications, and the configuration file is, by default,
#         stored in a user's home directory. Each repo clone can have an
#         associated default configuration defined by the file "~/1st-CLaaS_config.mk", which
#         can be created interactively using 'make config'. It contains shell variable assignments and can
#         be included by a Makefile or sourced by a shell script (or otherwise parsed).
#         It encapsulates:
#            - an AWS profile
#            - an S3 bucket name (which must be globally unique and accessible using the AWS credentials)
#            - on this S3 bucket, the state of AWS resources ("setups") associated with this configuration
#         This "1st-CLaaS_config.mk" file should have 600 privs as it contains AWS credentials.
#         The S3 bucket will hold secrets, such as TLS (SSH) access keys, so the bucket must have appropriate permissions.
#   Landing Web Server: The public-facing web server providing the landing page for an application (in contrast to an Accelerated
#                       Web Server, though these could be one in the same).
#   Accelerated Web Server: A web server utilizing an attached FPGA or FPGA emulation (running on an Amazon F1 Instance or emulated
#                           on a C4 Instance or future platform)
#   Accelerated Instance: An EC2 Instance (or future platform) running an Accelerateed Web Server.
#   Static Accelerated Web Server: An Accelerated Web Server Instance that is statically associated with a Landing Web Server.
#                                  It is shared by all users and may be dynamically started and stopped and will be stopped by an
#                                  EC2 time bomb.
#   EC2 Time Bomb: A utility provided in this repository responsible for stopping/terminating EC2 Instances (Accelerated Instances)
#                  when not in use.
#
# Usage:
#   Projects must provide a Makefile that includes this one.
#   Use apps/* examples for sample usage.
#
#   This Makefile provides targets for:
#      o Building and launching a Landing Web Server (and its host application)
#      o Creating a Static Accelerated Web Server
#
#   Provided Targets (for Web Server and Application build/launch):
#     config: interactive user configuration for using 1st CLaaS. In the rare case that multiple configurations are desired,
#             CONFIG_FILE=XXX can be given in this and subsequent make commands that wish to use this configuration.
#     host: the host application
#     xclbin: the FPGA image
#     build: the host application and FPGA image
#     emulation: ?
#     push: push application directory to S3 storage for transfer to F1 Instance
#     prebuild: populate contents of "prebuilt" directory with current build (do not set PREBUILT variable)
#     clean: remove all outputs for the given TARGET
#     live: launch or relaunch on PORT=80 in the background such that subsequent builds will not affect the live webserver.
#           (Must be the only target.)
#     dead: kill the running production server.
#     shrink: remove some of the larger TARGET=hw build collateral files. (No "TARGET=hw" required.)
#     copy_app: copy this app to a new app with name $(APP_NAME).
#   Variables:
#     AFI_PERMISSION=[public/private]: By default, AFIs are made public. Set this to "private" to prevent this.
#     CONFIG_FILE: The 1st CLaaS user configuration file to use. ~/1st-CLaaS_config.mk by default. This is an
#                     included Makefile that is expected to define:
#        AWS_PROFILE: The AWS profile to use to access AWS resources (in AWS CLI commands, the '--profile' argument).
#                     The AWS profile provides access keys and selects the EC2 region which must be one with F1 instances.
#        S3_BUCKET, defaulting to "1st-claas.$(S3_USER).$(S3_BUCKET_TAG)", where, by default:
#              S3_USER=user-name
#              S3_BUCKET_TAG=default
#           Any of these three may optionally be provided as configurtion variables.
#           The resulting S3_BUCKET_NAME must be a globally-unique (across all AWS users). It is used to store
#                information about AWS resources that are in use ("setups" managed using Terraform via this Makefile).
#        For secure server (https/wss), define:
#           SSL_CRT_FILE=<file>: File containing SSL certificate (.crt)
#           SSL_KEY_FILE=<file>: File containing SSL key (.key)
#     PORT: The port on which to launch the web server.
#     TARGET=[hw, hw_emu, sim, sw] (determined by platform by default)
#             hw: F1 FPGA.
#             hw_emu: SDAccel hardware emulation compilation.
#             sim: Verilator simulation of the kernel.
#             sw: software-only with no kernel behavior available.
#            TARGET is downgraded automatically based on the platform.
#     PREBUILT=[true] or default to false behavior. True to use the prebuilt files in the repository, rather than building.
#     WAVES=[true] or default to false behavior. True to generate waveforms. (xocc )
#     VALGRIND=[true] or default to false behavior. True to use Valgrind to identify memory leaks in the host application.
#     NOHUP=true: Can be used with 'launch' target to launch in background and stay running after the shell exits. (This is implied by 'make live').
#     LAUNCH_ID: Used by launch, live, and dead targets. If unassigned, these targets assume a single running microservice.
#                A unique identifier can be provided in this variable for these targets to enable unique instances.
#   Eg:
#     make host TARGET=hw_emu
#
#   Instance/Setup Targets:
#     Instance targets are used for creating, destroying, and managing EC2 instances.
#     EC2 instances should be managed using these targets rather than manually via the EC2 Management Console
#     so that associated resources are created/destroyed together.
#
#     Instance Target Variables:
#        #    PASSWORD: (prompts as admin_pwd) might be used by web server to authenticate administrative actions from a client.
#        #    LINUX_PASSWORD: Constructed instances will be assigned this Linux password. (Must not contain single/double quote or backslash.)
#        #                    Note that RDP access uses LINUX_PASSWORD (because storing a password in Remmina config is not secure, and
#        #                    I don't know how to configure the desktop to bypass the password prompt when ssh-tunnelled).
#        #    INSTANCE_TYPE: Use c4 for testing without FPGA.
#        #    INSTANCE_NAME: Name of the instance.
#        #    INSTANCE_STORAGE: Size in GB of "sdb" storage on the instance. Defaults to 15, which is appropriate for Development Instance.
#        #                      5 is the default for the AMI and is good for deployment (no implementation builds).
#        #    INSTANCE_CONFIG_SCRIPT: Script that is run to configure the instance.
#        #    SETUP: The Terraform "setup" to use. Each setup is managed independently with its own .tfstate file.
#        #    TFVAR:    A single .tfvars file. To avoid prompts, this should contain:
#        #                aws_access_key_id="XXX"
#        #                aws_secret_access_key="XXX"
#        #                region="XXX"   # Eg: "us-east-1"
#        #              (It may also provide admin_pwd and use_prebuilt_afi.)
#        #    TF_ARGS: (opt) Additional arguments for Terraform.
#     # The following *_instance targets exist. These targets must be used as the only target in the make command.
#     # Note that the admin password and AWS profile's keys are stored in plain text on the created instance. They are also
#     # displayed in plain text on stdout.
#     # Each *_instance target has its own default values for INSTANCE_* variables.
#     development_instance (from framework/build):
#        > make PASSWORD=XXX LINUX_PASSWORD=XXX development_instance
#        WARNING: This launches a new instance. Be sure it is not left running!
#     f1_instance (from framework/build):
#        > make PASSWORD=XXX LINUX_PASSWORD=XXX f1_instance
#        WARNING: This launches a new instance. Be sure it is not left running!
#        NOTE: This instance is allocated enough INSTANCE_STORAGE for development by default.
#     static_accelerated_instance (from app/xxx/build):
#        By default to create a new Static Accelerated Instance, for an application, to be associated with the Content Web Server, use:
#        > make PASSWORD=XXX PREBUILT=false/true static_accelerated_instance
#           # PREBUILT: (prompts as use_prebuilt_afi) provided to 'make live' of the F1 (or C4 for debug) instance.
#        WARNING: This launches a new instance. Be sure it is not left running!
#     For make launch, to associate an F1 instance, with this Content Web Server use:
#        > make INSTANCE=i-xxxxxxx PASSWORD=<password> AWS_PROFILE=<aws-profile> launch
#           # PASSWORD: used by this web server (not F1) to authenticate administrative actions (may not be necessary); probably best to use the same PASSWORD for F1.
#     Instances can be destroyed (along with their associated AWS resources) using:
#        > make destroy SETUP=XXX
#     Available SETUPs (same as INSTANCE_NAME in this case) can be listed with:
#        > make list_setups
#   Targets for connecting to EC2 instances:
#     # Connect to remote desktop via RDP.
#     desktop:
#       >make INSTANCE_NAME=<instance_name> desktop
#          # INSTANCE_NAME: (opt) Can be supplied if multiple EC2 instances are running to identify the instance.
#     # Connect or run a command via SSH (and accept the ECDSA key fingerprint).
#     ssh
#       >make INSTANCE_NAME=<instance-name> SSH_CMD=<command> ssh
#          # INSTANCE_NAME: (opt) Can be supplied if multiple EC2 instances are running to identify the instance.
#          # SSH_CMD: (opt) A command to run remotely via SSH (otherwise keep the SSH shell running).
#     # Report the instance name and IP of the running instance.
#     ip
#       >make INSTANCE_NAME=<instance_name> ip
#          # INSTANCE_NAME: (opt) Can be supplied if multiple EC2 instances are running to identify the instance.

SHELL=/bin/bash

COMMA:= ,
EMPTY:=
SPACE:= $(EMPTY) $(EMPTY)
# $(SINGLE_QUOTE) is used to avoid syntax highlighting issues in Atom.
SINGLE_QUOTE:= '

# Path to this repo (relative or absolute). Makefiles outside of this repo must define this.
FIRST_CLAAS_REPO ?=$(shell realpath --relative-to=. $$(git rev-parse --show-toplevel))

# Absolute path to this repo.
ABS_REPO=$(shell realpath "$(FIRST_CLAAS_REPO)")
# Relative path to this repo.
REPO=$(shell realpath "--relative-to=." "$(FIRST_CLAAS_REPO)")

FRAMEWORK_DIR=$(REPO)/framework

# Make sure init has been run.
ifeq ($(shell ls "$(REPO)/terraform/terraform" 2> /dev/null),)
$(info )
$(info *****************************)
$(info Did you forget to run "init"?)
$(info *****************************)
$(info )
DUMMY :=$(shell sleep 3)
endif

# force every `terraform init` to include -reconfigure
# To ensure a clean and correct Terraform re-initialization every time make runs terraform init
export TF_CLI_ARGS_init = -reconfigure


# Read user configuration.

CONFIG_FILE=$(HOME)/1st-CLaaS_config.mk

# Default config.
AWS_PROFILE=default
S3_USER=$(USER)
S3_BUCKET_TAG=default

ifneq ($(MAKECMDGOALS),config)
ifneq ($(shell ls '$(CONFIG_FILE)' 2> /dev/null),)
include $(CONFIG_FILE)
else
$(info 1st CLaaS Configuration file "$(CONFIG_FILE)" can be configured interactively using "make config".)
endif
endif
# Invalidate default passwords if -n flag is given to prevent password from appearing in output. (LINUX_PASSWORD shouldn't be defaulted anyway.)
ifneq ($(subst n,,$(MAKEFLAGS)),$(MAKEFLAGS))
PASSWORD :=XXXXX
LINUX_PASSWORD :=YYYYY
endif

S3_BUCKET ?=1st-claas.$(S3_USER).$(S3_BUCKET_TAG)


AUTO_APPROVE=false
AFI_PERMISSION=public


# Chrome executable if there is one. Empty if not found and unspecified.
CHROME=$(shell which google-chrome)


#
# Characterize platform (define $SUPPORTED_TARGETS)
#

VERILATOR=$(shell ls "$(REPO)/local/verilator" 2> /dev/null)
ifeq ($(VERILATOR),)
# No local verilator.
VERILATOR=$(shell which verilator 2> /dev/null)
# Presumable verilator is /usr/local/bin/verilator or /usr/bin/verilator (but there is no check).
# Find the include directory relative to the binary.
VERILATOR_INCLUDE=$(subst bin/verilator,share/verilator/include,$(VERILATOR))
else
VERILATOR=$(ABS_REPO)/local/verilator/bin/verilator
VERILATOR_ROOT=$(ABS_REPO)/local/verilator
VERILATOR_INCLUDE=$(ABS_REPO)/local/verilator/include
endif
ifneq ($(AWS_FPGA_REPO_DIR),)
ifneq ($(findstring f2.,$(shell curl http://169.254.169.254/latest/meta-data/instance-type)),)
# F2
SUPPORTED_TARGETS :=hw | hw_emu |$(SPACE)
else
SUPPORTED_TARGETS :=hw_emu |$(SPACE)
endif
endif

ifneq ($(VERILATOR),)
# Verilator.
SUPPORTED_TARGETS :=$(SUPPORTED_TARGETS)sim | sw |$(SPACE)
else
SUPPORTED_TARGETS :=$(SUPPORTED_TARGETS)sw |$(SPACE)
endif



#
# Determine BUILD_TARGET. [hw (default) | hw_emu | sim | sw]
#

# This one can be specified on command line, so it cannot be changed.
TARGET :=default
# We'll change this one.
BUILD_TARGET :=$(TARGET)
# A more explicit name for TARGET, and we never user TARGET again.
SPECIFIED_TARGET :=$(TARGET)

# Default BUILD_TARGET to hw or hw_emu depending on platform.
ifeq ($(BUILD_TARGET),default)
ifneq ($(findstring hw |,$(SUPPORTED_TARGETS)),)
BUILD_TARGET :=hw
else
BUILD_TARGET :=hw_emu
endif
endif

# If BUILD_TARGET is not supported, downgrade, but allow hw (if explicit, as ensured above) for hw_emu platforms. (Note that "hw" will match "hw_emu".)
ifeq ($(findstring $(BUILD_TARGET),$(SUPPORTED_TARGETS)),)
# Downgrade.
# If sim is not supported, downgrade to sw.
ifeq ($(BUILD_TARGET),sim)
BUILD_TARGET :=sw
else
# Downgrade to highest-level target.
BUILD_TARGET :=$(firstword $(SUPPORTED_TARGETS))
endif
ifneq ($(SPECIFIED_TARGET),default)
$(info Your platform does not support TARGET=$(SPECIFIED_TARGET).)
endif
endif
$(info Using TARGET=$(BUILD_TARGET).  (Platform supports: | $(SUPPORTED_TARGETS)))



# Characterize TARGET.
ifeq ($(BUILD_TARGET),hw)
USE_XILINX=true
endif
ifeq ($(BUILD_TARGET),hw_emu)
USE_XILINX=true
endif


# Can only do PREBUILT=true w/ TARGET=hw.
ifneq ($(BUILD_TARGET),hw)
	USE_PREBUILT=false
else
	USE_PREBUILT=$(PREBUILT)
endif



# Determine kernel name from current directory.
KERNEL_NAME ?= $(shell realpath $$(pwd) | sed 's|^.*/\([^/]*\)/build$$|\1|')
HW_SHELL_CONFIG_JSON ?=$(FRAMEWORK_DIR)/fpga/default_shell_config.json


PORT ?= 8888


# Python Web Server Command


WEBSERVER_ARGS :=
LAUNCH_PASSWORD :=
ifdef INSTANCE
WEBSERVER_ARGS :=$(WEBSERVER_ARGS) --instance $(INSTANCE)
endif
ifdef PASSWORD
WEBSERVER_ARGS :=$(WEBSERVER_ARGS) --password <<PASSWORD>>
LAUNCH_PASSWORD :=LAUNCH_PASSWORD=' {{{$(PASSWORD)}}} '
endif
ifneq ($(AWS_PROFILE),default)
WEBSERVER_ARGS :=$(WEBSERVER_ARGS) --profile $(AWS_PROFILE)
endif
ifdef SSL_CRT_FILE
ifdef SSL_KEY_FILE
WEBSERVER_ARGS :=$(WEBSERVER_ARGS) --ssl_crt_file='$(SSL_CRT_FILE)' --ssl_key_file='$(SSL_KEY_FILE)'
endif
endif

WEBSERVER_PY ?= $(shell if [[ -e "../webserver/$(KERNEL_NAME)_server.py" ]]; then echo "../webserver/$(KERNEL_NAME)_server.py"; else echo "$(FRAMEWORK_DIR)/webserver/default_server.py"; fi)
LAUNCH_W ?=python3 $(WEBSERVER_PY) --port=<<PORT>> --socket=<<SOCKET>> $(WEBSERVER_ARGS)




# For S3.
#    S3_LOGS_KEY=folder: the S3 bucket folder to use for logs for the AFI build.
#    S3_DCP_KEY=folder: the S3 bucket folder to use for logs for the AFI build.
#    S3_TF_KEY=folder: the S3 bucket folder to use for Terraform state.
S3_LOGS_KEY=$(KERNEL_NAME)_log
S3_DCP_KEY=$(KERNEL_NAME)_dcp
S3_TRANSFER_KEY=$(KERNEL_NAME)_xfer

VPP=v++
CC=g++


HOST_DIR=../host
FRAMEWORK_HOST_DIR=$(FRAMEWORK_DIR)/host

EXTRA_C_SRC ?=
EXTRA_C_HDRS ?=
PROJ_C_SRC ?=$(shell ls ../host/*.c ../host/*.cpp ../host/*.C ../host/*.cxx 2> /dev/null)
PROJ_C_HDRS ?=$(shell ls ../host/*.h ../host/*.hpp ../host/*.H ../host/*.hxx 2> /dev/null)
PROJ_SW_CFLAGS ?=
PROJ_SW_LFLAGS ?=

# If the project supplies C++ code, it must supply main. Otherwise, use framework main.
ifeq ($(PROJ_C_SRC)$(EXTRA_C_SRC),)
  PROJ_C_SRC=$(FRAMEWORK_HOST_DIR)/default_main.c
endif

#Software (no FPGA) flags
SW_SRC ?= $(FRAMEWORK_HOST_DIR)/server_main.c $(PROJ_C_SRC) $(EXTRA_C_SRC)
SW_HDRS ?= $(FRAMEWORK_HOST_DIR)/protocol.h $(FRAMEWORK_HOST_DIR)/server_main.h $(PROJ_C_HDRS) $(EXTRA_C_HDRS)
SW_CFLAGS ?= -g -Wall -O3 -std=c++11 -faligned-new -I$(HOST_DIR) -I$(FRAMEWORK_HOST_DIR) -I$(FRAMEWORK_DIR)/host/json/include $(PROJ_SW_CFLAGS)
SW_LFLAGS ?= -L$(XILINX_XRT)/lib $(PROJ_SW_LFLAGS)

#Host code
HOST_SRC=$(SW_SRC) $(FRAMEWORK_HOST_DIR)/hw_kernel.c
HOST_HDRS=$(SW_HDRS) $(FRAMEWORK_HOST_DIR)/kernel.h
HOST_HDRS=$(SW_HDRS) $(FRAMEWORK_HOST_DIR)/hw_kernel.h
# TODO: It seems SDX_PLATFORM should be set to a value. For hw_emu, I see one device: "xilinx:pcie-hw-em:7v3:1.0"
#       What's the emconfigutil command (for configuring the platform for hw_emu?)
HOST_CFLAGS=$(SW_CFLAGS) -D KERNEL_AVAIL -D FPGA_DEVICE -D OPENCL -I$(XILINX_XRT)/runtime/include/1_2 -D C_KERNEL -D VITIS_PLATFORM=$(AWS_PLATFORM) -D KERNEL=$(KERNEL_NAME)
HOST_LFLAGS=$(SW_LFLAGS) -lxilinxopencl

#Simulation flags
SIM_SRC=$(SW_SRC) $(FRAMEWORK_HOST_DIR)/sim_kernel.c
SIM_HDRS=$(SW_HDRS) $(FRAMEWORK_HOST_DIR)/kernel.h
SIM_HDRS=$(SW_HDRS) $(FRAMEWORK_HOST_DIR)/sim_kernel.h
SIM_CFLAGS=$(SW_CFLAGS) -std=c++11 -lpthread -DVL_THREADED=1 -D KERNEL_AVAIL -D KERNEL=$(KERNEL_NAME) -D VERILATOR_KERNEL=V$(KERNEL_NAME)_kernel
SIM_LFLAGS=$(SW_LFLAGS)

#Name of host executable
HOST_EXE=host

#Kernel
KERNEL_SRC=
# Flags for v++ (include -I <file> args).
KERNEL_FLAGS=
KERNEL_EXE=$(KERNEL_NAME)

#Custom flag to give to v++
KERNEL_LDCLFLAGS= --connectivity.nk $(KERNEL_NAME):1 \
      --xp param:compiler.preserveHlsOutput=1 \
      --hls.max_memory_ports $(KERNEL_NAME) \
      --hls.memory_port_data_width $(KERNEL_NAME):512 \

KERNEL_ADDITIONAL_FLAGS=

#Device to be used
#TARGET_DEVICE=xilinx:aws-vu9p-f1:4ddr-xpr-2pr:4.0
TARGET_DEVICE=xilinx_aws-vu47p-f2_202410_1_2# updated for F2 platform on Vitis 2024.2


REPORT=
ifeq ($(BUILD_TARGET),hw)
REPORT=--report system
else
ifeq ($(BUILD_TARGET),hw_emu)
REPORT=--report estimate
endif
endif

# Build dir is "out" or "prebuilt", based on PREBUILT variable.
BUILD_DIR_NAME = out
OUT_DIR_NAME = out
ifeq ($(USE_PREBUILT), true)
BUILD_DIR_NAME = prebuilt
OUT_DIR_NAME = prebuilt_out
endif

#Assign DEST_DIR as <BUILD_TARGET>/<TARGET_DEVICE>, or just <BUILD_TARGET> for sw build (w/ no target device).
ifneq ($(USE_XILINX),true)
DEST_DIR=../$(OUT_DIR_NAME)/$(BUILD_TARGET)
BUILD_DIR=../$(BUILD_DIR_NAME)/$(BUILD_TARGET)
else
ifndef AWS_PLATFORM
$(info WARNING: AWS_PLATFORM is not set. Making assumptions.)
AWS_PLATFORM=xilinx_aws-vu47p-f2_202410_1_2# updated for F2 platform on Vitis 2024.2
endif
#Translate Target Device name with underscores
PERIOD:= :
UNDERSCORE:= _
DEST_SUBDIR=$(BUILD_TARGET)/$(subst $(PERIOD),$(UNDERSCORE),$(TARGET_DEVICE))
DEST_DIR=../$(OUT_DIR_NAME)/$(DEST_SUBDIR)
BUILD_DIR=../$(BUILD_DIR_NAME)/$(DEST_SUBDIR)
endif

ifndef XILINX_XRT
ifeq ($(USE_XILINX),true)
$(error XILINX_XRT is not set. Please source the SDx settings64.{csh,sh} first)
endif
endif


# For instance-specific targets (launch/live/dead)

# Prevent conflicts between launch and live targets.
ifeq ($(MAKECMDGOALS), launch)
DEFAULT_SOCKET=SOCKET
DEFAULT_KILLME=./kill_launch
else
DEFAULT_SOCKET=LIVE_SOCKET
DEFAULT_KILLME=./killme
endif

# Interpret the LAUNCH_ID
# KILLME: The name of the killme file for this microservice.
# WEBSERVER_LOG: The path to the log file for this microservice (./log/*).
# LAUNCH_DIR: directory from which microservice is launched and where is creates files.
ifdef LAUNCH_ID
LAUNCH_LOCAL_DIR=id-$(LAUNCH_ID)/
LAUNCH_DIR=../live/$(BUILD_TARGET)/id-$(LAUNCH_ID)
KILLME=./killme-$(LAUNCH_ID)
WEBSERVER_LOG=log/id-$(LAUNCH_ID).log
LAUNCH_ID_ARG_STR=$(SPACE)LAUNCH_ID=$(LAUNCH_ID)
SOCKET=SOCKET-$(LAUNCH_ID)
else
LAUNCH_ID=.
LAUNCH_LOCAL_DIR=
LAUNCH_DIR=../live/$(BUILD_TARGET)
KILLME=$(DEFAULT_KILLME)
WEBSERVER_LOG=log/webserver.log
LAUNCH_ID_ARG_STR=LAUNCH_ID=
SOCKET=$(DEFAULT_SOCKET)
endif

# 'live' target.
ifeq ($(MAKECMDGOALS),live)
NOHUP=true
PORT=80
HOST_EXE_PATH=$(LAUNCH_DIR)/$(HOST_EXE)
else
HOST_EXE_PATH=$(BUILD_DIR)/$(HOST_EXE)
endif

ifeq ($(MAKECMDGOALS),dead)
ALREADY_DEAD=else echo "There doesn't appear to be anything to kill.";
endif


# If project has a launch command, use it, otherwise, use launch from framework.
LAUNCH_CMD_PARTIAL :=$(shell if [[ -e ./launch ]]; then echo ./launch; else echo $(FRAMEWORK_DIR)/build/launch; fi) -w '$(LAUNCH_W)'
LAUNCH_ARGS=-p $(PORT) -s $(SOCKET) -k '$(KILLME)' $(BUILD_TARGET) '$(HOST_CMD)'
ifdef NOHUP
# Run in background to continue if the shell exits; log output and cut off stdin to detach from the launching process's stdin (so ssh/etc can exit).
LAUNCH_CMD=nohup $(LAUNCH_CMD_PARTIAL) $(LAUNCH_ARGS) &> $(WEBSERVER_LOG) < /dev/null &
else
LAUNCH_CMD=$(LAUNCH_CMD_PARTIAL) $(LAUNCH_ARGS)
endif


# TL-Verilog compilation.
# fpga/src/*.tlv are taken as top-level TLV files.
# fpga/src/*.tlvlib are taken as TLV library files, provided for every SandPiper run (which is network overhead whether used or not).
#KERNEL_TLV=../fpga/src/$(KERNEL_NAME)_kernel.tlv
TLV=$(shell ls ../fpga/src/*.tlv 2> /dev/null)
SV_SRC=$(shell ls ../fpga/src/*.sv ../fpga/src/*.v 2> /dev/null)
VH_SRC=$(shell ls ../fpga/src/*.vh 2> /dev/null)
FRAMEWORK_V_SRC=$(shell ls $(FRAMEWORK_DIR)/fpga/src/*.v $(FRAMEWORK_DIR)/fpga/src/*.sv $(FRAMEWORK_DIR)/fpga/src/*.vh 2> /dev/null)
TLVLIB=$(shell ls ../fpga/src/*.tlvlib 2> /dev/null)
SV_FROM_TLV=$(patsubst ../fpga/src/%.tlv,../out/sv/%.sv,$(TLV))
SP_CURL_FILES=$(patsubst ../fpga/src/%.tlvlib,-F 'files[]=@../../../fpga/src/%.tlvlib',$(TLVLIB))


ifeq ($(VALGRIND),true)
VALGRIND_PREFIX=valgrind --leak-check=yes
else
VALGRIND_PREFIX=
endif

HOST_ARGS=-s $(SOCKET)
ifneq ($(USE_XILINX),true)
BUILD_TARGETS=$(BUILD_DIR)/$(HOST_EXE)
HOST_CMD=$(VALGRIND_PREFIX) $(HOST_EXE_PATH) $(HOST_ARGS)
endif
ifeq ($(BUILD_TARGET),hw_emu)
BUILD_TARGETS=$(BUILD_DIR)/$(HOST_EXE) $(HOST_XCLBIN)
HOST_CMD=export XCL_EMULATION_MODE=$(BUILD_TARGET) && $(XILINX_VITIS)/bin/emconfigutil --od $(DEST_DIR) --nd 1  --platform $(AWS_PLATFORM) && $(VALGRIND_PREFIX) $(HOST_EXE_PATH) $(HOST_ARGS) $(HOST_XCLBIN)
endif
ifeq ($(BUILD_TARGET),hw)
BUILD_TARGETS=$(BUILD_DIR)/$(HOST_EXE) $(HOST_XCLBIN)
HOST_CMD=$(VALGRIND_PREFIX) $(HOST_EXE_PATH) $(HOST_ARGS) $(HOST_XCLBIN)
endif


# It's best not to expose passwords in the output. (Even though the user has access, there might be someone peeping.)
# This macro recognizes " {{{secret}}} " as a secret. It is echoed to the terminal as "*****" and replaced
# with "secret" to execute the command.
# Usage: $(call with_secret,$(COMMAND))
define with_secret
	@# Echo command without secrets (requires proper quoting)
	@echo '$(subst $(SPACE)*****$(SPACE),*****,$(patsubst {{{%}}},*****,$(subst $(SINGLE_QUOTE),'"$(SINGLE_QUOTE)"',$1)))'
	@$(subst }}}$(SPACE),,$(subst $(SPACE){{{,,$1))
endef

.PHONY: nothing
nothing:
	@echo "No target specified. Nothing built."

.PHONY: clean shrink
clean:
	sudo rm -rf ../out
# TODO: Add more-selective clean targets.

# Remove some of the large hw build collateral files.
shrink:
	rm -rf ../out/hw/*/to_aws ../out/hw/*/*.tar ../out/hw/*/_x



# User configuration.
define config_param
	@echo -n "$1 [$($1)]: " && (read TMP; if [[ -n "$$TMP" ]]; then echo "$1=$$TMP" >> $(CONFIG_FILE).tmp; else echo '$1=$($1)' >> $(CONFIG_FILE).tmp; fi)
endef
#Validating S3 user and bucket name
define validate_param
	@while true; do \
		echo -n "$1 [$($1)]: "; \
		read TMP; \
		if [[ -z "$$TMP" ]]; then TMP="$($1)"; fi; \
		if [[ "$$TMP" =~ ^[a-z0-9]([-a-z0-9]*[a-z0-9])?$$ ]]; then \
			echo "$1=$$TMP" >> $(CONFIG_FILE).tmp; \
			break; \
		else \
			echo "❌ Invalid $1. Must follow S3 naming rules:"; \
			echo "   • Only lowercase letters, numbers, and hyphens"; \
			echo "   • Must start and end with a letter or number"; \
		fi; \
	done
endef

.PHONY: config
config:
	@rm -f $(CONFIG_FILE).tmp
	@[[ ! -e "$(CONFIG_FILE)" ]] || ! echo "User configuration file ($(CONFIG_FILE)) already exists. Edit with a text editor."
	@echo
	@echo 'Creating 1st CLaaS user configuration file: "$(CONFIG_FILE)".'
	@echo 'To keep a default value, press <Enter>.'
	@echo 'Enter AWS profile to associate with your 1st CLaaS work. If desired, create a new IAM user via the AWS Management Console.'
	@ if [[ -e '~/.aws/config' && -e '~/.aws/credentials' ]];\
	  then echo 'Known (already-configured via "aws configure" AWS profiles (if any):';\
		   grep '\[profile' ~/.aws/config | sed 's/^\[profile \(.*\)\]$/\1/';\
	  fi
	$(call config_param,AWS_PROFILE)
	@echo
	@echo 'Have your AWS credentials ready (or create new via AWS Management Console: search "IAM", "users", select user, "Security Credentials", "Create access key").'
	@source $(CONFIG_FILE).tmp && NEW_AWS_PROFILE="$$AWS_PROFILE" && unset AWS_PROFILE && aws configure --profile "$$AWS_PROFILE"  # (aws configure doesn't work if $AWS_PROFILE doesn't already exist.)
	@source $(CONFIG_FILE).tmp && \
	  REGION=$$(aws configure get region) && \
	  if [[ ! $$REGION =~ (us-east-1|us-west-2|eu-west-2|ap-southeast-2) ]]; \
	  then echo "Warning: Region $$REGION is not known to support F2. Valid regions w/ F2 include: 'us-east-1' (N. Virginia), 'us-west-2' (Oregon), 'eu-west-2' (London), or 'ap-southeast-2' (Sydney). (Please update Makefile and create a pull request if you know differently.)"; \
	  fi
	@echo
	@echo 'User configuration needs an associated AWS S3 bucket (storage), which requires a globally-unique name (across all AWS users).'
	@echo 'Bucket name will be 1st-claas.$$(S3_USER).$$(S3_BUCKET_TAG)'

	@echo "Enter S3_USER (must follow S3 naming rules: lowercase letters, digits, hyphens only)"
	$(call validate_param,S3_USER)

	@echo "Enter S3_BUCKET_TAG (must follow S3 naming rules: lowercase letters, digits, hyphens only)"
	$(call validate_param,S3_BUCKET_TAG)

	@# For convenience, also store the full bucket name.
	@source $(CONFIG_FILE).tmp && echo "S3_BUCKET=1st-claas.$${S3_USER}.$${S3_BUCKET_TAG}" >> $(CONFIG_FILE).tmp
	@echo 'EC2 instances can be initialized with an administrative password. This password may be used by optional administrative features of 1st-CLaaS web servers. Choose a default or leave blank to require explicit password on launch when needed.'
	@echo "WARNING: This default PASSWORD is accessible to $(USER) and root users."
	$(call config_param,PASSWORD)
	@chmod 600 $(CONFIG_FILE).tmp
	@mv $(CONFIG_FILE).tmp $(CONFIG_FILE)
	@echo 'Configuration complete and stored in "$(CONFIG_FILE)" accessible only to you ("$(USER)"). Contents:'
	@cat $(CONFIG_FILE)
	@source $(CONFIG_FILE) && \
	echo "Setting up S3 bucket: s3://$$S3_BUCKET" && \
	aws s3api create-bucket --bucket "$$S3_BUCKET" --acl private --profile "$$AWS_PROFILE" > /dev/null && \
	aws s3api wait bucket-exists --bucket "$$S3_BUCKET" --profile "$$AWS_PROFILE"



# Rule to build host application, only if not using pre-built.
ifneq ($(USE_PREBUILT), true)

# TODO: Instead of this condition, define $(SW_SRC) and $(HOST_SRC) as $(SRC) conditionally, etc.
ifneq ($(USE_XILINX),true)
ifeq ($(BUILD_TARGET),sw)
#sw target
$(DEST_DIR)/$(HOST_EXE): $(SW_SRC) $(SW_HDRS)
	mkdir -p $(DEST_DIR)
	$(CC) $(SW_SRC) $(SW_CFLAGS) $(SW_LFLAGS) -o $(DEST_DIR)/$(HOST_EXE)
# Host for debug.
$(DEST_DIR)/$(HOST_EXE)_debug: $(SW_SRC) $(SW_HDRS)
	mkdir -p $(DEST_DIR)
	$(CC) $(SW_SRC) $(SW_CFLAGS) -Og -ggdb -DDEBUG $(SW_LFLAGS) -o $(DEST_DIR)/$(HOST_EXE)_debug
else
#sim target
$(DEST_DIR)/verilator/V$(KERNEL_NAME)_kernel.cpp: $(SV_SRC) $(SV_FROM_TLV) $(VH_SRC) $(FRAMEWORK_V_SRC)
	mkdir -p $(DEST_DIR)
	$(VERILATOR) --cc --sv --trace --top-module $(KERNEL_NAME)_kernel -DFPGA_WEBSERVER_KERNEL $(SV_SRC) $(SV_FROM_TLV) -y ../out/sv -y ../fpga/src -y $(FRAMEWORK_DIR)/fpga/src --Mdir $(DEST_DIR)/verilator \
	|| (STATUS=$$? && mv $(DEST_DIR)/verilator/V$(KERNEL_NAME)_kernel.cpp $(DEST_DIR)/verilator/V$(KERNEL_NAME)_kernel.cpp.error && exit $$STATUS)  # to force re-run.
$(DEST_DIR)/$(HOST_EXE): $(SIM_SRC) $(SIM_HDRS) $(DEST_DIR)/verilator/V$(KERNEL_NAME)_kernel.cpp
	@[[ -e "$(VERILATOR_INCLUDE)" ]] || ! echo "Verilator include directory not found at '$(VERILATOR_INCLUDE)'."
	cd $(DEST_DIR)/verilator && rm -f verilator_kernel.h && ln -s V$(KERNEL_NAME)_kernel.h verilator_kernel.h
	@# For multithreaded, include on command line: $(VERILATOR_INCLUDE)/verilated_threads.cpp
	$(CC) $(SIM_SRC) $(SIM_CFLAGS) $(SIM_LFLAGS) $$(ls $(DEST_DIR)/verilator/*.cpp) $(VERILATOR_INCLUDE)/verilated.cpp $(VERILATOR_INCLUDE)/verilated_vcd_c.cpp -I $(DEST_DIR)/verilator -I $(VERILATOR_INCLUDE) -o $(DEST_DIR)/$(HOST_EXE)
	cd $(DEST_DIR)/verilator && rm verilator_kernel.h
# Host for debug.
#$(DEST_DIR)/$(HOST_EXE)_debug: $(SW_SRC) $(SW_HDRS)
#	mkdir -p $(DEST_DIR)
#	$(CC) $(SW_SRC) $(SW_CFLAGS) -Og -ggdb -DDEBUG $(SW_LFLAGS) -o $(DEST_DIR)/$(HOST_EXE)_debug
endif
else
#hw and hw_emu target
$(DEST_DIR)/$(HOST_EXE): $(HOST_SRC) $(HOST_HDRS)
	mkdir -p $(DEST_DIR)
	$(CC) $(HOST_SRC) $(HOST_CFLAGS) $(HOST_LFLAGS) -o $(DEST_DIR)/$(HOST_EXE)
endif

endif


# Run SandPiper.
# Use a local sandpiper if $(SANDPIPER) is defined to point to one, otherwise, use SandPiper(TM) SaaS.
.PHONY: sv
sv: $(SV_FROM_TLV)
../out/sv/%.sv: ../fpga/src/%.tlv $(TLVLIB)
	rm -rf ../out/sv/$*
	mkdir -p ../out/sv/$*/out
ifeq ($(SANDPIPER),)
	@# Run SandPiper(TM) SaaS Edition on TLV files.
	@# SandPiper SaaS produces a zipped tarball of: out/[*.sv, stdout, status]
	cd ../out/sv/$*
	yes | sandpiper-saas -i ../fpga/src/$*.tlv -o $*.sv --outdir ../out/sv/$*/out/ --sv_url_inc --iArgs 2>&1 | tee ../out/sv/$*/out/stdout && echo $$? > ../out/sv/$*/out/status
else
	@# Use local SandPiper, given by $(SANDPIPER)
	$(SANDPIPER) --iArgs --m4out ../out/sv/$*/out/$*.m4out.tlv -i ../fpga/src/$*.tlv -o ../out/sv/$*/out/$*.sv 2>&1 | tee ../out/sv/$*/out/stdout && echo $$? > ../out/sv/$*/out/status
endif
	(( $$(cat ../out/sv/$*/out/status) < 4 ))  # Fail for errors > 3 (SYNTAX_ERROR).
	mv ../out/sv/$*/out/*.sv ../out/sv
	# Vivado requires includes to be of .vh files, so change file name.
	mv ../out/sv/$*_gen.sv ../out/sv/$*_gen.vh
	cd ../out/sv && sed -i -e s/$*_gen\\.sv/$*_gen\\.vh/ $*.sv



# Kernel SV can come from fpga/src or via SandPiper.
KERNEL_SV :=$(shell ls ../fpga/src/$(KERNEL_NAME)_kernel.sv 2> /dev/null)
ifeq ($(KERNEL_SV),)
KERNEL_SV :=../out/sv/$(KERNEL_NAME)_kernel.sv
endif

# Xilinx build
ifeq ($(USE_XILINX),true)

# TODO: These are not relevant for BUILD_TARGET=sw/sim, and there is no distinction between hw and hw_emu, so they are defined the same
# regardless of BUILD_TARGET. Need to make $(HW_DEST_DIR) and $(HW_BUILD_DIR) and use those for kernel build commands/files.
# Actually, I think it would be better to include BUILD_TARGET in the build target, eg: sw_host, hw_host, etc. (As it is, there is
# redundant building for different targets).

VIVADO_VERSION_MESSAGE=Note: Kernel construction assumes Vivado v2018.3

# Create tcl script for the kernel configuration
$(DEST_DIR)/rtl_kernel_wiz.tcl: $(FRAMEWORK_DIR)/fpga/scripts/produce_tcl_file.py $(HW_SHELL_CONFIG_JSON)
	mkdir -p $(DEST_DIR)
	python3 "$(FRAMEWORK_DIR)/fpga/scripts/produce_tcl_file.py" "$(HW_SHELL_CONFIG_JSON)" "$(DEST_DIR)/rtl_kernel_wiz.tcl"

XO_FILE=$(DEST_DIR)/$(KERNEL_NAME)_ex/sdx_imports/$(KERNEL_EXE).xo
# A representative file for all inner-shell files generated by the RTL Kernel Wizard.
SHELL_REP=$(DEST_DIR)/$(KERNEL_NAME)_ex/imports/kernel.xml
# A file signifying completion of the addition of the user's kernel into the project.
USER_KERNEL_ADDED_FILE=$(DEST_DIR)/$(KERNEL_NAME)_ex/kernel_added.flag

# Creating the rtl kernel wizard project.
# kernel.xml acts as a representative for all produced files.
$(SHELL_REP): $(DEST_DIR)/rtl_kernel_wiz.tcl
	@echo $(VIVADO_VERSION_MESSAGE)
	vivado -mode batch -nojournal -nolog -notrace -source "$(DEST_DIR)/rtl_kernel_wiz.tcl" -tclargs $(KERNEL_NAME) "$(DEST_DIR)"

# Incorporate the user's kernel into the project.
# The Xilinx rtl_kernel_wizard does not create a cleanly partitioned model. We choose to replace the guts of the add example logic with some modifications via sed.
# How we hack the add example:
#   The example has an rd_fifo from AXI to kernel, and a wr_fifo from kernel to AXI.
#   It propagates the backpressure from the wr_fifo straight to the rd_fifo.
#   We need backpressure between rd_fifo and kernel and kernel and wr_fifo.
#   The sed commands apply the changes.
# Creates a kernel_added.flag file to signify completion.
# TODO: How do we create the SDAccel workspace and project? Makefile or in repo or via instructions?
# TODO: How do we configure the Vivado SDAccel project, including low-optimizations. Makefile or in repo or via instructions?
IMPORTS_DIR=$(DEST_DIR)/$(KERNEL_NAME)_ex/imports
VADD_SV=$(IMPORTS_DIR)/$(KERNEL_NAME)_example_vadd.sv
VIVADO_PROJ_SCRIPT=$(DEST_DIR)/add_to_project.tcl
$(USER_KERNEL_ADDED_FILE): $(SHELL_REP) $(SV_FROM_TLV)
	@echo $(VIVADO_VERSION_MESSAGE)
	# Hacking the Xilinx template project to include the custom user kernel. (Failures in this process could leave the project in an inconsistent state.)
	@# Add user's kernel source code to project.
	@mkdir -p ../out/sv  # Must exist for add_kernel.tcl
	@# Add sources to project.
	echo 'remove_files *_example_adder.v' > '$(VIVADO_PROJ_SCRIPT)' \
	  && echo "add_files $$(ls $(SV_SRC) $(VH_SRC) $(FRAMEWORK_V_SRC) ../out/sv/*.v ../out/sv/*.sv ../out/sv/*.vh 2> /dev/null | tr "\n" " ")" >> '$(VIVADO_PROJ_SCRIPT)'
	vivado -mode batch -nojournal -nolog -notrace -source '$(VIVADO_PROJ_SCRIPT)' '$(DEST_DIR)/$(KERNEL_NAME)_ex/$(KERNEL_NAME)_ex.xpr'
	@# Replace the adder example code with the user's kernel (including inner shell logic).
	$(FRAMEWORK_DIR)/fpga/scripts/hack_vadd_example.pl $(KERNEL_NAME) < $(VADD_SV) > $(VADD_SV).hacked
	mv $(VADD_SV).hacked $(VADD_SV)
	@# Also make the following edit to hook up ctrl_length arg (which must be specified in <shell-config>.json).
	#@grep 'LP_DEFAULT_LENGTH_IN_BYTES;' $(IMPORTS_DIR)/$(KERNEL_NAME)_example.sv | wc | grep '      1      ' 1> /dev/null  # Make sure there will be exactly one substitution.
	#sed -i 's/=\s*LP_DEFAULT_LENGTH_IN_BYTES;/; assign ctrl_xfer_size_in_bytes = ctrl_length;/' $(IMPORTS_DIR)/$(KERNEL_NAME)_example.sv
	@# And stitch args through hierarchy.
	@grep '( *ctrl_xfer_size_in_bytes *),' $(IMPORTS_DIR)/$(KERNEL_NAME)_example.sv | wc | grep '      1      ' 1> /dev/null  # Make sure there will be exactly one substitution.
	sed -i 's/( *ctrl_xfer_size_in_bytes *),/(ctrl_length), .resp_addr_offset (write_mem), .resp_xfer_size_in_bytes (resp_length),/' $(IMPORTS_DIR)/$(KERNEL_NAME)_example.sv
	@# Remove unused vadd example file.
	rm "$(DEST_DIR)/$(KERNEL_NAME)_ex/imports/$(KERNEL_NAME)_example_adder.v"
	# Hacked Xilinx template project without errors.
	@# Signify successful completion for Make.
	touch "$(USER_KERNEL_ADDED_FILE)"

# Moving the Makefile necessary for Hardware emulation and build into the sdx_imports directory
# TODO: Is this necessary?
#cp $LIB_DIR/src/Makefile $2/${1}_ex/sdx_imports/

#$(DEST_DIR)/$(KERNEL_EXE).xo:
#	mkdir -p $(DEST_DIR)
#	$(XOCC) --platform $(AWS_PLATFORM) --target $(BUILD_TARGET) --compile --include $(KERNEL_HDRS) --save-temps $(REPORT) --kernel $(KERNEL_NAME) $(KERNEL_SRC) $(KERNEL_LDCLFLAGS) $(KERNEL_FLAGS) $(KERNEL_ADDITIONAL_FLAGS) --output $(DEST_DIR)/$(KERNEL_EXE).xo
#	#cp ../fpga/mandelbrot_hw/sdx_imports/$(KERNEL_EXE).xo $(DEST_DIR)/$(KERNEL_EXE).xo

# Package the project as an .xo.
# (Use: "$(XO_FILE): $(SHELL_REP)" to build with the vadd example kernel, unmodified.)
$(XO_FILE): $(USER_KERNEL_ADDED_FILE) $(SV_SRC) $(SV_FROM_TLV) $(FRAMEWORK_V_SRC)
	$(info $(VIVADO_VERSION_MESSAGE))
	$(info "-----------------")
	$(info "Packaging project")
	$(info "-----------------")
	-rm $(XO_FILE) 2> /dev/null || true  # Seems to be necessary to remove the old .xo file for some reason.
	@NEWLINE=$$'\n'; \
	DEST_DIR=`realpath $(DEST_DIR)`; \
	echo "source $(DEST_DIR)/$(KERNEL_NAME)_ex/imports/package_kernel.tcl$${NEWLINE}package_project $$DEST_DIR/$(KERNEL_NAME)_ex/$(KERNEL_NAME) xilinx kernel $(KERNEL_NAME)$${NEWLINE}package_xo -xo_path $$DEST_DIR/$(KERNEL_NAME)_ex/sdx_imports/$(KERNEL_NAME).xo -kernel_name $(KERNEL_NAME) -ip_directory $$DEST_DIR/$(KERNEL_NAME)_ex/$(KERNEL_NAME) -kernel_xml $$DEST_DIR/$(KERNEL_NAME)_ex/imports/kernel.xml" > $(DEST_DIR)/$(KERNEL_NAME)_ex/package_source_kernel.tcl
	vivado -mode batch -source "$(DEST_DIR)/$(KERNEL_NAME)_ex/package_source_kernel.tcl" "$(DEST_DIR)/$(KERNEL_NAME)_ex/$(KERNEL_NAME)_ex.xpr"

edit_kernel: $(USER_KERNEL_ADDED_FILE)
	vivado "$(DEST_DIR)/$(KERNEL_NAME)_ex/$(KERNEL_NAME)_ex.xpr" &

.PHONY: shell xo project edit_kernel
shell: $(SHELL_REP)
xo: $(XO_FILE)
project: $(USER_KERNEL_ADDED_FILE)


$(DEST_DIR)/$(KERNEL_EXE).xclbin: $(XO_FILE)
	cd $(DEST_DIR); $(VPP) -g --platform $(AWS_PLATFORM) --target $(BUILD_TARGET) --link -O quick --save-temps $(REPORT) --kernel $(KERNEL_NAME) --input_files ../../$(XO_FILE) $(KERNEL_LDCLFLAGS) $(KERNEL_FLAGS) $(KERNEL_ADDITIONAL_FLAGS) --output $(KERNEL_EXE).xclbin

# Create the AFI.
# The steps are:
#   Start AFI creation process, which runs in the background and puts the values of the AFI IDs in <timestamp>_afi_id.txt.
#   Wait for the process to complete.
#   Make AFI public.
#   Delete S3 files to avoid charges.
ifneq ($(USE_PREBUILT), true)
$(BUILD_DIR)/$(KERNEL_EXE).awsxclbin: $(DEST_DIR)/$(KERNEL_EXE).xclbin
	mkdir -p $(DEST_DIR)
	@# These files are created. Clean up any from old builds.
	rm $(DEST_DIR)/*_afi_id.txt 2> /dev/null || true
	rm -rf $(DEST_DIR)/to_aws 2> /dev/null || true
	$(info Building AFI using bucket "$(S3_BUCKET)" with output folder "$(S3_DCP_KEY)" and log folder "$(S3_LOGS_KEY)")
	@# Create bucket if it doesn't exist.
	aws s3api create-bucket --bucket '$(S3_BUCKET)' --acl private > /dev/null && aws s3api wait bucket-exists --bucket '$(S3_BUCKET)'
	# Create AFI and Wait for creation to complete. afi-<id> and <timestamp>_afi_id.txt are extracted into files for use.
	cd $(DEST_DIR) && $(VITIS_DIR)/tools/create_vitis_afi.sh -xclbin=$(KERNEL_EXE).xclbin -o=$(KERNEL_NAME) -s3_bucket=$(S3_BUCKET) -s3_dcp_key=$(S3_DCP_KEY) -s3_logs_key=$(S3_LOGS_KEY) -aws_profile_name=$(AWS_PROFILE) \
	  && grep '"afi-' *_afi_id.txt | sed 's/^.*"\(afi-[0-9a-zA-Z]*\)".*$$/\1/' > $(KERNEL_NAME)_afi_id.txt \
	  && ls *_afi_id.txt | sed 's/^\(.*\)_afi_id.txt$$/\1/' > $(KERNEL_NAME)_timestamp.txt \
	  && wait_for_afi.py --afi "$$(cat $(KERNEL_NAME)_afi_id.txt)"
	@# Delete S3 files to avoid charges.
	aws s3 rm --profile $(AWS_PROFILE) --recursive 's3://$(S3_BUCKET)/$(S3_DCP_KEY)/$$(cat $(KERNEL_NAME)_timestamp.txt)*'
	aws s3 rm --profile $(AWS_PROFILE) --recursive 's3://$(S3_BUCKET)/$(S3_LOGS_KEY)/$$(cat $(KERNEL_NAME)_timestamp.txt)*'
endif

.PHONY: push
# Push the entire contents of the app directory for running on F2. (TODO: Be more selective.)
# Previous transfer contents are deleted.
push: build
	aws s3 sync .. s3://$(S3_BUCKET)/$(S3_TRANSFER_KEY)/ --profile $(AWS_PROFILE)

endif  # End Xilinx build stuff.

# Phony targets for intermediate results
.PHONY: host xo xclbin emulation build launch
host: $(DEST_DIR)/$(HOST_EXE)
host_debug: $(DEST_DIR)/$(HOST_EXE)_debug
#xo: $(DEST_DIR)/$(KERNEL_EXE).xo
xclbin: $(DEST_DIR)/$(KERNEL_EXE).xclbin

ifeq ($(BUILD_TARGET), hw_emu)
HOST_XCLBIN=$(DEST_DIR)/$(KERNEL_EXE).xclbin
endif
ifeq ($(BUILD_TARGET), hw)
HOST_XCLBIN=$(BUILD_DIR)/$(KERNEL_EXE).awsxclbin
# HW targets
.PHONY: awsxclbin afi
awsxclbin: $(HOST_XCLBIN)
afi: awsxclbin
endif

# TODO: Need sdx_project and sdx_workspace targets to build SDx workspace/project configured to work w/ the host application.


# For production use of port 80.
# Run is done in its own directory to avoid socket collision with development.
# $(LAUNCH_DIR)/live indicates that the server is live.
# $(LAUNCH_DIR)/dead indicates that the server is dead.

.PHONY: live dead

# TODO: "live" target runs in its own directory. We've since added support for LAUNCH_ID, which provides a generic separation
#       of microservices. This could be used instead.
live: $(LAUNCH_DIR)/live
$(LAUNCH_DIR)/live: $(LAUNCH_DIR)/dead $(BUILD_TARGETS)
	@# Copy executables to launch dir to avoid impact from active development. Not sure how necessary this is.
	@cp $(BUILD_DIR)/$(HOST_EXE) $(LAUNCH_DIR)
ifeq ($(USE_XILINX),true)
	@cp $(HOST_XCLBIN) $(LAUNCH_DIR)
endif
	@# TODO: What about copying the launch script? If this is changed, will that affect the running server?
	@# TODO: Not sure it's necessary to set make vars. These might pass through as environment vars.
	@echo "Launching production server in the background"
	$(call with_secret,$(LAUNCH_PASSWORD) $(LAUNCH_CMD))
	-rm $(LAUNCH_DIR)/dead
	touch $(LAUNCH_DIR)/live
	@echo "Went live!!!   (Stop with 'make$(LAUNCH_ID_ARG_STR) dead' or restart by reexecuting this command.)"

dead: $(LAUNCH_DIR)/dead
$(LAUNCH_DIR)/dead:
	if [[ -e $(KILLME) ]]; then source $(KILLME) > /dev/null 2>&1 && echo "Giving web server time to exit gracefully." && sleep 7; $(ALREADY_DEAD) fi
	@mkdir -p $(LAUNCH_DIR) log
	rm -rf $(LAUNCH_DIR)/*
	@touch $(LAUNCH_DIR)/dead



PHONY: build launch
build: $(BUILD_TARGETS)

LAUNCH_CHECK=@if [ -e $(KILLME) ]; then echo "Error: There appears to already be an application running. Kill it with <Ctrl-C> or 'source $(KILLME)', or, if not running, 'rm $(KILLME)', and try again." && false; fi
launch: $(BUILD_TARGETS)
	$(LAUNCH_CHECK)
	@mkdir -p $(LAUNCH_DIR)
	$(call with_secret,$(LAUNCH_PASSWORD) $(LAUNCH_CMD))

# An un-documented target to launch the web server and open Chrome to test it.
# Requires $(CHROME) and works only for applications that open the websocket.
chrome: $(BUILD_TARGETS)
	$(LAUNCH_CHECK)
	@# Launch Chrome in background and webserver in foreground in "one-shot" mode (exit when websocket is closed).
	$(call with_secret,$(LAUNCH_PASSWORD) $(CHROME) -app='http:localhost:8888' & $(LAUNCH_CMD_PARTIAL) -p $(PORT) -o $(BUILD_TARGET) '$(HOST_CMD)')


ifeq ($(BUILD_TARGET), hw)
.PHONY: prebuild
prebuild: $(BUILD_DIR)/$(HOST_EXE) $(HOST_XCLBIN)
	# Name the AFI.
	aws ec2 modify-fpga-image-attribute --profile $(AWS_PROFILE) --fpga-image-id $$(cat $(DEST_DIR)/$(KERNEL_NAME)_afi_id.txt) --name "1st-CLaaS_$(KERNEL_NAME).$$(cat $(KERNEL_NAME)_timestamp.txt)"
ifeq ($(AFI_PERMISSION),public)
	# Making AFI public.
	aws ec2 modify-fpga-image-attribute --profile $(AWS_PROFILE) --fpga-image-id $$(cat $(DEST_DIR)/$(KERNEL_NAME)_afi_id.txt) --operation-type add --user-groups all
endif
	# Populating /prebuilt dir.
	mkdir -p $(subst ../out, ../prebuilt, $(DEST_DIR))
	cp $(DEST_DIR)/$(HOST_EXE)             $(subst ../out, ../prebuilt, $(DEST_DIR))/$(HOST_EXE)
	cp $(DEST_DIR)/$(KERNEL_EXE).awsxclbin $(subst ../out, ../prebuilt, $(DEST_DIR))/$(KERNEL_EXE).awsxclbin
endif


.PHONY: debug_prints
debug_prints:
	$(info host path: $(DEST_DIR)/$(HOST_EXE))




###################################
# Instance Targets
###################################

FIRST_CLAAS_REMOTE_REPO_DIR ?=/home/ubuntu/src/project_data/repo

# Create a new Static Accelerated Instance. See Makefile header comments for usage info.
# WARNING: This target launches a new instance. Be sure it is not left running!
# Default INSTANCE_NAME, INSTANCE_STORAGE, INSTANCE_TYPE, INSTANCE_CONFIG_SCRIPT based on target. (Doesn't work if multiple targets are given.)
# Defaults, in case instance target is unrecognized
#INSTANCE_NAME=1st-CLaaS
#INSTANCE_STORAGE=0
INSTANCE_TYPE=UNDEFINED
INSTANCE_CONFIG_SCRIPT=UNDEFINED
ifneq ($(findstring development_instance,$(MAKECMDGOALS)),)
	INSTANCE_NAME=1st-CLaaS_devel
	INSTANCE_STORAGE=15
	INSTANCE_TYPE=c4.2xlarge
	INSTANCE_CONFIG_SCRIPT=$(FIRST_CLAAS_REMOTE_REPO_DIR)/framework/terraform/config_instance_dev.sh
endif

#F1 instance discontinued by aws
#ifneq ($(findstring f1_instance,$(MAKECMDGOALS)),)
#	INSTANCE_NAME=1st-CLaaS_run
#	#INSTANCE_STORAGE=15
#	INSTANCE_TYPE=f1.2xlarge
#	INSTANCE_CONFIG_SCRIPT=$(FIRST_CLAAS_REMOTE_REPO_DIR)/framework/terraform/config_instance_dev.sh
#endif
#ifneq ($(findstring static_accelerated_instance,$(MAKECMDGOALS)),)
#	INSTANCE_NAME=1st-CLaaS_$(KERNEL_NAME)_accelerator
#	INSTANCE_STORAGE=5
#	INSTANCE_TYPE=f1.2xlarge
#	INSTANCE_CONFIG_SCRIPT=$(FIRST_CLAAS_REMOTE_REPO_DIR)/framework/terraform/config_static_f1_instance.sh
#endif

ifneq ($(findstring f2_instance,$(MAKECMDGOALS)),)
	INSTANCE_NAME=1st-CLaaS_run
	INSTANCE_STORAGE=20
	INSTANCE_TYPE=f2.6xlarge
	INSTANCE_CONFIG_SCRIPT=$(FIRST_CLAAS_REMOTE_REPO_DIR)/framework/terraform/config_instance_dev.sh
endif
ifneq ($(findstring static_accelerated_instance,$(MAKECMDGOALS)),)
	INSTANCE_NAME=1st-CLaaS_$(KERNEL_NAME)_accelerator
	INSTANCE_STORAGE=10
	INSTANCE_TYPE=f2.6xlarge
	INSTANCE_CONFIG_SCRIPT=$(FIRST_CLAAS_REMOTE_REPO_DIR)/framework/terraform/config_static_f2_instance.sh
endif

ifdef INSTANCE_NAME
  INSTANCE_NAME_FILTER=--filter 'Name=tag:Name,Values=$(INSTANCE_NAME)'
else
  INSTANCE_NAME_FILTER=
endif
# By default, each instance is an independent setup.
SETUP=$(INSTANCE_NAME)
S3_TF_KEY=tf_setups/$(SETUP)

GIT_URL ?=$(shell git config --get remote.origin.url)
GIT_BRANCH ?=$(shell git branch | grep \* | cut -d ' ' -f2)

# Build up TF_ARGS (without evaluating)
# Sometimes admin_pwd is not needed/used. If not given, we'll use a random value, assuming it isn't needed, but ensuring that it's difficult to guess, just in case.

# Try to read a session token (empty if none)
AWS_SESSION_TOKEN_CLI := $(shell aws configure get aws_session_token --profile $(AWS_PROFILE) 2>/dev/null)

# Only set TF_SESSION_VAR if its nonempty
ifdef AWS_SESSION_TOKEN_CLI
  TF_SESSION_VAR := -var "aws_session_token=$(AWS_SESSION_TOKEN_CLI)"
else
  TF_SESSION_VAR :=
endif

ifdef PASSWORD
	TF_ARGS1=-var 'admin_pwd= {{{$(PASSWORD)}}} '
else
	TF_ARGS1=-var 'admin_pwd= {{{$(shell echo $$RANDOM)}}} '
endif
ifeq ($(PREBUILT),true)
	TF_ARGS2=-var 'use_prebuilt_afi=true'
else
	TF_ARGS2=
endif
TF_ARGS3=-var 'instance_name=$(INSTANCE_NAME)' -var 'sdb_device_size=$(INSTANCE_STORAGE)'
TF_ARGS4=-var 'instance_type=$(INSTANCE_TYPE)' \
		 -var "aws_access_key_id=$$(aws configure get aws_access_key_id --profile $(AWS_PROFILE))" \
		 $(TF_SESSION_VAR)
TF_ARGS5=-var "aws_secret_access_key=$$(aws configure get aws_secret_access_key --profile $(AWS_PROFILE))" \
		 $(TF_SESSION_VAR) \
		 -var 'aws_profile=$(AWS_PROFILE)'
TF_ARGS6=-var "region=$$(aws configure get region --profile $(AWS_PROFILE))" -var 'repo_dir=$(ABS_REPO)' -var 'git_url=$(GIT_URL)' -var 'git_branch=$(GIT_BRANCH)'
ifeq ($(AUTO_APPROVE),true)
TF_AUTO_APPROVE_ARG=--auto-approve
else
TF_AUTO_APPROVE_ARG=
endif
ifdef TFVAR
	TF_ARGS7='-var-file=$(TFVAR)'
else
	TF_ARGS7=
endif

TF_ALL_ARGS=$(TF_ARGS1) $(TF_ARGS2) $(TF_ARGS3) $(TF_ARGS4) $(TF_ARGS5) $(TF_ARGS6) $(TF_ARGS7)
TF_DESTROY_ARGS=
TF_COMMON_ARGS=$(TF_AUTO_APPROVE_ARG) $(TF_ARGS1) $(TF_ARGS4) $(TF_ARGS5) $(TF_ARGS6) $(TF_ARGS)


# Macro to run terraform command. $1 contains terraform args.
# Generic .tf file is configured for user and setup before running terraform.
define terraform
	# Setting up and running Terraform in a new directory.
	[[ -n '$(SETUP)' ]]  # $(SETUP) must be defined.
	@#rm -rf '$(REPO)/tmp/$(SETUP)'
	@mkdir -p '$(REPO)/tmp/$(SETUP)'
	rm -f '$(REPO)/tmp/$(SETUP)/'*.* # '$(REPO)/tmp/$(SETUP)/.terraform/terraform.tfstate'
	cd '$(REPO)/tmp/$(SETUP)' \
	&& cp '$(ABS_REPO)/framework/terraform/ec2_instance.tf' . \
	&& sed -i 's/<<S3_BUCKET>>/$(S3_BUCKET)/' ec2_instance.tf \
	&& sed -i 's|<<S3_KEY>>|$(S3_TF_KEY)|' ec2_instance.tf \
	&& sed -i "s/<<REGION>>/$$(aws configure get region --profile $(AWS_PROFILE))/" ec2_instance.tf
	$(call with_secret,cd '$(REPO)/tmp/$(SETUP)' &&  $(ABS_REPO)/terraform/terraform init && '$(ABS_REPO)/terraform/terraform' $1 $(TF_COMMON_ARGS) |& tee terraform.log)
endef
.PHONY: static_accelerated_instance development_instance
TF_OUT_DIR=$(HOME)/.ssh/$(SETUP)
define make_instance
	@# Instance will be initialized with 1st-CLaaS repo cloned from remote, but there is an issue if the remote is not using https: ssh will require interactive verification which hangs script.
	@if [[ ! '$(GIT_URL)' =~ ^https: ]]; then echo -e '\e[91m\e[1m1st CLaaS repo must use "https" protocol, but is "$(GIT_URL)". Provide git repo to use on remote instance, e.g. "GIT_URL=https://github.com/xxx/1st-CLaaS.git", or use "git remote set-url origin https:..."./\e[0m' && false; fi
	@if ! git status | grep 'working tree clean' > /dev/null; then echo && echo -e '\e[91m\e[1mInstance construction can have unexpected behavior when working directory is not clean.\e[0m' && echo && sleep 2; fi
	@echo 'Instance will be initialized based on latest "$(GIT_BRANCH)" branch.' && echo
	$(call terraform,apply -var 'kernel=$(KERNEL_NAME)' -var 'config_instance_script=$(INSTANCE_CONFIG_SCRIPT)' -var "out_dir=$(TF_OUT_DIR)" $(TF_ALL_ARGS))
	@echo 'This instance and its associated resources can be destroyed with:'
	@echo '   > make destroy SETUP=$(SETUP)'
	@# Set password. (This will find the correct instance via $INSTANCE_NAME_FILTER.)
	@# Do so without echoing command to avoid password in output (though, most-likely, it was typed in the first place).
	@if [[ -n '$(LINUX_PASSWORD)' ]]; then \
	    echo "Setting Linux password (final step)…"; \
	    sudo sed -i 's/^#\?PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config; \
	    sudo systemctl restart sshd; \
	    make ssh SSH_CMD='echo "ubuntu:$(LINUX_PASSWORD)" | sudo chpasswd'; \
	fi
endef
ifneq ($(KERNEL_NAME),framework)
static_accelerated_instance:
	$(make_instance)
development_instance:
	@echo "development_instance target is available only from /framework/build directory (when KERNEL_NAME variable is not defined)."
#f1_instance:
#	@echo "f1_instance target is available only from /framework/build directory (when KERNEL_NAME variable is not defined)."
f2_instance:
	@echo "f2_instance target is available only from /framework/build directory (when KERNEL_NAME variable is not defined)."
else
static_accelerated_instance:
	@echo "static_accelerated_instance target must have KERNEL_NAME variable defined."
development_instance:
	$(make_instance)
f2_instance:
	$(make_instance)
endif

# Connect to the single running EC2 instance.
define connect
	DNS=$$(aws ec2 describe-instances --profile $(AWS_PROFILE) --query "Reservations[*].Instances[*].PublicDnsName" $(INSTANCE_NAME_FILTER) --output=text | tr -d '\n') && \
	COUNT=$$(echo "$$DNS" | wc -w) && \
	INSTANCE_NAME=$$(aws ec2 describe-instances --profile $(AWS_PROFILE) --filters "Name=dns-name,Values=$$DNS" --query 'Reservations[].Instances[].Tags[?Key==`Name`].Value' --output=text | tr -d '\n') && \
	PRIVATE_KEY=$$(realpath ~/".ssh/$$INSTANCE_NAME/private_key.pem") && \
	echo "$1 $$INSTANCE_NAME ($$DNS)" && \
	mkdir -p ../out && \
	$2
endef

.PHONY: desktop ssh
desktop:
	@# Call remmina using template.remmina configuration with "TBD" values substituted. (perl is used to substitute arbitrary literal text.)
	$(call connect,Connecting via RDP using Remmina to,\
		TMP="$$PRIVATE_KEY" perl -p -e 's/^ssh_privatekey=TBD/ssh_privatekey=$$ENV{TMP}/' < "$(FRAMEWORK_DIR)/build/template.remmina" > "$(FRAMEWORK_DIR)/out/tmp.remmina" && \
		sed -i "s/^server=TBD/server=$$DNS/" "$(FRAMEWORK_DIR)/out/tmp.remmina" && \
		remmina -c "$(FRAMEWORK_DIR)/out/tmp.remmina" &)

ssh:
	$(call connect,Connecting via SSH to,\
		ssh -oStrictHostKeyChecking=no -X -i "$$PRIVATE_KEY" ubuntu@$$DNS '$(SSH_CMD)')

ip:
	$(call connect,Running instance with Public DNS:,true)

.PHONY: destroy
destroy:
	$(call terraform,destroy $(TF_DESTROY_ARGS))
	aws s3 rm 's3://$(S3_BUCKET)/tf_setups/$(SETUP)' --profile $(AWS_PROFILE)
	@echo 'Destroyed instance/setup $(SETUP)'
	@if [[ -d $(TF_OUT_DIR) ]]; then rm $(TF_OUT_DIR)/public_key.pem && rm $(TF_OUT_DIR)/private_key.pem && rmdir $(TF_OUT_DIR) && echo 'Deleted $(TF_OUT_DIR) containing TLS keys'; else echo 'No directory $(TF_OUT_DIR). Perhaps another user still has these obsolete TLS keys?'; fi

.PHONY: list_setups
list_setups:
	@echo "Setups that can be used with 'make destroy SETUP=XXX':"
	echo "Setups:" && aws s3 ls 's3://$(S3_BUCKET)/tf_setups/' --profile $(AWS_PROFILE) || true

.PHONY: copy_app
copy_app:
	if [[ -n '$(APP_NAME)' ]]; then $(REPO)/bin/copy_app '$(KERNEL_NAME)' '$(APP_NAME)'; else echo -e '\e[91m\e[1mAPP_NAME must be provided.\e[0m'; fi
