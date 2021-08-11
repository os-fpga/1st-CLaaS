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


# Chrome executable if there is one. Empty if not found and unspecified.
CHROME=$(shell which google-chrome)


#
# Characterize platform (define $SUPPORTED_TARGETS)
#
AWS_FPGA_REPO_DIR=/home/vj07/Desktop/sdx/aws-fpga

VERILATOR=$(shell ls "$(REPO)/local/verilator" 2> /dev/null)
ifeq ($(VERILATOR),)
# No local verilator.
VERILATOR=$(shell which verilator 2> /dev/null)
# Presumable verilator is /usr/local/bin/verilator or /usr/bin/verilator (but there is no check).
VERILATOR_INCLUDE=/usr/share/verilator/include
else
VERILATOR=$(ABS_REPO)/local/verilator/bin/verilator
VERILATOR_ROOT=$(ABS_REPO)/local/verilator
VERILATOR_INCLUDE=$(ABS_REPO)/local/verilator/include
endif

ifneq ($(AWS_FPGA_REPO_DIR),)
SUPPORTED_TARGETS :=hw | hw_emu |$(SPACE)
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
# We will change this one.
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
ifdef SSL_CRT_FILE
ifdef SSL_KEY_FILE
WEBSERVER_ARGS :=$(WEBSERVER_ARGS) --ssl_crt_file='$(SSL_CRT_FILE)' --ssl_key_file='$(SSL_KEY_FILE)'
endif
endif

WEBSERVER_PY ?= $(shell if [[ -e "../webserver/$(KERNEL_NAME)_server.py" ]]; then echo "../webserver/$(KERNEL_NAME)_server.py"; else echo "$(FRAMEWORK_DIR)/webserver/default_server.py"; fi)
LAUNCH_W ?=python3 $(WEBSERVER_PY) --port=<<PORT>> --socket=<<SOCKET>> $(WEBSERVER_ARGS)


XOCC=xocc
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
SW_CFLAGS ?= -g -Wall -O3 -std=c++11 -I$(HOST_DIR) -I$(FRAMEWORK_HOST_DIR) -I$(FRAMEWORK_DIR)/host/json/include $(PROJ_SW_CFLAGS)
SW_LFLAGS ?= -L$(XILINX_XRT)/lib $(PROJ_SW_LFLAGS)

#Host code
HOST_SRC=$(SW_SRC) $(FRAMEWORK_HOST_DIR)/hw_kernel.c
HOST_HDRS=$(SW_HDRS) $(FRAMEWORK_HOST_DIR)/kernel.h
HOST_HDRS=$(SW_HDRS) $(FRAMEWORK_HOST_DIR)/hw_kernel.h
# TODO: It seems SDX_PLATFORM should be set to a value. For hw_emu, I see one device: "xilinx:pcie-hw-em:7v3:1.0"
#       What is the emconfigutil command (for configuring the platform for hw_emu?)
HOST_CFLAGS=$(SW_CFLAGS) -D KERNEL_AVAIL -D FPGA_DEVICE -D OPENCL -I$(XILINX_XRT)/runtime/include/1_2 -D C_KERNEL -D SDX_PLATFORM=$(AWS_PLATFORM) -D KERNEL=$(KERNEL_NAME)
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
# Flags for xocc (include -I <file> args).
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
# TARGET_DEVICE=xilinx_aws-vu9p-f1-04261818_dynamic_5_0

REPORT=
ifeq ($(BUILD_TARGET),hw)
REPORT= -R2 --report_level system
else
ifeq ($(BUILD_TARGET),hw_emu)
REPORT= -R2 --report_level estimate
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
AWS_PLATFORM=/tools/Xilinx/SDx/2018.3/platforms/xilinx_aws-vu9p-f1-04261818_dynamic_5_0/xilinx_aws-vu9p-f1-04261818_dynamic_5_0.xpfm

