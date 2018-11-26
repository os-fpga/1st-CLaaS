###############################
#                             #
# Makefile for SDAccel 2017.1 #
#                             #
###############################

# Usage:
#   Targets:
#     host: the host application
#     xclbin: the FPGA image
#     build: the host application and FPGA image
#     emulation: ?
#     run_system: build and run
#     push: push application directory to S3 storage for transfer to F1 Instance
#     prebuild: populate contents of "prebuilt" directory with current build (do not set PREBUILT variable)
#   Variables:
#     TARGET=[sw_emu, hw, hw_emu] or unspecified for software-only (no OpenCL) build of host application
#     KERNEL: the name for the fpga model
#     PREBUILT=[true] or default to false behavior. True to use the prebuilt files in the repository, rather than building.
#     S3_BUCKET=bucket_name (defaullt="<users>-<kernel>-afi") provides a name for the S3 bucket to use for the AFI (.awsxclbin) build.
#     S3_LOGS_KEY=folder (default="afi_logs") the S3 bucket folder to use for logs for the AFI build.
#     S3_DCP_KEY=folder (default="afi_dcp_key") the S3 bucket folder to use for logs for the AFI build.
#   Eg:
#     make host TARGET=hw_emu KERNEL=mandelbrot

# BUILD_ID is used to tag the build for transfer from the build instance to the F1 instance.
ifndef S3_USER
S3_USER=default_user
endif
S3_BUCKET=fpga-webserver
S3_LOGS_KEY=${S3_USER}/$(KERNEL)/logs
S3_DCP_KEY=${S3_USER}/$(KERNEL)/AFIs
S3_TRANSFER_KEY=${S3_USER}/$(KERNEL)/xfer

XOCC=xocc
CC=g++


HOST_DIR=../host
FRAMEWORK_DIR=../../../framework/host

#Software (no FPGA) flags
SW_SRC=$(FRAMEWORK_DIR)/server_main.c $(HOST_DIR)/lodepng.c $(HOST_DIR)/mandelbrot.c
SW_HDRS=$(HOST_DIR)/mandelbrot.h
SW_CFLAGS=-g -Wall -O3 -std=c++11 -I$(HOST_DIR) -I$(FRAMEWORK_DIR)
SW_LFLAGS=-L${XILINX_SDX}/runtime/lib/x86_64

#Host code
HOST_SRC=$(SW_SRC) $(FRAMEWORK_DIR)/kernel.c
HOST_HDRS=$(SW_HDRS)
HOST_CFLAGS=$(SW_CFLAGS) -D FPGA_DEVICE -D OPENCL -I${XILINX_SDX}/runtime/include/1_2 -D C_KERNEL -D SDX_PLATFORM -D KERNEL=$(KERNEL_NAME)
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

ifndef XILINX_SDX
ifneq ($(TARGET), sw)
$(error XILINX_SDX is not set. Please source the SDx settings64.{csh,sh} first)
endif
endif


ifdef DEST_DIR  # just to be safe
.PHONY: clean
clean:
	rm -rf $(DEST_DIR)
endif
# TODO: Add more-selective clean targets.


# Rule to build host application, only if not using pre-built.
ifeq ($(PREBUILT), true)
else

# TODO: Instead of this condition, define $(SW_SRC) and $HOST_SRC) as $(SRC) conditionally, etc.
ifeq ($(TARGET), sw)
$(DEST_DIR)/$(HOST_EXE): $(SW_SRC) $(SW_HDRS)
	mkdir -p $(DEST_DIR)
	$(CC) $(SW_SRC) $(SW_CFLAGS) $(SW_LFLAGS) -o $(DEST_DIR)/$(HOST_EXE)
else
$(DEST_DIR)/$(HOST_EXE): $(HOST_SRC) $(HOST_HDRS)
	mkdir -p $(DEST_DIR)
	$(CC) $(HOST_SRC) $(HOST_CFLAGS) $(HOST_LFLAGS) -o $(DEST_DIR)/$(HOST_EXE)
endif

endif

$(DEST_DIR)/$(KERNEL_EXE).xo:
	mkdir -p $(DEST_DIR)
	#$(XOCC) --platform $(PLATFORM) --target $(TARGET) --compile --include $(KERNEL_HDRS) --save-temps $(REPORT) --kernel $(KERNEL_NAME) $(KERNEL_SRC) $(KERNEL_LDCLFLAGS) $(KERNEL_FLAGS) $(KERNEL_ADDITIONAL_FLAGS) --output $(DEST_DIR)/$(KERNEL_EXE).xo
	# TODO: How do we generate the .xo?
	cp ../fpga/mandelbrot_hw/sdx_imports/$(KERNEL_EXE).xo $(DEST_DIR)/$(KERNEL_EXE).xo

