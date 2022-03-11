# Extends framework Makefile with mandelbrot-specific stuff.
# See framework/build/Makefile for usage info.

##########
# TODO: lodepng.[c/h] is used in framework. Use should be moved to mandelbrot, so none of these are required.
EXTRA_C_SRC=$(FRAMEWORK_HOST_DIR)/default_main.c ../../mandelbrot/host/lodepng.c
EXTRA_C_HDRS=../../mandelbrot/host/lodepng.h
PROJ_SW_CFLAGS=-I../../mandelbrot/host
##########

############################## Setting up Project Variables ##############################
# Points to top directory of Git repository
MK_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
COMMON_REPO ?= $(shell bash -c 'export MK_PATH=$(MK_PATH); echo $${MK_PATH%rtl_kernels/rtl_vadd/*}')
PWD = $(shell readlink -f .)
ABS_COMMON_REPO = $(shell readlink -f $(COMMON_REPO))

TARGET := hw
HOST_ARCH := x86
SYSROOT := 

include ./utils.mk

XSA := $(call device2xsa, $(DEVICE))
TEMP_DIR := ./_x.$(TARGET).$(XSA)
BUILD_DIR := ./build_dir.$(TARGET).$(XSA)

# SoC variables
RUN_APP_SCRIPT = ./run_app.sh
PACKAGE_OUT = ./package.$(TARGET)

LAUNCH_EMULATOR = $(PACKAGE_OUT)/launch_$(TARGET).sh
RESULT_STRING = TEST PASSED

VPP := v++ 
SDCARD := sd_card


# include $(ABS_COMMON_REPO)/common/includes/opencl/opencl.mk
include config.mk

CXXFLAGS += $(opencl_CXXFLAGS) -Wall -O0 -g -std=c++11
LDFLAGS += $(opencl_LDFLAGS)

############################## Setting up Host Variables ##############################
#Include Required Host Source Files
CXXFLAGS += -I../../host/xcl2
HOST_SRCS += ../../host/xcl2.cpp ../../host/vadd.cpp 
# Host compiler global settings
CXXFLAGS += -fmessage-length=0
LDFLAGS += -lrt -lstdc++ 

ifneq ($(HOST_ARCH), x86)
	LDFLAGS += --sysroot=$(SYSROOT)
endif

############################## Setting up Kernel Variables ##############################
# Kernel compiler global settings
CLFLAGS += -t $(TARGET) --platform $(DEVICE) --save-temps 
ifneq ($(TARGET), hw)
	CLFLAGS += -g
endif



EXECUTABLE = ./rtl_vadd
CMD_ARGS = $(BUILD_DIR)/vadd.xclbin
EMCONFIG_DIR = $(TEMP_DIR)
EMU_DIR = $(SDCARD)/data/emulation

############################## Declaring Binary Containers ##############################
BINARY_CONTAINERS += $(BUILD_DIR)/vadd.xclbin
BINARY_CONTAINER_vadd_OBJS += $(TEMP_DIR)/vadd.xo

############################## Setting Targets ##############################
CP = cp -rf

.PHONY: all clean cleanall docs emconfig
all: check-devices $(EXECUTABLE) $(BINARY_CONTAINERS) emconfig sd_card

.PHONY: host
host: $(EXECUTABLE)

.PHONY: build
build: check-vitis $(BINARY_CONTAINERS)

.PHONY: xclbin
xclbin: build

# Building kernel
$(BUILD_DIR)/vadd.xclbin: $(BINARY_CONTAINER_vadd_OBJS)
	mkdir -p $(BUILD_DIR)
ifeq ($(HOST_ARCH), x86)
	$(VPP) -l $(LDCLFLAGS) $(CLFLAGS) --temp_dir $(BUILD_DIR)  -o'$(BUILD_DIR)/vadd.link.xclbin' $(+)
	$(VPP) -p $(BUILD_DIR)/vadd.link.xclbin -t $(TARGET) --platform $(DEVICE) --package.out_dir $(PACKAGE_OUT) -o $(BUILD_DIR)/vadd.xclbin
else
	$(VPP) -l $(LDCLFLAGS) $(CLFLAGS) --temp_dir $(BUILD_DIR) -o'$(BUILD_DIR)/vadd.xclbin' $(+)
endif

############################## Setting Rules for Host (Building Host Executable) ##############################
$(EXECUTABLE): $(HOST_SRCS) | check-xrt
		$(CXX) -o $@ $^ $(CXXFLAGS) $(LDFLAGS)

emconfig:$(EMCONFIG_DIR)/emconfig.json
$(EMCONFIG_DIR)/emconfig.json:
	emconfigutil --platform $(DEVICE) --od $(EMCONFIG_DIR)

