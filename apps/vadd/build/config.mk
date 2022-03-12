VIVADO := $(XILINX_VIVADO)/bin/vivado
$(TEMP_DIR)/vadd.xo: $(ABS_COMMON_REPO)/apps/vadd/fpga/scripts/package_kernel.tcl $(ABS_COMMON_REPO)/apps/vadd/fpga/scripts/gen_xo.tcl $(ABS_COMMON_REPO)/apps/vadd/fpga/src/*.sv $(ABS_COMMON_REPO)/apps/vadd/fpga/src/*.v $(ABS_COMMON_REPO)/apps/vadd/fpga/src/tlv/*.tlv
	sandpiper-saas -i $(ABS_COMMON_REPO)/apps/vadd/fpga/src/tlv/sw.tlv --outdir $(ABS_COMMON_REPO)/apps/vadd/fpga/src/ -o krnl_vadd_rtl_adder.sv --fmtFlatSignals --bestsv --noline
	mkdir -p $(TEMP_DIR)
	$(VIVADO) -mode batch -source $(ABS_COMMON_REPO)/apps/vadd/fpga/scripts/gen_xo.tcl -tclargs $(TEMP_DIR)/vadd.xo vadd $(TARGET) $(DEVICE) $(XSA)
