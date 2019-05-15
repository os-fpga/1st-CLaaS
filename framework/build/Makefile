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
# Usage:
#   Projects must provide a Makefile that includes this one.
#   Use mandelbrot example as a frame of reference.
#
#   Provided Targets:
#     host: the host application
#     xclbin: the FPGA image
#     build: the host application and FPGA image
#     emulation: ?
#     run_system: build and run
#     push: push application directory to S3 storage for transfer to F1 Instance
#     prebuild: populate contents of "prebuilt" directory with current build (do not set PREBUILT variable)
#     clean: remove all outputs for the given TARGET
#     live: launch or relaunch TARGET=hw on PORT=80 (without the need to be explicit.)
#     dead: kill the running production server.
#     shrink: remove some of the larger TARGET=hw build collateral files. (No "TARGET=hw" required.)
#   Variables:
#     PORT: The port on which to launch the webserver.
#     TARGET=[sw_emu, hw, hw_emu] or unspecified for software-only (no OpenCL) build of host application
#     KERNEL: the name for the fpga model
#     PREBUILT=[true] or default to false behavior. True to use the prebuilt files in the repository, rather than building.
#     WAVES=[true] or default to false behavior. True to generate waveforms. (xocc )
#     S3_BUCKET=bucket_name: provides a name for the S3 bucket to use for the AFI (.awsxclbin) build.
#     S3_LOGS_KEY=folder: the S3 bucket folder to use for logs for the AFI build.
#     S3_DCP_KEY=folder: the S3 bucket folder to use for logs for the AFI build.
#     VALGRIND=[true] or default to false behavior. True to use Valgrind to identify memory leaks in the host application.
#   Eg:
#     make host TARGET=hw_emu KERNEL=mandelbrot

PORT=8888

# For transfer from the build instance to the F1 instance.
ifndef S3_USER
S3_USER_PATH=
else
S3_USER_PATH=$(S3_USER)/
endif
ifndef S3_BUCKET
S3_BUCKET=fpga-webserver
endif
S3_LOGS_KEY=${S3_USER_PATH}$(KERNEL)/log
S3_DCP_KEY=${S3_USER_PATH}$(KERNEL)/dcp
S3_TRANSFER_KEY=${S3_USER_PATH}$(KERNEL)/xfer

XOCC=xocc
CC=g++


HOST_DIR=../host
FRAMEWORK_DIR=../../../framework
FRAMEWORK_HOST_DIR=$(FRAMEWORK_DIR)/host

PROJ_C_SRC ?=
PROJ_C_HDRS ?=
PROJ_SW_CFLAGS ?=
PROJ_SW_LFLAGS ?=
PROJ_FPGA_EXTRA_SRCS ?=    # Extra verilog source files. (All must be in ../fpga/src to be added properly to project. Clean build required if sources are added.)

#Software (no FPGA) flags
SW_SRC ?= $(FRAMEWORK_HOST_DIR)/server_main.c $(PROJ_C_SRC)
SW_HDRS=$(FRAMEWORK_HOST_DIR)/protocol.h $(FRAMEWORK_HOST_DIR)/server_main.h $(PROJ_C_HDRS)
SW_CFLAGS=-g -Wall -O3 -std=c++11 -I$(HOST_DIR) -I$(FRAMEWORK_HOST_DIR) -I../../../framework/host/json/include $(PROJ_SW_CFLAGS)
SW_LFLAGS=-L${XILINX_XRT}/lib $(PROJ_SW_LFLAGS)

#Host code
HOST_SRC=$(SW_SRC) $(FRAMEWORK_HOST_DIR)/kernel.c
HOST_HDRS=$(SW_HDRS) $(FRAMEWORK_HOST_DIR)/kernel.h
# TODO: It seems SDX_PLATFORM should be set to a value. For hw_emu, I see one device: "xilinx:pcie-hw-em:7v3:1.0"
#       What's the emconfigutil command (for configuring the platform for hw_emu?)
HOST_CFLAGS=$(SW_CFLAGS) -D FPGA_DEVICE -D OPENCL -I${XILINX_XRT}/runtime/include/1_2 -D C_KERNEL -D SDX_PLATFORM=$(PLATFORM) -D KERNEL=$(KERNEL_NAME)
HOST_LFLAGS=$(SW_LFLAGS) -lxilinxopencl

#Name of host executable
HOST_EXE=host