############################## Setting Essential Checks and Running Rules ##############################
run: all
ifeq ($(TARGET),$(filter $(TARGET),sw_emu hw_emu))
ifeq ($(HOST_ARCH), x86)
	$(CP) $(EMCONFIG_DIR)/emconfig.json .
	XCL_EMULATION_MODE=$(TARGET) $(EXECUTABLE) $(BUILD_DIR)/vadd.xclbin
else
	$(ABS_COMMON_REPO)/common/utility/run_emulation.pl "${LAUNCH_EMULATOR} | tee run_app.log" "${RUN_APP_SCRIPT} $(TARGET)" "${RESULT_STRING}" "7"
endif
else
ifeq ($(HOST_ARCH), x86)
	$(EXECUTABLE) $(BUILD_DIR)/vadd.xclbin
endif
endif
ifneq ($(TARGET),$(findstring $(TARGET), hw hw_emu))
$(warning WARNING:Application supports only hw hw_emu TARGET. Please use the target for running the application)
endif


.PHONY: test
test: $(EXECUTABLE)
ifeq ($(TARGET),$(filter $(TARGET),sw_emu hw_emu))
ifeq ($(HOST_ARCH), x86)
	XCL_EMULATION_MODE=$(TARGET) $(EXECUTABLE) $(BUILD_DIR)/vadd.xclbin
else
	$(ABS_COMMON_REPO)/common/utility/run_emulation.pl "${LAUNCH_EMULATOR} | tee embedded_run.log" "${RUN_APP_SCRIPT} $(TARGET)" "${RESULT_STRING}" "7"
endif
else
ifeq ($(HOST_ARCH), x86)
	$(EXECUTABLE) $(BUILD_DIR)/vadd.xclbin
else
	$(ECHO) "Please copy the content of sd_card folder and data to an SD Card and run on the board"
endif
endif
ifneq ($(TARGET),$(findstring $(TARGET), hw hw_emu))
$(warning WARNING:Application supports only hw hw_emu TARGET. Please use the target for running the application)
endif

############################## Preparing sdcard ##############################
sd_card: $(BINARY_CONTAINERS) $(EXECUTABLE) gen_run_app
ifneq ($(HOST_ARCH), x86)
	$(VPP) -p $(BUILD_DIR)/vadd.xclbin -t $(TARGET) --platform $(DEVICE) --package.out_dir $(PACKAGE_OUT) --package.rootfs $(EDGE_COMMON_SW)/rootfs.ext4 --package.sd_file $(SD_IMAGE_FILE) --package.sd_file xrt.ini --package.sd_file $(RUN_APP_SCRIPT) --package.sd_file $(EXECUTABLE) -o vadd.xclbin
endif

############################## Cleaning Rules ##############################
# Cleaning stuff
clean:
	-$(RMDIR) $(EXECUTABLE) $(XCLBIN)/{*sw_emu*,*hw_emu*} 
	-$(RMDIR) profile_* TempConfig system_estimate.xtxt *.rpt *.csv 
	-$(RMDIR) ../src/*.ll *v++* .Xil emconfig.json dltmp* xmltmp* *.log *.jou *.wcfg *.wdb
	sudo rm -rf ../out

cleanall: clean
	-$(RMDIR) build_dir* sd_card*
	-$(RMDIR) package.*
	-$(RMDIR) _x* *xclbin.run_summary qemu-memory-_* emulation _vimage pl* start_simulation.sh *.xclbin
	-$(RMDIR) ./tmp_kernel_pack* ./packaged_kernel* 


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

# include ../../../framework/build/Makefile
define with_secret
	@# Echo command without secrets (requires proper quoting)
	@echo '$(subst $(SPACE)*****$(SPACE),*****,$(patsubst {{{%}}},*****,$(subst $(SINGLE_QUOTE),'"$(SINGLE_QUOTE)"',$1)))'
	@$(subst }}}$(SPACE),,$(subst $(SPACE){{{,,$1))
endef

.PHONY: nothing
nothing:
	@echo "No target specified. Nothing built."

.PHONY: clean shrink
# clean:

# TODO: Add more-selective clean targets.

# Remove some of the large hw build collateral files.
shrink:
	rm -rf ../out/hw/*/to_aws ../out/hw/*/*.tar ../out/hw/*/_x



