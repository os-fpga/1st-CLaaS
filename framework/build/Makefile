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


# Includes SDAccel 2017.1 Makefile functionality and general functionality for fpga-webserver.
#
# Terminology (Move to README):
#   Landing Web Server: The public-facing web server providing the landing page for an application (in contrast to an Accelerated
#                       Web Server, though these could be one in the same).
#   Accelerated Web Server: A web server utilizing an attached FPGA or FPGA emulation (running on an Amazon F1 Instance or emulated
#                           on a C4 Instance or future platform)
#   Accelerated Instance: An EC2 Instance (or future platform) running an Accelerateed Web Server.
#   Static Accelerated Web Server: An Accelerated Web Server Instance that is statically associated with a Landing Web Server.
#                                  It is shared by all users and may be dynamically started and stopped and will be stopped by an
#                                  EC2 time bomb.
#   EC2 Feeder: A utility provided in this repository responsible for stopping/terminating EC2 Instances (Accelerated Instances)
#               when not in use.
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
#   Variables:
#     PORT: The port on which to launch the webserver.
#     TARGET=[hw, hw_emu, sim, sw] (determined by platform by default)
#              hw: F1 FPGA.
#              hw_emu: SDAccel hardware emulation compilation.
#              sim: Verilator simulation of the kernel.
#              sw: software-only with no kernel behavior available.
#            Target is downgraded automatically based on the platform.
#     PREBUILT=[true] or default to false behavior. True to use the prebuilt files in the repository, rather than building.
#     WAVES=[true] or default to false behavior. True to generate waveforms. (xocc )
#     S3_BUCKET=bucket_name: provides a name for the S3 bucket to use for the AFI (.awsxclbin) build.
#     S3_LOGS_KEY=folder: the S3 bucket folder to use for logs for the AFI build.
#     S3_DCP_KEY=folder: the S3 bucket folder to use for logs for the AFI build.
#     VALGRIND=[true] or default to false behavior. True to use Valgrind to identify memory leaks in the host application.
#     NOHUP=true: Can be used with 'launch' target to launch in background and stay running after the shell exits. (This is implied by 'make live').
#   Eg:
#     make host TARGET=hw_emu
#
#   Platform Targets (for constructing the multi-server platform):
#     By default to create a new Static Accelerated Instance, for an application, to be associated with the Content Web Server, use:
#        make PASSWORD=XXX PREBUILT=false/true TFVAR=$HOME/aws_cred.tfvars static_accelerated_instance  # (or omit variables to be prompted.)
#        #    PASSWORD: (prompts as admin_pwd) might be used by webserver to authenticate administrative actions from a client.
#        #    PREBUILT: (prompts as use_prebuilt_afi) provided to 'make live' of the F1 (or C4 for debug) instance.
#        #    EC2_TYPE: Use c4 for testing without FPGA.
#        #    INSTANCE_NAME: Name of the instance.
#        #    TFVAR:    A single .tfvars file. To avoid prompts, this should contain:
#        #                aws_access_key_id="XXX"
#        #                aws_secret_access_key="XXX"
#        #                region="XXX"   # Eg: "us-east-1"
#        #              (It may also provide admin_pwd and use_prebuilt_afi.)
#        #    TF_ARGS: (opt) Additional arguments for Terraform.
#        WARNING: This launches a new instance. Be sure it is not left running!
#     To associate F1, with this Content Web Server use:
#        make INSTANCE=i-xxxxxxx PASSWORD=<password> PROFILE=<aws-profile> ...
#        #    PASSWORD: used by this web server (not F1) to authenticate administrative actions; probably best to use the same PASSWORD for F1.


SHELL=/bin/bash
COMMA:= ,
EMPTY:=
SPACE:= $(EMPTY) $(EMPTY)


# Characcterize platform.

