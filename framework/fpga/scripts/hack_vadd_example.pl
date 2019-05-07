#!/usr/bin/perl

use strict;
use warnings;

# This script hacks the Xilinx vector add example produced by the rtl_kernel_wizard into an inner shell for the user kernel
# for this fpga-webserver infrastructure.
# The file mandelbrot_example_vadd.sv is provided in STDIN and STDOUT is the hacked version.
# $1 is the name of the kernel.


if ($#ARGV != 0) {
	print STDERR "Error: $0 requires an argument providing kernel name.\n";
	exit(1);
}
my $kernel = $ARGV[0];



my $status = 0;  # Return status.

# To keep track of replacements.
my $interface_additions = 0;  # Incremented when the interface substitutions are made.
my $axi_wr_master_subst1 = 0;  # Incremented when the 1st AXI write master substitution is made.
my $axi_wr_master_subst2 = 0;  # Incremented when the 2nd AXI write master substitution is made.
my $block_repl = 0;    # Lines deleted from block of code.
while (my $line = <STDIN>) {
	# TODO: Should we reduce wr_fifo depth?
  # TODO: Could expose FIFO depth to user kernel (for now, we keep the interface simple and leave it to the kernel to provide it's own output FIFO if necessary).

  # Add lines to the module interface.
	if ($line =~ /ctrl_xfer_size_in_bytes,$/) {
		$line .= " input wire [C_M_AXI_ADDR_WIDTH-1:0] resp_addr_offset, input wire [C_XFER_SIZE_WIDTH-1:0] resp_xfer_size_in_bytes,";
		$interface_additions++;
	}

	# Replace the following block of code:
  #    // Adder is combinatorial
  #    <kernel>_example_adder #(
  #      .C_AXIS_TDATA_WIDTH ( C_M_AXI_DATA_WIDTH ) ,
  #      .C_ADDER_BIT_WIDTH  ( C_ADDER_BIT_WIDTH  )
  #    )
  #    inst_adder  (
  #      .aclk          ( kernel_clk                   ) ,
  #      .aresetn       ( ~kernel_rst                  ) ,
  #      .ctrl_constant ( ctrl_constant_kernel_clk   ) ,
  #      .s_axis_tvalid ( rd_tvalid                    ) ,
  #      .s_axis_tready ( rd_tready                    ) ,
  #      .s_axis_tdata  ( rd_tdata                     ) ,
  #      .s_axis_tkeep  ( {C_M_AXI_DATA_WIDTH/8{1'b1}} ) ,
  #      .s_axis_tlast  ( rd_tlast                     ) ,
  #      .m_axis_tvalid ( adder_tvalid                 ) ,
  #      .m_axis_tready ( adder_tready                 ) ,
  #      .m_axis_tdata  ( adder_tdata                  ) ,
  #      .m_axis_tkeep  (                              ) , // Not used
  #      .m_axis_tlast  (                              )   // Not used
  #    );


  #    assign rd_fifo_tready = ~wr_fifo_prog_full;
  #
  #    mandelbrot_example_pipeline #(
  #      .C_DEPTH ( LP_RD_FIFO_READ_LATENCY )
  #    )
  #    inst_rd_fifo_valid_pipeline[C_M_AXI_NUM_THREADS-1:0] (
  #      .aclk   ( kernel_clk                             ) ,
  #      .areset ( kernel_rst                             ) ,
  #      .aclken ( 1'b1                                   ) ,
  #      .din    ( ~rd_fifo_tvalid_n & ~wr_fifo_prog_full ) ,
  #      .dout   ( rd_fifo_tvalid                         )
  #    );
  #
  #    // Adder has 2 pipeline stages (1 cycle latency)
  #    mandelbrot_example_adder #(
  #      .C_DATA_WIDTH      ( C_M_AXI_DATA_WIDTH ) ,
  #      .C_ADDER_BIT_WIDTH ( C_ADDER_BIT_WIDTH  )
  #    )
  #    inst_adder[C_M_AXI_NUM_THREADS-1:0]  (
  #      .aclk          ( kernel_clk     ) ,
  #      .areset        ( kernel_rst     ) ,
  #      .ctrl_constant ( ctrl_constant  ) ,
  #      .s_tvalid      ( rd_fifo_tvalid ) ,
  #      .s_tdata       ( rd_fifo_tdata  ) ,
  #      .m_tvalid      ( adder_tvalid   ) ,
  #      .m_tdata       ( adder_tdata    )
  #    );
  if ($line =~ /_example_adder/) {
		# Find 'inst_adder'.
		do {
			$block_repl++;
			if (!$line) {
				print STDERR "Error: $0 failed to find end of adder kernel instantiation for replacement.";
				$status = 1;
				last;
			}
			$line = <STDIN>;
		} while ($line !~ /\);/);
    $line = <<'CODE_BLOCK';

// --------------------------------------------------------
// BEGIN hack of adder example to insert user kernel.

user_kernel #(
  .C_DATA_WIDTH (C_M_AXI_DATA_WIDTH )
)
inst_adder (
  .clk          ( kernel_clk     ) ,
  .reset        ( kernel_rst     ) ,
  .in_ready     ( rd_tready ),
  .in_avail      ( rd_tvalid ) ,
  .in_data       ( rd_tdata  ) ,
  .out_ready     ( adder_tready ),
  .out_avail      ( adder_tvalid   ) ,
  .out_data       ( adder_tdata    )
);

// END hack of adder example to insert user kernel.
// --------------------------------------------------------

CODE_BLOCK
    # rename the module in the above code.
    my $kernel_module_name = $kernel . "_kernel";
    $line =~ s/\buser_kernel\b/$kernel_module_name/g;
  }


  # Replace args for AXI write master. The kernel is generated doing reads and writes to the same memory. This memory becomes the read memory,
	# and we replace the write memory.
	if ($block_repl &&    # The AXI write master appears in the code after the kernel instantiation, whereas read appears before.
      $line =~ s/\(\s*ctrl_addr_offset\s*\)/\( resp_addr_offset \)/
		 ) {
		$axi_wr_master_subst1++;
	}
	if ($block_repl &&
      $line =~ s/\(\s*ctrl_xfer_size_in_bytes\s*\)/\( resp_xfer_size_in_bytes \)/
		 ) {
		$axi_wr_master_subst2++;
	}


  print $line;
}


# Make sure the proper replacements were performed.

if ($interface_additions != 1) {
	print STDERR "Error: $0 failed to add to interface definition exactly once. Added $interface_additions times.\n";
  $status = 1;
}
if ($block_repl > 24 || $block_repl < 12) {
  print STDERR "Error: $0 failed to replace about 26 lines of adder core module instantiation. Replaced $block_repl.\n";
  $status = 1;
}
if ($axi_wr_master_subst1 != 1 || $axi_wr_master_subst2 != 1) {
  print STDERR "Error: $0 failed to replace AXI write master inputs correctly. (Debug: $axi_wr_master_subst1 != 1 || $axi_wr_master_subst2 != 1)\n";
  $status = 1;
}



exit($status);