#Translate Target Device name with underscores
PERIOD:= :
UNDERSCORE:= _
DEST_SUBDIR=$(BUILD_TARGET)/$(subst $(PERIOD),$(UNDERSCORE),$(TARGET_DEVICE))
DEST_DIR=../$(OUT_DIR_NAME)/$(DEST_SUBDIR)
BUILD_DIR=../$(BUILD_DIR_NAME)/$(DEST_SUBDIR)
endif

ifndef XILINX_XRT
ifeq ($(USE_XILINX),true)
# $(error XILINX_XRT is not set. Please source the SDx settings64.{csh,sh} first)
XILINX_XRT=/opt/xilinx/xrt
endif
endif
ifndef XILINX_SDX
XILINX_SDX=/tools/Xilinx/SDx/2018.3
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
HOST_CMD=export XCL_EMULATION_MODE=$(BUILD_TARGET) && $(XILINX_SDX)/bin/emconfigutil --od $(DEST_DIR) --nd 1  --platform $(AWS_PLATFORM) && $(VALGRIND_PREFIX) $(HOST_EXE_PATH) $(HOST_ARGS) $(HOST_XCLBIN)
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

# Rule to build host application, only if not using pre-built.
ifneq ($(USE_PREBUILT), true)

# TODO: Instead of this condition, define $(SW_SRC) and $(HOST_SRC) as $(SRC) conditionally, etc.
ifneq ($(USE_XILINX),true)
ifeq ($(BUILD_TARGET),sw)
#sw target
$(DEST_DIR)/$(HOST_EXE): $(SW_SRC) $(SW_HDRS)
	mkdir -p $(DEST_DIR)
	cp sdaccel.ini ../out/$(BUILD_TARGET)/*/
	$(CC) $(SW_SRC) $(SW_CFLAGS) $(SW_LFLAGS) -o $(DEST_DIR)/$(HOST_EXE)
# Host for debug.
$(DEST_DIR)/$(HOST_EXE)_debug: $(SW_SRC) $(SW_HDRS)
	mkdir -p $(DEST_DIR)
	cp sdaccel.ini ../out/$(BUILD_TARGET)/*/
	$(CC) $(SW_SRC) $(SW_CFLAGS) -Og -ggdb -DDEBUG $(SW_LFLAGS) -o $(DEST_DIR)/$(HOST_EXE)_debug