# User configuration.
define config_param
	@echo -n "$1 [$($1)]: " && (read TMP; if [[ -n "$$TMP" ]]; then echo "$1=$$TMP" >> $(CONFIG_FILE).tmp; else echo '$1=$($1)' >> $(CONFIG_FILE).tmp; fi)
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
	  if [[ ! $$REGION =~ (us-east-1|us-west-2|eu-west-1|us-gov-west-1) ]]; \
	  then echo "Warning: Region $$REGION is not known to support F1. Valid regions w/ F1 include: 'us-east-1' (N. Virginia), 'us-west-2' (Oregon), 'eu-west-1' (Ireland), or 'us-gov-west-1' (GovCloud US). (Please update Makefile and create a pull request if you know differently.)"; \
	  fi
	@echo
	@echo 'User configuration needs an associated AWS S3 bucket (storage), which requires a globally-unique name (across all AWS users).'
	@echo 'Bucket name will be 1st-claas.$$(S3_USER).$$(S3_BUCKET_TAG)'
	$(call config_param,S3_USER)
	$(call config_param,S3_BUCKET_TAG)
	@# For convenience, also store the full bucket name.
	@source $(CONFIG_FILE).tmp && echo "S3_BUCKET=1st-claas.$${S3_USER}.$${S3_BUCKET_TAG}" >> $(CONFIG_FILE).tmp
	@echo 'EC2 instances can be initialized with an administrative password. This password may be used by optional administrative features of 1st-CLaaS web servers. Choose a default or leave blank to require explicit password on launch when needed.'
	@echo "WARNING: This default PASSWORD is accessible to $(USER) and root users."
	$(call config_param,PASSWORD)
	@chmod 600 $(CONFIG_FILE).tmp
	@mv $(CONFIG_FILE).tmp $(CONFIG_FILE)
	@echo 'Configuration complete and stored in "$(CONFIG_FILE)" accessible only to you ("$(USER)"). Contents:'
	@cat $(CONFIG_FILE)
	@source $(CONFIG_FILE) \
	  && echo "Setting up S3 bucket: s3://$$S3_BUCKET" \
	  && aws s3api create-bucket --bucket "$$S3_BUCKET" --acl private > /dev/null \
	  && aws s3api wait bucket-exists --bucket "$$S3_BUCKET"


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
	cd $(DEST_DIR); $(XOCC) -g --platform $(AWS_PLATFORM) --target $(BUILD_TARGET) --link -O quick --save-temps $(REPORT) --kernel $(KERNEL_NAME) ../../$(XO_FILE) $(KERNEL_LDCLFLAGS) $(KERNEL_FLAGS) $(KERNEL_ADDITIONAL_FLAGS) --output $(KERNEL_EXE).xclbin

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
	cd $(DEST_DIR) && $(SDACCEL_DIR)/tools/create_sdaccel_afi.sh -xclbin=$(KERNEL_EXE).xclbin -o=$(KERNEL_NAME) -s3_bucket=$(S3_BUCKET) -s3_dcp_key=$(S3_DCP_KEY) -s3_logs_key=$(S3_LOGS_KEY) -aws_profile_name=$(AWS_PROFILE) \
	  && grep '"afi-' *_afi_id.txt | sed 's/^.*"\(afi-[0-9a-zA-Z]*\)".*$$/\1/' > $(KERNEL_NAME)_afi_id.txt \
	  && ls *_afi_id.txt | sed 's/^\(.*\)_afi_id.txt$$/\1/' > $(KERNEL_NAME)_timestamp.txt \
	  && wait_for_afi.py --afi "$$(cat $(KERNEL_NAME)_afi_id.txt)"
	@# Delete S3 files to avoid charges.
	aws s3 rm --profile $(AWS_PROFILE) --recursive 's3://$(S3_BUCKET)/$(S3_DCP_KEY)/$$(cat $(KERNEL_NAME)_timestamp.txt)*'
	aws s3 rm --profile $(AWS_PROFILE) --recursive 's3://$(S3_BUCKET)/$(S3_LOGS_KEY)/$$(cat $(KERNEL_NAME)_timestamp.txt)*'
endif

.PHONY: push
# Push the entire contents of the app directory for running on F1. (TODO: Be more selective.)
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

FIRST_CLAAS_REMOTE_REPO_DIR ?=/home/centos/src/project_data/repo

# Create a new Static Accelerated Instance. See Makefile header comments for usage info.
# WARNING: This target launches a new instance. Be sure it is not left running!
# Default INSTANCE_NAME, INSTANCE_STORAGE, INSTANCE_TYPE, INSTANCE_CONFIG_SCRIPT based on target. (Doesn't work if multiple targets are given.)
# Defaults, in case instance target is unrecognized
#INSTANCE_NAME=1st-CLaaS
#INSTANCE_STORAGE=0
INSTANCE_TYPE=UNDEFINED
INSTANCE_CONFIG_SCRIPT=UNDEFINED
ifneq ($(findstring development_instance,$(MAKECMDGOALS)),)
	INSTANCE_NAME=manycore
	INSTANCE_STORAGE=15
	INSTANCE_TYPE=c4.2xlarge
	INSTANCE_CONFIG_SCRIPT=$(FIRST_CLAAS_REMOTE_REPO_DIR)/framework/terraform/config_instance_dev.sh
