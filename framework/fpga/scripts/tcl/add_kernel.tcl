# This script adds the user's kernel into the project.
# It adds verilog source to project, so verilog source must be built (from .tlv)
remove_files *_example_adder.v
add_files ../fpga/src
add_files ../out/sv
