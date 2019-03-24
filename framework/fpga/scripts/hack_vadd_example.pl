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
my $unused_sig_repl = 0; # Unused signal line replaced.
my $latency_repl = 0;  # rd FIFO latency replaced.
my $type_repl = 0;     # rd FIFO type replaced.
#my $full_latency_repl = 0; # wr FIFO FULL_THRESH replaced.
my $block_repl = 0;    # Lines deleted from block of code.
while (my $line = <STDIN>) {
	# Delete an unused signal line.
	$unused_sig_repl += $line =~ s/logic\b.+\brd_fifo_tvalid;//;
  # Replace latency of rd_fifo 1 -> 0.
  $latency_repl += $line =~ s/LP_WR_FIFO_READ_LATENCY\s*=\s*1/LP_WR_FIFO_READ_LATENCY = 0/;
  # Replace array type of rd_fifo "std" -> "fwft". This provides a 0-cycle bypass of the input data.
  $type_repl += $line =~ s/\(\s*"std"/\( "fwft"/;
	# TODO: I don't understand the setting of FULL_THRESH for wr_fifo. It seems it should be less than max in the vadd example to account
	#       for the two cycles of latency in the vadd pipeline since the backpressure is applied at the beginning of this pipeline, but it is
	#       set to the value above which the module reports an error. The user kernel is required to apply backpressure immediately, so
	#       we leave it at its max value, but I'm not entirely sure this is a correct/optimal value.
	# TODO: Should we reduce wr_fifo depth?
  # TODO: Could expose FIFO depth to user kernel (for now, we keep the interface simple and leave it to the kernel to provide it's own output FIFO if necessary).
  #$full_latency_repl += $line =~ s/\.PROG_FULL_THRESH\s*\(\s*LP_WR_FIFO_DEPTH-5\s*\)/.PROG_FULL_THRESH \( LP_WR_FIFO_DEPTH-1 \)/;


	# Replace the following block of code:
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
  if ($line =~ /assign rd_fifo_tready/) {
		# Find 'inst_adder'.
		do {
			$block_repl++;
			if (!$line) {
				print STDERR "Error: $0 failed to find 'inst_adder' in replacement block.";
				$status = 1;
				last;
			}
			$line = <STDIN>;
		} while ($line !~ /inst_adder/);
    # Find end of 'inst_adder'.
		do {
			$block_repl++;
			if (!$line) {
				print STDERR "Error: $0 failed to find end of replacement block.";
				$status = 1;
				last;
			}
			$line = <STDIN>;
		} while ($line !~ /\);/);
    $line = <<'CODE_BLOCK';

// --------------------------------------------------------
// BEGIN hack of adder example to insert user kernel.

// User kernel uses avail/blocked API (like TLV Flow Lib).
logic user_kernel_out_avail;
logic user_kernel_in_blocked, user_kernel_in_avail;
assign rd_fifo_tready = ~user_kernel_in_blocked;
assign user_kernel_in_avail = ~rd_fifo_tvalid_n;

user_kernel #(
  .C_DATA_WIDTH      ( C_M_AXI_DATA_WIDTH )
)
user_kernel[C_M_AXI_NUM_THREADS-1:0]  (
  .clk           ( kernel_clk     ) ,
  .reset         ( kernel_rst     ) ,
  .in_blocked    ( user_kernel_in_blocked ) ,
  .in_avail      ( user_kernel_in_avail ) ,
  .in_data       ( rd_fifo_tdata  ) ,
  .out_blocked   ( wr_fifo_prog_full ) ,
  .out_avail     ( user_kernel_out_avail ) ,
  .out_data      ( adder_tdata    )
);

assign adder_tvalid = user_kernel_out_avail && ~wr_fifo_prog_full;

// END hack of adder example to insert user kernel (though there are one-line hacks elsewhere; diff w/ .orig).
// --------------------------------------------------------

CODE_BLOCK
    # rename the module in the above code.
    my $kernel_module_name = $kernel . "_kernel";
    $line =~ s/\buser_kernel\b/$kernel_module_name/g;
  }

  print $line;
}

# Make sure the proper replacements were performed.
if ($unused_sig_repl != 1) {
  print STDERR "Error: $0 failed to replace exactly one unused signal line. Replaced $unused_sig_repl.\n";
  $status = 1;
}
if ($latency_repl != 1) {
  print STDERR "Error: $0 failed to replace exactly one rd_fifo latency. Replaced $latency_repl.\n";
  $status = 1;
}
if ($type_repl != 2) {
  print STDERR "Error: $0 failed to replace exactly two fd_fifo type. Replaced $type_repl.\n";
  $status = 1;
}
if ($block_repl > 30 || $block_repl < 22) {
  print STDERR "Error: $0 failed to replace about 26 lines of adder core module instantiation. Replaced $block_repl.\n";
  $status = 1;
}
#if ($full_latency_repl != 2) {
#  print STDERR "Error: $0 failed to replace exactly two wr_fifo FULL_THRESH. Replaced $full_latency_repl.\n";
#}

exit($status);