$(DEST_DIR)/$(KERNEL_EXE).xclbin: $(DEST_DIR)/$(KERNEL_EXE).xo
	cd $(DEST_DIR); $(XOCC) -g --platform $(PLATFORM) --target $(TARGET) --link --include $(KERNEL_HDRS) --save-temps $(REPORT) --kernel $(KERNEL_NAME) $(KERNEL_EXE).xo $(KERNEL_LDCLFLAGS) $(KERNEL_FLAGS) $(KERNEL_ADDITIONAL_FLAGS) --output $(KERNEL_EXE).xclbin

# Create AFI. Creation is asynchronous on S3 and uses non-descript timestamped names, so it's hard to know
# when they are ready, where to find them, and when you can delete (ugh).
$(DEST_DIR)/$(KERNEL_EXE).awsxclbin: $(BUILD_DIR)/$(KERNEL_EXE).xclbin
	mkdir -p $(DEST_DIR)
	$(info Building AFI using bucket "$(S3_BUCKET)" with output folder "$(S3_DCP_KEY)" and log folder "$(S3_LOGS_KEY)")
	cp $(BUILD_DIR)/$(KERNEL_EXE).xclbin $(DEST_DIR)
	cd $(DEST_DIR); $(SDACCEL_DIR)/tools/create_sdaccel_afi.sh -xclbin=$(KERNEL_EXE).xclbin -o=$(KERNEL) -s3_bucket=$(S3_BUCKET) -s3_dcp_key=$(S3_DCP_KEY) -s3_logs_key=$(S3_LOGS_KEY)

# Transfer (push) FPGA files from build instance to F1 instance through S3.
ifneq ($(TARGET), sw)
.PHONY: push
# Push the entire contents of the app directory for running on F1. (SDAccel tarball should already in S3.)
# Previous transfer contents are deleted.
push: build
	aws s3 sync .. s3://$(S3_BUCKET)/$(S3_TRANSFER_KEY)/
endif

# Phony targets for intermediate results
.PHONY: host xo xclbin awsxclbin afi
host: $(DEST_DIR)/$(HOST_EXE)
xo: $(DEST_DIR)/$(KERNEL_EXE).xo
xclbin: $(DEST_DIR)/$(KERNEL_EXE).xclbin
awsxclbin: $(DEST_DIR)/$(KERNEL_EXE).awsxclbin
afi: awsxclbin

.PHONY: emulation
emulation:  $(DEST_DIR)/$(HOST_EXE) $(BUILD_DIR)/$(HOST_EXE) $(BUILD_DIR)/$(KERNEL_EXE).xclbin
	export XCL_EMULATION_MODE=$(TARGET) && $(BUILD_DIR)/$(HOST_EXE) $(BUILD_DIR)/$(KERNEL_EXE).xclbin
	$(info Remember to export XCL_EMULATION_MODE=$(TARGET) and run emcondigutil for emulation purposes)

.PHONY: build
.PHONY: launch
ifeq ($(TARGET), sw)
build:  $(BUILD_DIR)/$(HOST_EXE)
launch: build
	./launch $(TARGET) $(BUILD_DIR)/$(HOST_EXE)
else
build:  $(BUILD_DIR)/$(HOST_EXE) $(DEST_DIR)/$(KERNEL_EXE).awsxclbin
launch: build
	# TODO: Wait for AFI build to complete.
	#       In create_sdaccel_afi.sh, use create-fpga-image --wait
	./launch $(TARGET) $(BUILD_DIR)/$(HOST_EXE) $(DEST_DIR)/$(KERNEL_EXE).awsxclbin
endif


.PHONY: prebuild
prebuild: build
	mkdir -p $(subst ../out, ../prebuilt, $(DEST_DIR))
	cp $(DEST_DIR)/$(HOST_EXE)          $(subst ../out, ../prebuilt, $(DEST_DIR))/$(HOST_EXE)
	cp $(DEST_DIR)/$(KERNEL_EXE).xclbin $(subst ../out, ../prebuilt, $(DEST_DIR))/$(KERNEL_EXE).xclbin