VERILATOR=$(shell which verilator)
ifneq ($(AWS_FPGA_REPO_DIR),)
ifneq ($(findstring f1.,$(shell curl http://169.254.169.254/latest/meta-data/instance-type)),)
# F1
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

# Determine BUILD_TARGET. [hw (default) | hw_emu | sim | sw]

TARGET=hw
SPECIFIED_TARGET :=$(TARGET)
BUILD_TARGET :=$(TARGET)
# If specified TARGET is not supported, choose a different one.
ifeq ($(findstring $(BUILD_TARGET) |,$(SUPPORTED_TARGETS)),)
#If sim is not supported, downgrade to sw
ifeq ($(BUILD_TARGET),sim)
BUILD_TARGET :=sw
else
# Downgrade to highest-level target.
BUILD_TARGET :=$(firstword $(SUPPORTED_TARGETS))
endif
endif
ifeq ($(BUILD_TARGET),)
$(info Your platform does not support TARGET=$(SPECIFIED_TARGET).)
endif
$(info Using TARGET=$(BUILD_TARGET). (Platform supports: | $(SUPPORTED_TARGETS)))

# Characterize BUILD_TARGET.
ifeq ($(BUILD_TARGET),hw)
USE_XILINX=true
endif
ifeq ($(BUILD_TARGET),hw_emu)
USE_XILINX=true
endif


# Can only do PREBUILT=true w/ TARGET=hw.
ifneq ($(TARGET),hw)
  USE_PREBUILT=false
else
  USE_PREBUILT=$(PREBUILT)
endif



# Determine kernel name from current directory.
KERNEL_NAME ?= $(shell realpath $$(pwd) | sed 's|^.*/\([^/]*\)/build$$|\1|')

HW_SHELL_CONFIG_JSON ?=../../../framework/fpga/default_shell_config.json


PORT ?= 8888


# Python Web Server Command

WEBSERVER_ARGS :=
ifdef INSTANCE
  WEBSERVER_ARGS :=$(WEBSERVER_ARGS) --instance $(INSTANCE)
endif
ifdef PASSWORD
  WEBSERVER_ARGS :=$(WEBSERVER_ARGS) --password $(PASSWORD)
endif
ifdef PROFILE
  WEBSERVER_ARGS :=$(WEBSERVER_ARGS) --profile $(PROFILE)
endif

WEBSERVER_PY ?= $(shell if [[ -e "../webserver/$(KERNEL_NAME)_server.py" ]]; then echo "../webserver/$(KERNEL_NAME)_server.py"; else echo "../../../framework/webserver/default_server.py"; fi)
LAUNCH_W ?=python3 $(WEBSERVER_PY) --port=<<PORT>> $(WEBSERVER_ARGS)




# For transfer from the build instance to the F1 instance.
ifndef S3_USER
S3_USER_PATH=
else
S3_USER_PATH=$(S3_USER)/
endif
ifndef S3_BUCKET
S3_BUCKET=fpga-webserver
endif
S3_LOGS_KEY=${S3_USER_PATH}$(KERNEL_NAME)/log
S3_DCP_KEY=${S3_USER_PATH}$(KERNEL_NAME)/dcp
S3_TRANSFER_KEY=${S3_USER_PATH}$(KERNEL_NAME)/xfer

XOCC=xocc
CC=g++


HOST_DIR=../host
FRAMEWORK_DIR=../../../framework
FRAMEWORK_HOST_DIR=$(FRAMEWORK_DIR)/host

EXTRA_C_SRC ?=
EXTRA_C_HDRS ?=
PROJ_C_SRC ?=$(shell ls ../host/*.c ../host/*.cpp ../host/*.C ../host/*.cxx 2> /dev/null)
PROJ_C_HDRS ?=$(shell ls ../host/*.h ../host/*.hpp ../host/*.H ../host/*.hxx 2> /dev/null)
PROJ_SW_CFLAGS ?=
PROJ_SW_LFLAGS ?=

#Software (no FPGA) flags
SW_SRC ?= $(FRAMEWORK_HOST_DIR)/server_main.c $(PROJ_C_SRC) $(EXTRA_C_SRC)
SW_HDRS ?= $(FRAMEWORK_HOST_DIR)/protocol.h $(FRAMEWORK_HOST_DIR)/server_main.h $(PROJ_C_HDRS) $(EXTRA_C_HDRS)
SW_CFLAGS ?= -g -Wall -O3 -std=c++11 -I$(HOST_DIR) -I$(FRAMEWORK_HOST_DIR) -I../../../framework/host/json/include $(PROJ_SW_CFLAGS)
SW_LFLAGS ?= -L${XILINX_XRT}/lib $(PROJ_SW_LFLAGS)

#Host code
HOST_SRC=$(SW_SRC) $(FRAMEWORK_HOST_DIR)/hw_kernel.c
HOST_HDRS=$(SW_HDRS) $(FRAMEWORK_HOST_DIR)/kernel.h
HOST_HDRS=$(SW_HDRS) $(FRAMEWORK_HOST_DIR)/hw_kernel.h
# TODO: It seems SDX_PLATFORM should be set to a value. For hw_emu, I see one device: "xilinx:pcie-hw-em:7v3:1.0"
#       What's the emconfigutil command (for configuring the platform for hw_emu?)
HOST_CFLAGS=$(SW_CFLAGS) -D KERNEL_AVAIL -D FPGA_DEVICE -D OPENCL -I${XILINX_XRT}/runtime/include/1_2 -D C_KERNEL -D SDX_PLATFORM=$(PLATFORM) -D KERNEL=$(KERNEL_NAME)
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
KERNEL_HDRS=
KERNEL_FLAGS=
KERNEL_EXE=$(KERNEL_NAME)

#Custom flag to give to xocc
KERNEL_LDCLFLAGS=--nk $(KERNEL_NAME):1 \
	--xp param:compiler.preserveHlsOutput=1 \
	--max_memory_ports $(KERNEL_NAME) \
	--memory_port_data_width $(KERNEL_NAME):512 \

KERNEL_ADDITIONAL_FLAGS=

#Device to be used
TARGET_DEVICE=xilinx:aws-vu9p-f1:4ddr-xpr-2pr:4.0

#Check if environment is an AWS one or not
ifndef AWS_PLATFORM
$(info setting platform for a non-aws environment)
PLATFORM=xilinx:aws-vu9p-f1:4ddr-xpr-2pr:4.0
else
$(info setting platform for an aws environment)
PLATFORM=${AWS_PLATFORM}
endif

REPORT=
ifeq (${BUILD_TARGET},hw)
REPORT=--report system
else
ifeq (${BUILD_TARGET},hw_emu)
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

# 'live' target.
ifeq ($(MAKECMDGOALS),live)
NOHUP=true
PORT=80
HOST_EXE_PATH=../live/$(BUILD_TARGET)/$(HOST_EXE)
else
HOST_EXE_PATH=$(BUILD_DIR)/$(HOST_EXE)
endif

#Assign DEST_DIR as <BUILD_TARGET>/<TARGET_DEVICE>, or just <BUILD_TARGET> for sw build (w/ no target device).
ifneq ($(USE_XILINX),true)
DEST_DIR=../$(OUT_DIR_NAME)/$(BUILD_TARGET)
BUILD_DIR=../$(BUILD_DIR_NAME)/$(BUILD_TARGET)
else
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

# If project has a launch command, use it, otherwise, use launch from framework.
LAUNCH_CMD_PARTIAL :=$(shell if [[ -e ./launch ]]; then echo ./launch; else echo ../../../framework/build/launch; fi)
ifdef LAUNCH_W
LAUNCH_CMD_PARTIAL :=$(LAUNCH_CMD_PARTIAL) -w '$(LAUNCH_W)'
endif
ifdef NOHUP
# Run in background to continue if the shell exits; log to webserver.log and cut off stdin to detach from the launching process's stdin (so ssh/etc can exit).
LAUNCH_CMD=nohup $(LAUNCH_CMD_PARTIAL) -p $(PORT) $(BUILD_TARGET) '$(HOST_CMD)' &> webserver.log < /dev/null &
else
LAUNCH_CMD=$(LAUNCH_CMD_PARTIAL) -p $(PORT) $(BUILD_TARGET) '$(HOST_CMD)'
endif


# TL-Verilog compilation.
# fpga/src/*.tlv are taken as top-level TLV files.
# fpga/src/*.tlvlib are taken as TLV library files, provided for every SandPiper run (which is network overhead whether used or not).
#KERNEL_TLV=../fpga/src/$(KERNEL_NAME)_kernel.tlv
TLV=$(shell ls ../fpga/src/*.tlv 2> /dev/null)
SV_SRC=$(shell ls ../fpga/src/*.sv ../fpga/src/*.v 2> /dev/null)
VH_SRC=$(shell ls ../fpga/src/*.vh 2> /dev/null)
TLVLIB=$(shell ls ../fpga/src/*.tlvlib 2> /dev/null)
SV_FROM_TLV=$(patsubst ../fpga/src/%.tlv,../out/sv/%.sv,$(TLV))
SP_CURL_FILES=$(patsubst ../fpga/src/%.tlvlib,-F 'files[]=@../../../fpga/src/%.tlvlib',$(TLVLIB))


ifeq ($(VALGRIND),true)
VALGRIND_PREFIX=valgrind --leak-check=yes
else
VALGRIND_PREFIX=
endif

ifneq ($(USE_XILINX),true)
BUILD_TARGETS=$(BUILD_DIR)/$(HOST_EXE)
HOST_CMD=$(HOST_EXE_PATH)
endif
ifeq ($(BUILD_TARGET),hw_emu)
BUILD_TARGETS=$(BUILD_DIR)/$(HOST_EXE) $(HOST_XCLBIN)
HOST_CMD=export XCL_EMULATION_MODE=$(BUILD_TARGET) && $(XILINX_SDX)/bin/emconfigutil --od $(DEST_DIR) --nd 1  --platform $(PLATFORM) && $(VALGRIND_PREFIX) $(HOST_EXE_PATH) $(HOST_XCLBIN)
endif
ifeq ($(BUILD_TARGET),hw)
BUILD_TARGETS=$(BUILD_DIR)/$(HOST_EXE) $(HOST_XCLBIN)
HOST_CMD=$(VALGRIND_PREFIX) $(HOST_EXE_PATH) $(HOST_XCLBIN)
endif


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

# Rule to build host application, only if not using pre-built.
ifneq ($(USE_PREBUILT), true)

# TODO: Instead of this condition, define $(SW_SRC) and $(HOST_SRC) as $(SRC) conditionally, etc.
ifneq ($(USE_XILINX),true)
ifeq (${BUILD_TARGET},sw)
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
$(DEST_DIR)/verilator: $(SV_SRC) $(SV_FROM_TLV) $(VH_SRC)
	mkdir -p $(DEST_DIR)
	verilator --cc --sv --trace -DFPGA_WEBSERVER_KERNEL $(SV_SRC) $(SV_FROM_TLV) -y ../out/sv -y ../fpga/src --Mdir $(DEST_DIR)/verilator 
$(DEST_DIR)/$(HOST_EXE): $(SIM_SRC) $(SIM_HDRS) $(DEST_DIR)/verilator
	cd $(DEST_DIR)/verilator && rm -f verilator_kernel.h && ln -s V$(KERNEL_NAME)_kernel.h verilator_kernel.h
	$(CC) $(SIM_SRC) $(SIM_CFLAGS) $(SIM_LFLAGS) $$(ls $(DEST_DIR)/verilator/*.cpp) /usr/local/share/verilator/include/verilated.cpp /usr/local/share/verilator/include/verilated_vcd_c.cpp /usr/local/share/verilator/include/verilated_threads.cpp -I $(DEST_DIR)/verilator -I /usr/local/share/verilator/include -o $(DEST_DIR)/$(HOST_EXE)
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
	mkdir -p ../out/sv/$*
ifeq ($(SANDPIPER),)
	@# Run SandPiper(TM) SaaS Edition on TLV files.
	@# SandPiper SaaS produces a zipped tarball of: out/[*.sv, stdout, status]
	cd ../out/sv/$* && curl -F 'top.tlv=@../../$<' $(SP_CURL_FILES) http://saas.makerchip.com/sandpiper | tar -zx
	cat ../out/sv/$*/out/stdout
else
	@# Use local SandPiper, given by $(SANDPIPER)
	mkdir ../out/sv/$*/out  # As would be produced by SandPiper SaaS.
	$(SANDPIPER) --iArgs --m4out ../out/sv/$*/out/$*.m4out.tlv -i ../fpga/src/$*.tlv -o ../out/sv/$*/out/$*.sv 2>&1 | tee ../out/sv/$*/out/stdout && echo $$? > ../out/sv/$*/out/status
endif
	(( $(shell cat ../out/sv/$*/out/status) < 4 ))  # Fail for errors > 3 (SYNTAX_ERROR).
	mv ../out/sv/$*/out/*.sv ../out/sv
	# Vivado requires includes to be of .vh files, so change file name.
	mv ../out/sv/$*_gen.sv ../out/sv/$*_gen.vh
	cd ../out/sv && sed -i s/$*_gen\\.sv/$*_gen\\.vh/ $*.sv



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
$(USER_KERNEL_ADDED_FILE): $(SHELL_REP) $(SV_FROM_TLV)
	@echo $(VIVADO_VERSION_MESSAGE)
	# Hacking the Xilinx template project to include the custom user kernel. (Failures in this process could leave the project in an inconsistent state.)
	@# Add user's kernel source code to project.
	@mkdir -p ../out/sv  # Must exist for add_kernel.tcl
	vivado -mode batch -nojournal -nolog -notrace -source "$(FRAMEWORK_DIR)/fpga/scripts/tcl/add_kernel.tcl" "$(DEST_DIR)/$(KERNEL_NAME)_ex/$(KERNEL_NAME)_ex.xpr"
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
#	$(XOCC) --platform $(PLATFORM) --target $(BUILD_TARGET) --compile --include $(KERNEL_HDRS) --save-temps $(REPORT) --kernel $(KERNEL_NAME) $(KERNEL_SRC) $(KERNEL_LDCLFLAGS) $(KERNEL_FLAGS) $(KERNEL_ADDITIONAL_FLAGS) --output $(DEST_DIR)/$(KERNEL_EXE).xo
#	#cp ../fpga/mandelbrot_hw/sdx_imports/$(KERNEL_EXE).xo $(DEST_DIR)/$(KERNEL_EXE).xo

# Package the project as an .xo.
# (Use: "$(XO_FILE): $(SHELL_REP)" to build with the vadd example kernel, unmodified.)
$(XO_FILE): $(USER_KERNEL_ADDED_FILE) $(SV_SRC) $(SV_FROM_TLV)
	$(info $(VIVADO_VERSION_MESSAGE))
	$(info "-----------------")
	$(info "Packaging project")
	$(info "-----------------")
	-rm $(XO_FILE) 2> /dev/null || true  # Seems to be necessary to remove the old .xo file for some reason.
	@NEWLINE=$$'\n'; \
	DEST_DIR=`realpath $(DEST_DIR)`; \
	echo "source $(DEST_DIR)/${KERNEL_NAME}_ex/imports/package_kernel.tcl$${NEWLINE}package_project $$DEST_DIR/$(KERNEL_NAME)_ex/${KERNEL_NAME} xilinx kernel ${KERNEL_NAME}$${NEWLINE}package_xo -xo_path $$DEST_DIR/$(KERNEL_NAME)_ex/sdx_imports/${KERNEL_NAME}.xo -kernel_name ${KERNEL_NAME} -ip_directory $$DEST_DIR/$(KERNEL_NAME)_ex/${KERNEL_NAME} -kernel_xml $$DEST_DIR/$(KERNEL_NAME)_ex/imports/kernel.xml" > $(DEST_DIR)/${KERNEL_NAME}_ex/package_source_kernel.tcl
	vivado -mode batch -source "$(DEST_DIR)/${KERNEL_NAME}_ex/package_source_kernel.tcl" "$(DEST_DIR)/$(KERNEL_NAME)_ex/${KERNEL_NAME}_ex.xpr"

edit_kernel: $(USER_KERNEL_ADDED_FILE)
	vivado "$(DEST_DIR)/$(KERNEL_NAME)_ex/${KERNEL_NAME}_ex.xpr" &

.PHONY: shell xo project edit_kernel
shell: $(SHELL_REP)
xo: $(XO_FILE)
project: $(USER_KERNEL_ADDED_FILE)


# Transfer (push) FPGA files from build instance to F1 instance through S3.

$(DEST_DIR)/$(KERNEL_EXE).xclbin: $(XO_FILE)
	cd $(DEST_DIR); $(XOCC) -g --platform $(PLATFORM) --target $(BUILD_TARGET) --link -O quick --include $(KERNEL_HDRS) --save-temps $(REPORT) --kernel $(KERNEL_NAME) ../../$(XO_FILE) $(KERNEL_LDCLFLAGS) $(KERNEL_FLAGS) $(KERNEL_ADDITIONAL_FLAGS) --output $(KERNEL_EXE).xclbin

# Create the AFI.
# The steps are:
#   Start AFI creation process, which runs in the background and puts the values of the AFI IDs in <timestamp>_afi_id.txt.
#   Wait for the process to complete.
#   Make AFI public.
#   Delete S3 files to avoid charges.
ifneq ($(USE_PREBUILT), true)
$(BUILD_DIR)/$(KERNEL_EXE).awsxclbin: $(DEST_DIR)/$(KERNEL_EXE).xclbin
	mkdir -p $(DEST_DIR)
	rm $(DEST_DIR)/*_afi_id.txt
	$(info Building AFI using bucket "$(S3_BUCKET)" with output folder "$(S3_DCP_KEY)" and log folder "$(S3_LOGS_KEY)")
	cd $(DEST_DIR); $(SDACCEL_DIR)/tools/create_sdaccel_afi.sh -xclbin=$(KERNEL_EXE).xclbin -o=$(KERNEL_NAME) -s3_bucket=$(S3_BUCKET) -s3_dcp_key=$(S3_DCP_KEY) -s3_logs_key=$(S3_LOGS_KEY)
	# Waiting for AFI creation to complete.
	# THESE COMMANDS ARE NOT DEBUGGED:
	# Get afi-<id> into a file in isolation.
	grep '"afi-' *_afi_id.txt | sed 's/^.*"\(afi-[0-9a-zA-Z]*\)".*$$/\1/' > $(KERNEL_NAME)_afi_id.txt
	# Get timestamp used in generated files.
	ls '_afi_id.txt' | sed 's/^\(.*\)_afi_id.txt$$/\1/' > $(KERNEL_NAME)_timestamp.txt
	wait_for_afi.py --afi "$$(cat $(KERNEL_NAME)_afi_id.txt)"
	@# Delete S3 files to avoid charges.
	aws s3 rm --recursive 's3://$(S3_BUCKET)/$(S3_DCP_KEY)/$$(cat $(KERNEL_NAME)_timestamp.txt)*'
	aws s3 rm --recursive 's3://$(S3_BUCKET)/$(S3_LOGS_KEY)/$$(cat $(KERNEL_NAME)_timestamp.txt)*'
endif

.PHONY: push
# Push the entire contents of the app directory for running on F1. (SDAccel tarball should already be in S3.)
# Previous transfer contents are deleted.
push: build
	aws s3 sync .. s3://$(S3_BUCKET)/$(S3_TRANSFER_KEY)/

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
# ../live/$(BUILD_TARGET)/live indicates that the server is live.
# ../live/$(BUILD_TARGET)/dead indicates that the server is dead.

.PHONY: live dead

live: ../live/$(BUILD_TARGET)/live
../live/$(BUILD_TARGET)/live: ../live/$(BUILD_TARGET)/dead $(BUILD_TARGETS)
	cp $(BUILD_DIR)/$(HOST_EXE) ../live/$(BUILD_TARGET)
ifeq ($(USE_XILINX),true)
	cp $(HOST_XCLBIN) ../live/$(BUILD_TARGET)
endif
	# TODO: What about copying the launch script? It this is changed, will that affect the running server?
	# TODO: Not sure it's necessary to set make vars. These might pass through as environment vars.
	@echo "Launching production server in the background"
	$(LAUNCH_CMD)
	-rm ../live/$(BUILD_TARGET)/dead
	touch ../live/$(BUILD_TARGET)/live
	@echo "Went live!!!   (Stop with 'make dead' or restart with 'make live' again.)"

dead: ../live/$(BUILD_TARGET)/dead
../live/$(BUILD_TARGET)/dead:
	if [[ -e killme ]]; then source killme > /dev/null 2>&1 && echo "Giving webserver time to exit gracefully." && sleep 7; fi
	@mkdir -p ../live/$(BUILD_TARGET)
	rm -rf ../live/$(BUILD_TARGET)/*
	@touch ../live/$(BUILD_TARGET)/dead



PHONY: build
build: $(BUILD_TARGETS)
	
launch: $(BUILD_TARGETS)
	@if [ -e killme ]; then echo "Error: There appears to already be an application running. Kill it with <Ctrl-C> or 'source killme', or, if not running, 'rm killme', and try again." && false; fi
	$(LAUNCH_CMD)


ifeq ($(BUILD_TARGET), hw)
.PHONY: prebuild
prebuild: $(BUILD_DIR)/$(HOST_EXE) $(HOST_XCLBIN)
	# Name the AFI.
	aws ec2 modify-fpga-image-attribute --fpga-image-id $$(cat $(KERNEL_NAME)_afi_id.txt) --name "1st_CLaaS-$(KERNEL_NAME).$$(cat $(KERNEL_NAME)_timestamp.txt)"
	# Making AFI public.
	aws ec2 modify-fpga-image-attribute --fpga-image-id $$(cat $(KERNEL_NAME)_afi_id.txt) --operation-type add --user-groups all
	# Populating /prebuilt dir.
	mkdir -p $(subst ../out, ../prebuilt, $(DEST_DIR))
	cp $(DEST_DIR)/$(HOST_EXE)             $(subst ../out, ../prebuilt, $(DEST_DIR))/$(HOST_EXE)
	cp $(DEST_DIR)/$(KERNEL_EXE).awsxclbin $(subst ../out, ../prebuilt, $(DEST_DIR))/$(KERNEL_EXE).awsxclbin
endif


.PHONY: debug_prints
debug_prints:
	$(info host path: $(DEST_DIR)/$(HOST_EXE))
	



###################################
# Platform Targets
###################################


# Create a new Static Accelerated Instance. See Makefile header comments for usage info.
# WARNING: This target launches a new instance. Be sure it is not left running!
TF_ARGS ?=
# Sometimes admin_pwd is not needed/used. If not given, we'll use a random value, assuming it isn't needed, but ensuring that it's difficult to guess, just in case.
PASSWORD ?=$(shell echo $$RANDOM)
ifdef PASSWORD
  TF_ARGS :=$(TF_ARGS) -var 'admin_pwd=$(PASSWORD)'
endif
ifeq ($(USE_PREBUILT),true)
  TF_ARGS :=$(TF_ARGS) -var 'use_prebuilt_afi=true'
endif
ifdef INSTANCE_NAME
  TF_ARGS :=$(TF_ARGS) -var 'instance_name=$(INSTANCE_NAME)'
endif
ifdef TFVAR
  TF_ARGS :=$(TF_ARGS) '-var-file=$(TFVAR)'
endif
EC2_TYPE=f1
TF_ARGS :=$(TF_ARGS) -var-file=$(EC2_TYPE).tfvars

APP_LAUNCH_SCRIPT ?=/home/centos/src/project_data/fpga-webserver/framework/terraform/deployment/f1_init.sh
.PHONY: static_accelerated_instance
static_accelerated_instance:
	cd ../../../framework/terraform/deployment && ../../../terraform/terraform init && ../../../terraform/terraform apply -auto-approve -var 'kernel=$(KERNEL_NAME)' -var 'app_launch_script=$(APP_LAUNCH_SCRIPT)' $(TF_ARGS)
