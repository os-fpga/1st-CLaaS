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
#   Variables:
#     TARGET=[sw_emu, hw, hw_emu] or unspecified for software-only (no OpenCL) build of host application
#     KERNEL: the name for the fpga model
#     PREBUILT=[true] or default to false. True to use the prebuilt files in the repository, rather than building.
#     S3_BUCKET=bucket_name (defaullt="afi") provides a name for the S3 bucket to use for the AFI (.awsxclbin) build.
#     S3_LOGS_KEY=folder (default="afi_logs") the S3 bucket folder to use for logs for the AFI build.
#     S3_DCP_KEY=folder (default="afi_dcp_key") the S3 bucket folder to use for logs for the AFI build.
#   Eg:
#     make host TARGET=hw_emu KERNEL=mandelbrot

S3_BUCKET=afi
S3_LOGS_KEY=afi_logs
S3_DCP_KEY=afi_dcp_key

HOST_DIR=../host

XOCC=xocc
CC=g++

#Software (no FPGA) flags
SW_SRC=$(HOST_DIR)/server_main.c $(HOST_DIR)/lodepng.c $(HOST_DIR)/mandelbrot.c
SW_HDRS=$(HOST_DIR)/mandelbrot.h
SW_CFLAGS=-g -Wall -O3 -std=c++11
SW_LFLAGS=-L${XILINX_SDX}/runtime/lib/x86_64

#Host code
HOST_SRC=$(SW_SRC) $(HOST_DIR)/kernel.c
HOST_HDRS=$(SW_HDRS)
HOST_CFLAGS=$(SW_CFLAGS) -D FPGA_DEVICE -D OPENCL -I${XILINX_SDX}/runtime/include/1_2 -D C_KERNEL -D SDX_PLATFORM -D KERNEL=${KERNEL_NAME}
HOST_LFLAGS=$(SW_LFLAGS) -lxilinxopencl

#Name of host executable
HOST_EXE=host

#Kernel
KERNEL_SRC=
KERNEL_HDRS=
KERNEL_FLAGS=
KERNEL_EXE=$(KERNEL)
KERNEL_NAME=$(KERNEL)

BUILD_DIR_NAME = out
ifeq ($(PREBUILT), true)
BUILD_DIR_NAME = prebuilt
endif

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

#Assign DEST_DIR as <TARGET>/<TARGET_DEVICE>, or just <TARGET> for sw build (w/ no target device).
#Translate Target Device name with underscores
PERIOD:= :
UNDERSCORE:= _
DEST_DIR=../out/$(TARGET)/$(subst $(PERIOD),$(UNDERSCORE),$(TARGET_DEVICE))
BUILD_DIR=../$(BUILD_DIR_NAME)/$(TARGET)/$(subst $(PERIOD),$(UNDERSCORE),$(TARGET_DEVICE))
ifeq ($(TARGET), sw)
DEST_DIR=../out/$(TARGET)
BUILD_DIR=../$(BUILD_DIR_NAME)/$(TARGET)
endif

ifndef XILINX_SDX
ifneq ($(TARGET), sw)
$(error XILINX_SDX is not set. Please source the SDx settings64.{csh,sh} first)
endif
endif

.PHONY: clean clean_sw clean_sw_emu clean_hw_emu clean_hw cleanall
clean:
	rm -rf .Xil emconfig.json 

clean_sw: clean
	rm -rf sw
clean_sw_emu: clean
	rm -rf sw_emu
clean_hw_emu: clean
	rm -rf hw_emu
clean_hw: clean
	rm -rf hw

cleanall: clean_sw clean_sw_emu clean_hw_emu clean_hw
	rm -rf _xocc_* xcl_design_wrapper_*


ifeq ($(TARGET), sw)
$(DEST_DIR)/$(HOST_EXE):  $(SW_SRC) $(SW_HDRS)
	mkdir -p $(DEST_DIR)
	$(CC) $(SW_SRC) $(SW_HDRS) $(SW_CFLAGS) $(SW_LFLAGS) -o $(DEST_DIR)/$(HOST_EXE)
