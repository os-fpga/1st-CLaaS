# Extends framework Makefile with mandelbrot-specific stuff.
# See framework/build/Makefile for usage info.

ADDITIONAL_SRC=$(HOST_DIR)/mandelbrot_main.cpp  # Provided as additional source to allow for other projects to provide a different main.

PROJ_C_SRC=$(HOST_DIR)/mandelbrot.c $(HOST_DIR)/lodepng.c $(ADDITIONAL_SRC)
PROJ_C_HDRS=$(HOST_DIR)/mandelbrot.h $(HOST_DIR)/lodepng.h

HW_SHELL_CONFIG_JSON=../fpga/shell_config.json

KERNEL=mandelbrot


include ../../../framework/build/Makefile



# MOVE TO FRAMEWORK:
ifeq ($(TARGET), sw)
else
# Create tcl script for the kernel configuration
$(DEST_DIR)/rtl_kernel_wiz.tcl: $(FRAMEWORK_DIR)/fpga/scripts/produce_tcl_file.py $(HW_SHELL_CONFIG_JSON)
	python $(FRAMEWORK_DIR)/fpga/scripts/produce_tcl_file.py $(HW_SHELL_CONFIG_JSON) $(DEST_DIR)/rtl_kernel_wiz.tcl

# Creating the rtl kernel wizard project.
# kernel.xml acts as a representative for all produced files.
$(DEST_DIR)/$(KERNEL_NAME)/imports/kernel.xml: $(DEST_DIR)/rtl_kernel_wiz.tcl
	vivado -mode batch -nojournal -nolog -notrace -source $(DEST_DIR)/rtl_kernel_wiz.tcl -tclargs $(KERNEL_NAME) $(DEST_DIR)/$(KERNEL_NAME)_hw

.PHONY: shell
shell: $(DEST_DIR)/$(KERNEL_NAME)/imports/kernel.xml

# Moving the Makefile necessary for Hardware emulation and build into the sdx_imports directory
# TODO: Is this necessary?
#cp $LIB_DIR/src/Makefile $2/${1}_ex/sdx_imports/


$(DEST_DIR)/$(KERNEL_EXE).xo:
	mkdir -p $(DEST_DIR)
	#$(XOCC) --platform $(PLATFORM) --target $(TARGET) --compile --include $(KERNEL_HDRS) --save-temps $(REPORT) --kernel $(KERNEL_NAME) $(KERNEL_SRC) $(KERNEL_LDCLFLAGS) $(KERNEL_FLAGS) $(KERNEL_ADDITIONAL_FLAGS) --output $(DEST_DIR)/$(KERNEL_EXE).xo
	# TODO: How do we generate the .xo?
	cp ../fpga/mandelbrot_hw/sdx_imports/$(KERNEL_EXE).xo $(DEST_DIR)/$(KERNEL_EXE).xo
endif

