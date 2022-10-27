VIVADO := $(XILINX_VIVADO)/bin/vivado
$(TEMP_DIR)/vadd.xo: $(ABS_COMMON_REPO)/apps/vadd/fpga/scripts/package_kernel.tcl $(ABS_COMMON_REPO)/apps/vadd/fpga/scripts/gen_xo.tcl $(ABS_COMMON_REPO)/apps/vadd/fpga/*.sv $(ABS_COMMON_REPO)/apps/vadd/fpga/*.v $(ABS_COMMON_REPO)/apps/vadd/fpga/tlv/*.tlv
	sandpiper-saas -i $(ABS_COMMON_REPO)/apps/vadd/fpga/tlv/sw.tlv --outdir $(ABS_COMMON_REPO)/apps/vadd/fpga/ -o krnl_vadd_rtl_adder.sv --fmtFlatSignals --bestsv --noline
	mkdir -p $(TEMP_DIR)
	$(VIVADO) -mode batch -source $(ABS_COMMON_REPO)/apps/vadd/fpga/gen_xo.tcl -tclargs $(TEMP_DIR)/vadd.xo vadd $(TARGET) $(DEVICE) $(XSA)