else
$(DEST_DIR)/$(HOST_EXE):  $(HOST_SRC) $(HOST_HDRS)
	mkdir -p $(DEST_DIR)
	$(CC) $(HOST_SRC) $(HOST_HDRS) $(HOST_CFLAGS) $(HOST_LFLAGS) -o $(DEST_DIR)/$(HOST_EXE)
endif

$(DEST_DIR)/$(KERNEL_EXE).xo:
	mkdir -p $(DEST_DIR)
	$(XOCC) --platform $(PLATFORM) --target $(TARGET) --compile --include $(KERNEL_HDRS) --save-temps $(REPORT) --kernel $(KERNEL_NAME) $(KERNEL_SRC) $(KERNEL_LDCLFLAGS) $(KERNEL_FLAGS) $(KERNEL_ADDITIONAL_FLAGS) --output $(DEST_DIR)/$(KERNEL_EXE).xo

$(DEST_DIR)/$(KERNEL_EXE).xclbin:
	cp $(KERNEL_EXE).xo $(DEST_DIR)/$(KERNEL_EXE).xo
	$(XOCC) -g --platform $(PLATFORM) --target $(TARGET) --link --include $(KERNEL_HDRS) --save-temps $(REPORT) --kernel $(KERNEL_NAME) $(DEST_DIR)/$(KERNEL_EXE).xo $(KERNEL_LDCLFLAGS) $(KERNEL_FLAGS) $(KERNEL_ADDITIONAL_FLAGS) --output $(DEST_DIR)/$(KERNEL_EXE).xclbin

$(DEST_DIR)/$(KERNEL_EXE).awsxclbin: $(DEST_DIR)/$(KERNEL_EXE).xclbin
	$SDACCEL_DIR/tools/create_sdaccel_afi.sh -xclbin=$(DEST_DIR)/$(KERNEL_EXE).xclbin -o=$(KERNEL) -s3_bucket=$(S3_BUCKET) -s3_dcp_key=$(S3_DCP_KEY) -s3_logs_key=$(S3_LOGS_KEY)
  # Not sure why this script uses S3. Let's copy to the output direcgtory.
	# First wait for completion.
	# ...
	# TODO: What's the path to the .awsxclbin. Need to put it in the right place for make.
	# aws s3 cp s3://$(S3_BUCKET)/$(S3_DCP_KEY) $(DEST_DIR)/$(S3_DCP_KEY)
	# aws s3 cp s3://$(S3_BUCKET)/$(S3_LOGS_KEY) $(DEST_DIR)/$(S3_LOGS_KEY)
  # ...

.PHONY: pull
	# Pull results from S3 bucket.
	# aws s3 mv s3://$(S3_BUCKET)/$(S3_DCP_KEY) $(DEST_DIR)/$(S3_DCP_KEY)
	# aws s3 mv s3://$(S3_BUCKET)/$(S3_LOGS_KEY) $(DEST_DIR)/$(S3_LOGS_KEY)

.PHONY: emulation
emulation:  $(DEST_DIR)/host $(BUILD_DIR)/$(HOST_EXE) $(BUILD_DIR)/$(KERNEL_EXE).xclbin
	export XCL_EMULATION_MODE=$(TARGET) && $(BUILD_DIR)/$(HOST_EXE) $(BUILD_DIR)/$(KERNEL_EXE).xclbin
	$(info Remember to export XCL_EMULATION_MODE=$(TARGET) and run emcondigutil for emulation purposes)

.PHONY: build
ifeq ($(TARGET), sw)
build:  $(BUILD_DIR)/$(HOST_EXE)
else
build:  $(BUILD_DIR)/$(HOST_EXE) $(BUILD_DIR)/$(KERNEL_EXE).awsxclbin
endif

.PHONY: launch
launch: build
	# TODO: Wait for AFI build to complete.
	#       In create_sdaccel_afi.sh, use create-fpga-image --wait
	./launch $(TARGET)

