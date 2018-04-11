# This is a generated file. Use and modify at your own risk.
################################################################################

# Define clock constraints for out of context synthesis/implementation runs only. This clock will
# be overwritten when the kernel is linked into the SDx system. Out of context results will provide
# an optimistic view of timing closure compared to final place and route results in a loaded
# system. Modifications to the clock here will have no bearing on xclbin timing.
create_clock -period 4.000 [get_ports ap_clk]
# Secondary clock is async to ap_clk. Same notes above apply here.
create_clock -period 5.000 [get_ports ap_clk_2]
