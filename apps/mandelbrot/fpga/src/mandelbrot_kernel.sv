`include "sp_default.vh" //_\SV

   // ==========================
   // Mandelbrot Set Calculation
   // ==========================

   // To relax Verilator compiler checking:
   /* verilator lint_off UNOPTFLAT */
   /* verilator lint_on WIDTH */
   /* verilator lint_off REALCVT */  // !!! SandPiper DEBUGSIGS BUG.

   // Parameters:


   // Fixed numbers (sign, int, fraction)
	// Fixed values are < 8.0.
	// There are two bit widths, normal and extended:
	// 	- Extended is used for X and Y coordinates calculation to avoid
	//      the accumulation of the rounding error as pixel width is added


	// Extended precision



	// Data width for the incoming configuration data


	// Interleaving computation cycles


	// PE pipeline depth


   // Number of replicated Processing Elements


   // Constants and computed values:
   // Bit indices for fixed numbers
	// 	- [X:0] = integer portion
	// 	- [-1:Y] = fractional portion




	// Fixed point definition




   // Extended fixed point definitions



	//m4_makerchip_module
   // Zero extend to given width.
   `define ZX(val, width) {{1'b0{width-$bits(val)}}, val}

	module top(input logic clk, input logic reset, input logic [31:0] cyc_cnt, output logic passed, output logic failed);    /* verilator lint_save */ /* verilator lint_off UNOPTFLAT */  bit [256:0] RW_rand_raw; bit [256+63:0] RW_rand_vect; pseudo_rand #(.WIDTH(257)) pseudo_rand (clk, reset, RW_rand_raw[256:0]); assign RW_rand_vect[256+63:0] = {RW_rand_raw[62:0], RW_rand_raw};  /* verilator lint_restore */  /* verilator lint_off WIDTH */ /* verilator lint_off UNOPTFLAT */
		logic s_tvalid;
		logic [511:0] s_tdata;
		logic m_tvalid;
		logic [511:0] m_tdata;

		assign s_tvalid = cyc_cnt == 10;
		assign s_tdata = {
         					64'b0,
         					64'd128,
         					64'd512,
         					64'd512,
                        2'b0, {7{1'b1}}, 1'b0, {2{1'b1}}, 52'b0,
         					2'b0, {7{1'b1}}, 1'b0, {2{1'b1}}, 52'b0,
         					{2{1'b1}}, 62'b0,
         					{2{1'b1}}, 62'b0
							  };

		mandelbrot_kernel dut (
         .clk(clk),
         .reset(reset),
         .in_blocked(),  // Assumed not blocked.
         .in_avail(s_tvalid),
         .in_data(s_tdata),
         .out_blocked(1'b0),  // Never block output.
         .out_avail(m_tvalid),
         .out_data(m_tdata)
      );
		// Assert these to end simulation (before Makerchip cycle limit).
      assign passed = !clk || dut.done || cyc_cnt > 500;
      assign failed = !clk || 1'b0;
   endmodule



   module mandelbrot_kernel #(
     parameter integer C_DATA_WIDTH = 512 // Data width of both input and output data
   )
   (
     input wire                       clk,
     input wire                       reset,

     output wire                      in_blocked,
     input wire                       in_avail,
     input wire  [C_DATA_WIDTH-1:0]   in_data,

     input wire                       out_blocked,
     output wire                      out_avail,
     output wire [C_DATA_WIDTH-1:0]   out_data

   );
   logic done;  // Instrumentation-only. Used to end simulation.

   function logic [3:-29] fixed_mul (input logic [3:-29] v1, v2);
      logic [3-1:0] drop_bits;
      logic [29-1:0] insignificant_bits;
      {fixed_mul[3], drop_bits, fixed_mul[2:-29], insignificant_bits} =
         {v1[3] ^ v2[3], ({{32{1'b0}}, v1[2:-29]} * {{32{1'b0}}, v2[2:-29]})};
   endfunction;

   function logic [3:-29] fixed_add (input logic [3:-29] v1, v2, input logic sub);
      logic [3:-29] binary_v2;
      binary_v2 = fixed_to_binary(v1) +
                  fixed_to_binary({v2[3] ^ sub, v2[2:-29]});
      fixed_add = binary_to_fixed(binary_v2);
   endfunction;

   function logic [3:-29] fixed_to_binary (input logic [3:-29] f);
      fixed_to_binary =
         f[3]
            ? // Flip non-sign bits and add one. (Adding one is insignificant, so we save hardware and don't do it.)
              {1'b1, ~f[2:-29] /* + {{32-1{1'b0}}, 1'b1} */}
            : f;
   endfunction;

   function logic [3:-29] binary_to_fixed (input logic [3:-29] b);
      // The conversion is symmetric.
      binary_to_fixed = fixed_to_binary(b);
   endfunction;

   function logic [3:-29] real_to_fixed (input logic [63:0] b);
      real_to_fixed = {b[63], {1'b1, b[51:53-32]} >> (-(b[62:52] - 1023) + 3 - 1)};
   endfunction;

   function logic [3:-39] real_to_ext_fixed (input logic [63:0] b);
      real_to_ext_fixed = {b[63], {1'b1, b[51:53-42]} >> (-(b[62:52] - 1023) + 3 - 1)};
   endfunction;

`include "mandelbrot_kernel_gen.vh"
generate //_\TLV

   //_|pipe
      //_@-1
         assign PIPE_reset_n1 = reset;
      //_@0

         assign in_blocked = 1'b0;  // TODO: Backpressure.
         assign PIPE_valid_config_data_in_a0 = in_avail && ! in_blocked;
         assign {PIPE_config_data_bogus_a0[63:0],
          PIPE_config_max_depth_a0[63:0],
          PIPE_config_img_size_y_a0[63:0],
          PIPE_config_img_size_x_a0[63:0],
          PIPE_config_data_pix_y_a0[63:0],
          PIPE_config_data_pix_x_a0[63:0],
          PIPE_config_data_min_y_a0[63:0],
          PIPE_config_data_min_x_a0[63:0]} = in_data;

         `BOGUS_USE(PIPE_config_data_bogus_a0)

         // Initialization of a new frame. Generates a pulse signal
         assign PIPE_start_frame_a0 = PIPE_valid_config_data_in_a0;
         assign PIPE_init_frame_a0 = PIPE_start_frame_a0;

         // The computation is interleaved across M4_ITER cycles/strings
         //
         // Init frame will be asserted once every frame computation for each string
         // $init_frame = $start_frame ? 0 : >>1$start_frame;

         // Val holds the valid condition for the computation
         // $val = $reset ? 0 : $init_frame || >>M4_ITER$val;
         //
         // ViewBox (fly-through)
         //
         // The view, given by upper-left corner coords and pixel x & y size.
         // It is initialized by the input FIFO
         assign PIPE_MinX_n1[3:-29] = PIPE_reset_a0 ? '0 : PIPE_valid_config_data_in_a0 ? real_to_fixed(PIPE_config_data_min_x_a0) : PIPE_MinX_a0[3:-29];
         assign PIPE_MinY_n1[3:-29] = PIPE_reset_a0 ? '0 : PIPE_valid_config_data_in_a0 ? real_to_fixed(PIPE_config_data_min_y_a0) : PIPE_MinY_a0[3:-29];
         assign PIPE_PixX_n1[3:-39] = PIPE_reset_a0 ? '0 : PIPE_valid_config_data_in_a0 ? real_to_ext_fixed(PIPE_config_data_pix_x_a0) : PIPE_PixX_a0[3:-39];
         assign PIPE_PixY_n1[3:-39] = PIPE_reset_a0 ? '0 : PIPE_valid_config_data_in_a0 ? real_to_ext_fixed(PIPE_config_data_pix_y_a0) : PIPE_PixY_a0[3:-39];

         // The size of the image is dynamic
         assign PIPE_size_x_a0[3:-29] = PIPE_reset_a0 ? '0 : PIPE_valid_config_data_in_a0 ? PIPE_config_img_size_x_a0[31:0] : PIPE_size_x_a1[3:-29];
         assign PIPE_size_y_a0[3:-29] = PIPE_reset_a0 ? '0 : PIPE_valid_config_data_in_a0 ? PIPE_config_img_size_y_a0[31:0] : PIPE_size_y_a1[3:-29];

         assign PIPE_max_depth_a0[31:0] = PIPE_reset_a0 ? '0 : PIPE_valid_config_data_in_a0 ? PIPE_config_max_depth_a0[31:0] : PIPE_max_depth_a1[31:0];

      for (pe = 0; pe <= 63; pe++) begin : L1_PIPE_Pe //_/pe
         //_@0
            // Reset signal
            assign PIPE_Pe_reset_a0[pe] = PIPE_reset_a0;

         //_@1
            //
            // Screen render control
            //

            // Initialization of a new pixel
            assign PIPE_Pe_init_pix_a1[pe] = ! PIPE_Pe_reset_a1[pe] & (PIPE_all_pix_done_pulse_a3 | PIPE_init_frame_a1);

            // Cycle over pixels (vertical (outermost) and horizontal) and depth (innermost).
            // When each wraps, increment the next.
            assign PIPE_Pe_wrap_h_a1[pe] = PIPE_Pe_pix_h_a1[pe] >= PIPE_size_x_a1 - 64;
            assign PIPE_Pe_wrap_v_a1[pe] = PIPE_Pe_pix_v_a1[pe] == PIPE_size_y_a1 - 1;

            assign PIPE_Pe_depth_a0[pe][15:0] =
               PIPE_Pe_reset_a1[pe]       ? '0      :
               PIPE_Pe_init_pix_a1[pe]    ? '0      :
                              PIPE_Pe_depth_a1[pe] + 1;
            assign PIPE_Pe_pix_h_a0[pe][31:0] =
               PIPE_Pe_reset_a1[pe]       ? pe :
               PIPE_Pe_init_pix_a1[pe]    ? PIPE_Pe_wrap_h_a1[pe] ? pe :
                                        PIPE_Pe_pix_h_a1[pe] + 64 :
                              PIPE_Pe_pix_h_a1[pe][31:0];
            assign PIPE_Pe_pix_v_a0[pe][31:0] =
               PIPE_Pe_reset_a1[pe]                    ? '0 :
               (PIPE_Pe_init_pix_a1[pe] && PIPE_Pe_wrap_h_a1[pe])    ? PIPE_Pe_wrap_v_a1[pe] ? '0 :
                                                     PIPE_Pe_pix_v_a1[pe] + 1 :
                                           PIPE_Pe_pix_v_a1[pe][31:0];

            //
            // Map pixels to x,y coords
            //


         //_@2
            // The coordinates of the pixel we are working on.
            //**real $xx;
            // $xx = $init_pix ? $MinX + $PixX * $PixH : $RETAIN;  (in fixed-point)
            assign PIPE_Pe_xx_mul_a2[pe][2:-39] =
               (PIPE_PixX_a2[2:-39] * `ZX(PIPE_Pe_pix_h_a2[pe], 42));
            assign PIPE_Pe_xx_a2[pe][3:-29] =
               PIPE_Pe_init_pix_a2[pe] ? fixed_add(PIPE_MinX_a2[3:-29],
                                 {1'b0, PIPE_Pe_xx_mul_a2[pe][2:-29]},
                                 1'b0)
                     : PIPE_Pe_xx_a3[pe][3:-29];
            //**real $yy;
            // $yy = $init_pix ? $MinY + $PixY * $PixV : $RETAIN;  (in fixed-point)
            assign PIPE_Pe_yy_mul_a2[pe][2:-39] =
               (PIPE_PixY_a2[2:-39] * `ZX(PIPE_Pe_pix_v_a2[pe], 42));
            assign PIPE_Pe_yy_a2[pe][3:-29] =
               PIPE_Pe_init_pix_a2[pe] ? fixed_add(PIPE_MinY_a2[3:-29],
                                     {1'b0, PIPE_Pe_yy_mul_a2[pe][2:-29]},
                                     1'b0)
                     : PIPE_Pe_yy_a3[pe][3:-29];

         //_@3
            //
            // Mandelbrot Calculation
            //
            // Mandelbrot algorithm:
            // a = 0.0
            // b = 0.0
            // depth = 0
            // for depth [0..max_depth] until diverged {  // one iteration per cycle
            //   a <= a*a - b*b + x
            //   b <= 2*a*b + y
            //   diverged = a*a + b*b >= 2.0*2.0
            // }
            assign PIPE_Pe_aa_sq_a3[pe][3:-29] = fixed_mul(PIPE_Pe_aa_a3[pe], PIPE_Pe_aa_a3[pe]);
            assign PIPE_Pe_bb_sq_a3[pe][3:-29] = fixed_mul(PIPE_Pe_bb_a3[pe], PIPE_Pe_bb_a3[pe]);
            assign PIPE_Pe_aa_sq_plus_bb_sq_a3[pe][3:-29] = fixed_add(PIPE_Pe_aa_sq_a3[pe], PIPE_Pe_bb_sq_a3[pe], 1'b0);
            assign PIPE_Pe_done_pix_a3[pe] = PIPE_Pe_init_pix_a3[pe] ? 1'b0 :
                PIPE_Pe_done_pix_a4[pe]      ? 1'b1 : //Hold value until init_pix is asserted
                // a*a + b*b
                ((PIPE_Pe_aa_sq_plus_bb_sq_a3[pe][3] == 1'b0) &&
                 (PIPE_Pe_aa_sq_plus_bb_sq_a3[pe][2:-29] >= real_to_fixed({1'b0, 1'b1, 9'b0, 1'b1, 52'b0}))
                ) ||
                // This term catches some overflow cases w/ the multiply and allows fewer int bits to be used.
                // |a| >= 2.0 || |b| >= 2.0
                (|{PIPE_Pe_aa_a3[pe][3-1:3-3+1],
                   PIPE_Pe_bb_a3[pe][3-1:3-3+1]}
                ) ||
                (PIPE_Pe_depth_a3[pe] == PIPE_max_depth_a3);
            //+$not_done = ! $done_pix;

            //?$not_done
            assign PIPE_Pe_aa_sq_minus_bb_sq_a3[pe][3:-29] = fixed_add(PIPE_Pe_aa_sq_a3[pe], PIPE_Pe_bb_sq_a3[pe], 1'b1);
            assign PIPE_Pe_aa_a2[pe][3:-29] = PIPE_Pe_init_pix_a3[pe] ? PIPE_Pe_xx_a3[pe] : fixed_add(PIPE_Pe_aa_sq_minus_bb_sq_a3[pe], PIPE_Pe_xx_a3[pe], 1'b0);
            assign PIPE_Pe_aa_times_bb_a3[pe][3:-29] = fixed_mul(PIPE_Pe_aa_a3[pe], PIPE_Pe_bb_a3[pe]);
            assign PIPE_Pe_aa_times_bb_times_2_a3[pe][3:-29] = {PIPE_Pe_aa_times_bb_a3[pe][3], PIPE_Pe_aa_times_bb_a3[pe][2:-29] << 1};
            assign PIPE_Pe_bb_a2[pe][3:-29] = PIPE_Pe_init_pix_a3[pe] ? PIPE_Pe_yy_a3[pe] : fixed_add(PIPE_Pe_aa_times_bb_times_2_a3[pe], PIPE_Pe_yy_a3[pe], 1'b0);

            assign PIPE_Pe_done_pix_pulse_a3[pe] = PIPE_Pe_done_pix_a3[pe] & ! PIPE_Pe_done_pix_a4[pe];
            assign PIPE_Pe_depth_out_a3[pe][7:0] = PIPE_Pe_done_pix_pulse_a3[pe] ? PIPE_Pe_depth_a3[pe][7:0] : PIPE_Pe_depth_out_a4[pe][7:0];
      end
      //_@3
         assign out_data = PIPE_Pe_depth_out_a3;
         assign PIPE_all_pix_done_a3 = PIPE_reset_a3 ? '0 : & PIPE_Pe_done_pix_a3;
         assign PIPE_all_pix_done_pulse_a3 = PIPE_all_pix_done_a3 & ! PIPE_all_pix_done_a4;

         assign out_avail = PIPE_all_pix_done_pulse_a3;  // TODO: Lost if there is backpressure!
         assign done = PIPE_reset_a3 ? '0 : PIPE_all_pix_done_pulse_a3 & PIPE_Pe_wrap_h_a3 & PIPE_Pe_wrap_v_a3;
endgenerate

//_\SV
   endmodule