#Kernel
KERNEL_SRC=
KERNEL_HDRS=
KERNEL_FLAGS=
KERNEL_EXE=$(KERNEL)
KERNEL_NAME=$(KERNEL)

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

#TARGET for compilation [sw | sw_emu | hw_emu | hw]
TARGET=none
REPORT_FLAG=n
REPORT=
ifeq (${TARGET}, sw_emu)
$(info software emulation)
TARGET=sw_emu
else ifeq (${TARGET}, hw_emu)
$(info hardware emulation)
TARGET=hw_emu
REPORT=--report estimate
else ifeq (${TARGET}, hw)
$(info system build)
TARGET=hw
REPORT=--report system
else ifeq (${TARGET}, sw)
$(info software build)
TARGET=sw
else
$(info no TARGET specified, SW assumed)
TARGET=sw
endif


# Build dir is "out" or "prebuilt", based on PREBUILT variable.
BUILD_DIR_NAME = out
OUT_DIR_NAME = out
ifeq ($(PREBUILT), true)
BUILD_DIR_NAME = prebuilt
OUT_DIR_NAME = prebuilt_out
endif

#Assign DEST_DIR as <TARGET>/<TARGET_DEVICE>, or just <TARGET> for sw build (w/ no target device).
ifeq ($(TARGET), sw)
DEST_DIR=../$(OUT_DIR_NAME)/$(TARGET)
BUILD_DIR=../$(BUILD_DIR_NAME)/$(TARGET)
else
#Translate Target Device name with underscores
PERIOD:= :
UNDERSCORE:= _
DEST_SUBDIR=$(TARGET)/$(subst $(PERIOD),$(UNDERSCORE),$(TARGET_DEVICE))
DEST_DIR=../$(OUT_DIR_NAME)/$(DEST_SUBDIR)
BUILD_DIR=../$(BUILD_DIR_NAME)/$(DEST_SUBDIR)
endif

ifndef XILINX_XRT
ifneq ($(TARGET), sw)
$(error XILINX_XRT is not set. Please source the SDx settings64.{csh,sh} first)
endif
endif


ifdef DEST_DIR  # just to be safe
.PHONY: clean shrink
clean:
	sudo rm -rf $(DEST_DIR)
endif
# TODO: Add more-selective clean targets.