else
#sim target
$(DEST_DIR)/verilator/V$(KERNEL_NAME)_kernel.cpp: $(SV_SRC) $(SV_FROM_TLV) $(VH_SRC) $(FRAMEWORK_V_SRC)
	mkdir -p $(DEST_DIR)
	cp sdaccel.ini ../out/$(BUILD_TARGET)/*/
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
	cp sdaccel.ini ../out/$(BUILD_TARGET)/*/
	cp sdaccel.ini ../out/$(BUILD_TARGET)/*
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

BUILD_DIR_vadd = $(BUILD_DIR)/vadd

$(DEST_DIR)/$(KERNEL_EXE).xclbin: $(XO_FILE)
	cp sdaccel.ini ../out/hw_emu/*/
	mkdir -p ../out/hw_emu/*/plz/
	cd $(DEST_DIR);	$(XOCC) -g --platform $(AWS_PLATFORM) --dk protocol:all:all --profile_kernel data:all:all:all --target $(BUILD_TARGET) --link --temp_dir ./_x/plz/ --save-temps $(REPORT) --kernel $(KERNEL_NAME) ../../$(XO_FILE) $(KERNEL_LDCLFLAGS) $(KERNEL_FLAGS) $(KERNEL_ADDITIONAL_FLAGS) --output $(KERNEL_EXE).xclbin

endif

# Phony targets for intermediate results
.PHONY: host xo xclbin emulation build launch
host: $(DEST_DIR)/$(HOST_EXE)
host_debug: $(DEST_DIR)/$(HOST_EXE)_debug
xo: $(DEST_DIR)/$(KERNEL_EXE).xo
xclbin: $(DEST_DIR)/$(KERNEL_EXE).xclbin

ifeq ($(BUILD_TARGET), hw_emu)
HOST_XCLBIN=$(DEST_DIR)/$(KERNEL_EXE).xclbin
endif
# ifeq ($(BUILD_TARGET), hw)
# HOST_XCLBIN=$(BUILD_DIR)/$(KERNEL_EXE).awsxclbin
# # HW targets
# .PHONY: awsxclbin afi
# awsxclbin: $(HOST_XCLBIN)
# afi: awsxclbin
# endif

# TODO: Need sdx_project and sdx_workspace targets to build SDx workspace/project configured to work w/ the host application.


# For production use of port 80.
# Run is done in its own directory to avoid socket collision with development.
# $(LAUNCH_DIR)/live indicates that the server is live.
# $(LAUNCH_DIR)/dead indicates that the server is dead.

# .PHONY: live dead

# # TODO: "live" target runs in its own directory. We've since added support for LAUNCH_ID, which provides a generic separation
# #       of microservices. This could be used instead.
# live: $(LAUNCH_DIR)/live
# $(LAUNCH_DIR)/live: $(LAUNCH_DIR)/dead $(BUILD_TARGETS)
# 	@# Copy executables to launch dir to avoid impact from active development. Not sure how necessary this is.
# 	@cp $(BUILD_DIR)/$(HOST_EXE) $(LAUNCH_DIR)
# ifeq ($(USE_XILINX),true)
# 	@cp $(HOST_XCLBIN) $(LAUNCH_DIR)
# endif
# 	@# TODO: What about copying the launch script? If this is changed, will that affect the running server?
# 	@# TODO: Not sure it's necessary to set make vars. These might pass through as environment vars.
# 	@echo "Launching production server in the background"
# 	$(call with_secret,$(LAUNCH_PASSWORD) $(LAUNCH_CMD))
# 	-rm $(LAUNCH_DIR)/dead
# 	touch $(LAUNCH_DIR)/live
# 	@echo "Went live!!!   (Stop with 'make$(LAUNCH_ID_ARG_STR) dead' or restart by reexecuting this command.)"

# dead: $(LAUNCH_DIR)/dead
# $(LAUNCH_DIR)/dead:
# 	if [[ -e $(KILLME) ]]; then source $(KILLME) > /dev/null 2>&1 && echo "Giving web server time to exit gracefully." && sleep 7; $(ALREADY_DEAD) fi
# 	@mkdir -p $(LAUNCH_DIR) log
# 	rm -rf $(LAUNCH_DIR)/*
# 	@touch $(LAUNCH_DIR)/dead



PHONY: build launch
build: $(BUILD_TARGETS)

LAUNCH_CHECK=@if [ -e $(KILLME) ]; then echo "Error: There appears to already be an application running. Kill it with <Ctrl-C> or 'source $(KILLME)', or, if not running, 'rm $(KILLME)', and try again." && false; fi
# LAUNCH_CHECK=
launch: $(BUILD_TARGETS)
	$(LAUNCH_CHECK)
	@mkdir -p $(LAUNCH_DIR)
	$(call with_secret,$(LAUNCH_PASSWORD) $(LAUNCH_CMD))

# An un-documented target to launch the web server and open Chrome to test it.
# Requires $(CHROME) and works only for applications that open the websocket.
chrome: $(BUILD_TARGETS)
	$(LAUNCH_CHECK)
	@# Launch Chrome in background and webserver in foreground in "one-shot" mode (exit when websocket is closed).
# $(call with_secret,$(LAUNCH_PASSWORD) $(CHROME) -app='http:localhost:8888' & $(LAUNCH_CMD_PARTIAL) -p $(PORT) -o $(BUILD_TARGET) '$(HOST_CMD)')


.PHONY: debug_prints
debug_prints:
	$(info host path: $(DEST_DIR)/$(HOST_EXE))


.PHONY: copy_app
copy_app:
	if [[ -n '$(APP_NAME)' ]]; then $(REPO)/bin/copy_app '$(KERNEL_NAME)' '$(APP_NAME)'; else echo -e '\e[91m\e[1mAPP_NAME must be provided.\e[0m'; fi