endif
ifneq ($(findstring f1_instance,$(MAKECMDGOALS)),)
	INSTANCE_NAME=1st-CLaaS_run
	INSTANCE_STORAGE=15
	INSTANCE_TYPE=f1.2xlarge
	INSTANCE_CONFIG_SCRIPT=$(FIRST_CLAAS_REMOTE_REPO_DIR)/framework/terraform/config_instance_dev.sh
endif
ifneq ($(findstring static_accelerated_instance,$(MAKECMDGOALS)),)
	INSTANCE_NAME=1st-CLaaS_$(KERNEL_NAME)_accelerator
	INSTANCE_STORAGE=5
	INSTANCE_TYPE=f1.2xlarge
	INSTANCE_CONFIG_SCRIPT=$(FIRST_CLAAS_REMOTE_REPO_DIR)/framework/terraform/config_static_f1_instance.sh
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
TF_ARGS4=-var 'instance_type=$(INSTANCE_TYPE)' -var "aws_access_key_id=$$(aws configure get aws_access_key_id --profile $(AWS_PROFILE))"
TF_ARGS5=-var "aws_secret_access_key=$$(aws configure get aws_secret_access_key --profile $(AWS_PROFILE))" -var 'aws_profile=$(AWS_PROFILE)'
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
	@if ! git status | grep 'working directory clean' > /dev/null; then echo && echo -e '\e[91m\e[1mInstance construction can have unexpected behavior when working directory is not clean.\e[0m' && echo && sleep 2; fi
	@echo 'Instance will be initialized based on latest "$(GIT_BRANCH)" branch.' && echo
	$(call terraform,apply -var 'kernel=$(KERNEL_NAME)' -var 'config_instance_script=$(INSTANCE_CONFIG_SCRIPT)' -var "out_dir=$(TF_OUT_DIR)" $(TF_ALL_ARGS))
	@echo 'This instance and its associated resources can be destroyed with:'
	@echo '   > make destroy SETUP=$(SETUP)'
	@# Set password. (This will find the correct instance via $INSTANCE_NAME_FILTER.)
	@# Do so without echoing command to avoid password in output (though, most-likely, it was typed in the first place).
	@if [[ -n '$(LINUX_PASSWORD)' ]]; then echo "Setting Linux password (final step, in case this fails)." && make ssh SSH_CMD='echo "centos:$(LINUX_PASSWORD)" | sudo chpasswd'; fi
endef

static_accelerated_instance:
	$(make_instance)
development_instance:
	$(make_instance)
f1_instance:
	$(make_instance)

# Connect to the single running EC2 instance.
define connect
	IPs=$$(aws ec2 describe-instances --profile $(AWS_PROFILE) --query "Reservations[*].Instances[*].PublicIpAddress" $(INSTANCE_NAME_FILTER) --output=text) \
		&& if [[ $$IPs =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\s*$$ ]]; \
			then \
				INSTANCE_NAME=$$(aws ec2 describe-instances --profile $(AWS_PROFILE) --filters "Name=ip-address,Values=$$IPs" --query 'Reservations[].Instances[].Tags[?Key==`Name`].Value' --output=text) && \
				PRIVATE_KEY=$$(realpath ~/".ssh/$$INSTANCE_NAME/private_key.pem") && \
				echo "$1 $$INSTANCE_NAME ($$IPs)" && \
				mkdir -p ../out && \
				$2 \
			else \
				echo "There is not exactly one instance running. Use INSTANCE_NAME=<instance-name> to select from the following running instances:" && \
				aws ec2 describe-instances --profile $(AWS_PROFILE) --filters 'Name=instance-state-name,Values=running' --query 'Reservations[].Instances[].Tags[?Key==`Name`].Value' --output=text | sed 's/^\(.*\)$$/   o \1/'; \
			fi
endef

.PHONY: desktop ssh
desktop:
	@# Call remmina using template.remmina configuration with "TBD" values substituted. (perl is used to substitute arbitrary literal text.)
	$(call connect,Connecting via RDP using Remmina to,TMP="$$PRIVATE_KEY" perl -p -e 's/^ssh_privatekey=TBD/ssh_privatekey=$$ENV{TMP}/' < "$(FRAMEWORK_DIR)/build/template.remmina" > "$(FRAMEWORK_DIR)/out/tmp.remmina" && sed -i "s/^server=TBD/server=$$IPs/" "$(FRAMEWORK_DIR)/out/tmp.remmina" && remmina -c "$(FRAMEWORK_DIR)/out/tmp.remmina" &)
ssh:
	$(call connect,Connecting via SSH to,ssh -oStrictHostKeyChecking=no -X -i "$$PRIVATE_KEY" centos@$$IPs $(SSH_CMD);)
ip:
	$(call connect,Running instance:,true)

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