# Remove some of the large hw build collateral files.
shrink:
	rm -rf ../out/hw/*/to_aws ../out/hw/*/*.tar ../out/hw/*/_x

# Rule to build host application, only if not using pre-built.
ifneq ($(PREBUILT), true)

# TODO: Instead of this condition, define $(SW_SRC) and $HOST_SRC) as $(SRC) conditionally, etc.
ifeq ($(TARGET), sw)
$(DEST_DIR)/$(HOST_EXE): $(SW_SRC) $(SW_HDRS)
	mkdir -p $(DEST_DIR)
	$(CC) $(SW_SRC) $(SW_CFLAGS) $(SW_LFLAGS) -o $(DEST_DIR)/$(HOST_EXE)
# Host for debug.
$(DEST_DIR)/$(HOST_EXE)_debug: $(SW_SRC) $(SW_HDRS)
	mkdir -p $(DEST_DIR)
	$(CC) $(SW_SRC) $(SW_CFLAGS) -Og -ggdb -DDEBUG $(SW_LFLAGS) -o $(DEST_DIR)/$(HOST_EXE)_debug
else
$(DEST_DIR)/$(HOST_EXE): $(HOST_SRC) $(HOST_HDRS)
	mkdir -p $(DEST_DIR)
	$(CC) $(HOST_SRC) $(HOST_CFLAGS) $(HOST_LFLAGS) -o $(DEST_DIR)/$(HOST_EXE)
endif

endif



# Hardware build
ifneq ($(TARGET), sw)

# TODO: These are not relevant for TARGET=sw, and there is no distinction between hw and hw_emu, so they are defined the same
# regardless of TARGET. Need to make $(HW_DEST_DIR) and $(HW_BUILD_DIR) and use those for kernel build commands/files.
# Actually, I think it would be better to include TARGET in the build target, eg: sw_host, hw_host, etc. (As it is there is
# redundant building for different targets).

VIVADO_VERSION_MESSAGE=Note: Kernel construction assumes Vivado v2018.3

# Create tcl script for the kernel configuration
$(DEST_DIR)/rtl_kernel_wiz.tcl: $(FRAMEWORK_DIR)/fpga/scripts/produce_tcl_file.py $(HW_SHELL_CONFIG_JSON)
	mkdir -p $(DEST_DIR)
	python "$(FRAMEWORK_DIR)/fpga/scripts/produce_tcl_file.py" "$(HW_SHELL_CONFIG_JSON)" "$(DEST_DIR)/rtl_kernel_wiz.tcl"

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
$(USER_KERNEL_ADDED_FILE): $(SHELL_REP)
	@echo $(VIVADO_VERSION_MESSAGE)
	# Hacking the Xilinx template project to include the custom user kernel. (Failures in this process could leave the project in an inconsistent state.)
	@# Add user's kernel source code to project.
	vivado -mode batch -nojournal -nolog -notrace -source "$(FRAMEWORK_DIR)/fpga/scripts/tcl/add_kernel.tcl" "$(DEST_DIR)/$(KERNEL_NAME)_ex/${KERNEL_NAME}_ex.xpr"
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
#	$(XOCC) --platform $(PLATFORM) --target $(TARGET) --compile --include $(KERNEL_HDRS) --save-temps $(REPORT) --kernel $(KERNEL_NAME) $(KERNEL_SRC) $(KERNEL_LDCLFLAGS) $(KERNEL_FLAGS) $(KERNEL_ADDITIONAL_FLAGS) --output $(DEST_DIR)/$(KERNEL_EXE).xo
#	#cp ../fpga/mandelbrot_hw/sdx_imports/$(KERNEL_EXE).xo $(DEST_DIR)/$(KERNEL_EXE).xo

# Package the project as an .xo.
# (Use: "$(XO_FILE): $(SHELL_REP)" to build with the vadd example kernel, unmodified.)
$(XO_FILE): $(USER_KERNEL_ADDED_FILE) ../fpga/src/$(KERNEL_NAME)_kernel.sv $(PROJ_FPGA_EXTRA_SRCS)
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
	cd $(DEST_DIR); $(XOCC) -g --platform $(PLATFORM) --target $(TARGET) --link -O quick --include $(KERNEL_HDRS) --save-temps $(REPORT) --kernel $(KERNEL_NAME) ../../$(XO_FILE) $(KERNEL_LDCLFLAGS) $(KERNEL_FLAGS) $(KERNEL_ADDITIONAL_FLAGS) --output $(KERNEL_EXE).xclbin

# From: https://github.com/Xilinx/SDAccel-Tutorials/blob/master/docs/aws-getting-started/RTL/STEP1.md
# The AFI creation process that started in the background is not instantaneous. You must make sure that the process completes successfully before it is able to run on the F1 instance.
# Note the values of the AFI IDs by opening the <timestamp>_afi_id.txt file:
# cat *.afi_id.txt
# Use the describe-fpga-images API to check the status AFI generation process.
# aws ec2 describe-fpga-images --fpga-image-ids <AFI ID>
# When AFI creation completes successfully, the output should contain:
#  ...
#  "State": {
#     "Code": "available"
#  },
#  ...
# Wait until the AFI becomes available before proceeding to execute the application on the F1 instance.
# It's rediculous that there is no automation here. Or is there...
# TODO: Wait for AFI build to complete.
#       In create_sdaccel_afi.sh, use create-fpga-image --wait
ifneq ($(PREBUILT), true)
$(BUILD_DIR)/$(KERNEL_EXE).awsxclbin: $(DEST_DIR)/$(KERNEL_EXE).xclbin
	mkdir -p $(DEST_DIR)
	$(info Building AFI using bucket "$(S3_BUCKET)" with output folder "$(S3_DCP_KEY)" and log folder "$(S3_LOGS_KEY)")
	cd $(DEST_DIR); $(SDACCEL_DIR)/tools/create_sdaccel_afi.sh -xclbin=$(KERNEL_EXE).xclbin -o=$(KERNEL) -s3_bucket=$(S3_BUCKET) -s3_dcp_key=$(S3_DCP_KEY) -s3_logs_key=$(S3_LOGS_KEY)
endif

.PHONY: push
# Push the entire contents of the app directory for running on F1. (SDAccel tarball should already be in S3.)
# Previous transfer contents are deleted.
push: build
	aws s3 sync .. s3://$(S3_BUCKET)/$(S3_TRANSFER_KEY)/
endif

# Phony targets for intermediate results
.PHONY: host xo xclbin emulation build launch
host: $(DEST_DIR)/$(HOST_EXE)
host_debug: $(DEST_DIR)/$(HOST_EXE)_debug
#xo: $(DEST_DIR)/$(KERNEL_EXE).xo
xclbin: $(DEST_DIR)/$(KERNEL_EXE).xclbin

ifeq ($(TARGET), hw_emu)
HOST_XCLBIN=$(DEST_DIR)/$(KERNEL_EXE).xclbin
endif
ifeq ($(TARGET), hw)
HOST_XCLBIN=$(BUILD_DIR)/$(KERNEL_EXE).awsxclbin
# HW targets
.PHONY: awsxclbin afi
awsxclbin: $(HOST_XCLBIN)
afi: awsxclbin
endif

# TODO: Need sdx_project and sdx_workspace targets to build SDx workspace/project configured to work w/ the host application.

# TODO: This must have been from Alessandro, and emulation has never been launched from the makefile since.
emulation:  $(DEST_DIR)/$(HOST_EXE) $(BUILD_DIR)/$(HOST_EXE) $(BUILD_DIR)/$(KERNEL_EXE).xclbin
	export XCL_EMULATION_MODE=$(TARGET) && $(BUILD_DIR)/$(HOST_EXE) $(BUILD_DIR)/$(KERNEL_EXE).xclbin
	$(info Remember to export XCL_EMULATION_MODE=$(TARGET) and run emconfigutil for emulation purposes)



# For production use of port 80.
# Run is done in its own directory to avoid socket collision with development.
.PHONY: live dead

live: dead
	make TARGET=hw prep_live_internal
	@echo "Launching production server in the background"
	nohup ./launch -p 80 hw '../live/$(HOST_EXE) $(HOST_XCLBIN)'
	
dead:
	source ../live/killme > /dev/null 2>&1 || true

# A target used by target live (and not expected to be used directly by the user).
prep_live_internal:
	mkdir -p ../live
	cp $(DEST_DIR)/$(HOST_EXE) ../live
	cp $(HOST_XCLBIN) ../live


ifeq ($(VALGRIND), true)
VALGRIND_PREFIX=valgrind --leak-check=yes
else
VALGRIND_PREFIX=
endif

ifeq ($(TARGET), sw)
BUILD_TARGETS=$(BUILD_DIR)/$(HOST_EXE)
HOST_CMD=$(BUILD_DIR)/$(HOST_EXE)
endif
ifeq ($(TARGET), hw_emu)
BUILD_TARGETS=$(BUILD_DIR)/$(HOST_EXE) $(HOST_XCLBIN)
HOST_CMD= export XCL_EMULATION_MODE=$(TARGET) && $(XILINX_SDX)/bin/emconfigutil --od $(DEST_DIR) --nd 1  --platform $(PLATFORM) && $(VALGRIND_PREFIX) $(BUILD_DIR)/$(HOST_EXE) $(HOST_XCLBIN)
endif
ifeq ($(TARGET), hw)
BUILD_TARGETS=$(BUILD_DIR)/$(HOST_EXE) $(HOST_XCLBIN)
HOST_CMD=$(VALGRIND_PREFIX) $(BUILD_DIR)/$(HOST_EXE) $(HOST_XCLBIN)
endif

build:  $(BUILD_TARGETS)
launch: $(BUILD_TARGETS)
	@if [ -e killme ]; then echo "Error: There appears to already be an application running. Kill it with <Ctrl-C> or 'source killme', or, if not running, 'rm killme', and try again." && false; fi
	./launch -p $(PORT) $(TARGET) '$(HOST_CMD)'


ifeq ($(TARGET), hw)
.PHONY: prebuild
prebuild: $(BUILD_DIR)/$(HOST_EXE) $(HOST_XCLBIN)
	mkdir -p $(subst ../out, ../prebuilt, $(DEST_DIR))
	cp $(DEST_DIR)/$(HOST_EXE)             $(subst ../out, ../prebuilt, $(DEST_DIR))/$(HOST_EXE)
	cp $(DEST_DIR)/$(KERNEL_EXE).awsxclbin $(subst ../out, ../prebuilt, $(DEST_DIR))/$(KERNEL_EXE).awsxclbin
endif


.PHONY: debug_prints
debug_prints:
	$(info host path: $(DEST_DIR)/$(HOST_EXE))
