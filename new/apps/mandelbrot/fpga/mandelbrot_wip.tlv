\m4_TLV_version 1d --fmtFlatSignals: tl-x.org
\SV

   // ==========================
   // Mandelbrot Set Calculation
   // ==========================

   // To relax Verilator compiler checking:
   /* verilator lint_off UNOPTFLAT */
   /* verilator lint_on WIDTH */
   /* verilator lint_off REALCVT */  // !!! SandPiper DEBUGSIGS BUG.

   // Parameters:
   m4_define(M4_MAX_DEPTH, 32)

   // Fixed numbers (sign, int, fraction)
	// Fixed values are < 8.0.
	// There are two bit widths, normal and extended:
	// 	- Extended is used for X and Y coordinates calculation to avoid 
	//      the accumulation of the rounding error as pixel width is added
   m4_define(M4_FIXED_UNSIGNED_WIDTH, 32)
	
	// Extended precision
   m4_define(M4_FIXED_EXT_PRECISION, 10)
	m4_define(M4_FIXED_EXT_UNSIGNED_WIDTH, m4_eval(M4_FIXED_UNSIGNED_WIDTH + M4_FIXED_EXT_PRECISION))

	// Data width for the incoming configuration data
	m4_define_vector(M4_CONFIG_DATA, 512)

	// Interleaving computation cycles
	m4_define(M4_ITER, 1)
	
	// PE pipeline depth
	m4_define(M4_PIPE_DEPTH, 2)

   // Number of replicated Processing Elements
   m4_define_hier(M4_PE, 64)

   // Constants and computed values:
   // Bit indices for fixed numbers
	// 	- [X:0] = integer portion
	// 	- [-1:Y] = fractional portion

	m4_define(M4_FIXED_INT_WIDTH, 3)
   m4_define(M4_FIXED_SIGN_BIT, M4_FIXED_INT_WIDTH)
   
	// Fixed point definition
   m4_define(M4_FIXED_FRAC_WIDTH, m4_eval(M4_FIXED_UNSIGNED_WIDTH - M4_FIXED_INT_WIDTH))
   m4_define(M4_FIXED_RANGE, ['M4_FIXED_SIGN_BIT:-M4_FIXED_FRAC_WIDTH'])
   m4_define(M4_FIXED_UNSIGNED_RANGE, ['m4_eval(M4_FIXED_SIGN_BIT-1):-M4_FIXED_FRAC_WIDTH'])
	
   // Extended fixed point definitions
	m4_define(M4_FIXED_EXT_FRAC_WIDTH, m4_eval(M4_FIXED_EXT_UNSIGNED_WIDTH - M4_FIXED_INT_WIDTH))
	m4_define(M4_FIXED_EXT_RANGE, ['M4_FIXED_SIGN_BIT:m4_eval(-(M4_FIXED_FRAC_WIDTH + M4_FIXED_EXT_PRECISION))'])
	m4_define(M4_FIXED_EXT_UNSIGNED_RANGE, ['m4_eval(M4_FIXED_SIGN_BIT-1):-M4_FIXED_EXT_FRAC_WIDTH'])
	//m4_makerchip_module
   // Zero extend to given width.
   `define ZX(val, width) {{1'b0{width-$bits(val)}}, val}

	m4_makerchip_module
		logic start;
		logic done;
		logic s_tvalid;
		logic [M4_CONFIG_DATA_RANGE] s_tdata;
		logic m_tvalid;
		logic [M4_CONFIG_DATA_RANGE] m_tdata;
		
		assign start = cyc_cnt == 20;
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
	
		mandelbrot dut(
         .aclk(clk),
         .areset(reset),
         .start(start),
         .done(done),
         .s_tvalid(s_tvalid),
         .s_tdata(s_tdata),
         .m_tvalid(m_tvalid),
         .m_tdata(m_tdata)
      );
		// Assert these to end simulation (before Makerchip cycle limit).
      assign passed = !clk || done || cyc_cnt > 500;
      assign failed = !clk || 1'b0;
   endmodule

   module clk_gate (output logic gated_clk, input logic free_clk, func_en, pwr_en, gating_override);
      logic clk_en;
      logic latched_clk_en  /*verilator clock_enable*/;
      always_comb clk_en = func_en & (pwr_en | gating_override);
      always_latch if (~free_clk) latched_clk_en <= clk_en;
      // latched_clk_en <= (~free_clk) ? clk_en : latched_clk_en;
      always_comb gated_clk = latched_clk_en & free_clk;
   endmodule  
      
   module mandelbrot #(
        parameter integer C_DATA_WIDTH = 512,
        parameter integer C_ADDER_BIT_WIDTH = 32
   )
   (
        input logic aclk,
        input logic areset,
        input logic start,
        output logic done,
      
        input logic s_tvalid,
        input logic [C_DATA_WIDTH-1:0] s_tdata,
        
        output logic m_tvalid,
        output logic [C_DATA_WIDTH-1:0] m_tdata
    );

   logic clk;
   assign clk = aclk;
   
   function logic [M4_FIXED_RANGE] fixed_mul (input logic [M4_FIXED_RANGE] v1, v2);
      logic [M4_FIXED_INT_WIDTH-1:0] drop_bits;
      logic [M4_FIXED_FRAC_WIDTH-1:0] insignificant_bits;
      {fixed_mul[M4_FIXED_SIGN_BIT], drop_bits, fixed_mul[M4_FIXED_UNSIGNED_RANGE], insignificant_bits} =
         {v1[M4_FIXED_SIGN_BIT] ^ v2[M4_FIXED_SIGN_BIT], ({{M4_FIXED_UNSIGNED_WIDTH{1'b0}}, v1[M4_FIXED_UNSIGNED_RANGE]} * {{M4_FIXED_UNSIGNED_WIDTH{1'b0}}, v2[M4_FIXED_UNSIGNED_RANGE]})};
   endfunction;

   function logic [M4_FIXED_RANGE] fixed_add (input logic [M4_FIXED_RANGE] v1, v2, input logic sub);
      logic [M4_FIXED_RANGE] binary_v2;
      binary_v2 = fixed_to_binary(v1) +
                  fixed_to_binary({v2[M4_FIXED_SIGN_BIT] ^ sub, v2[M4_FIXED_UNSIGNED_RANGE]});
      fixed_add = binary_to_fixed(binary_v2);
   endfunction;

   function logic [M4_FIXED_RANGE] fixed_to_binary (input logic [M4_FIXED_RANGE] f);
      fixed_to_binary =
         f[M4_FIXED_SIGN_BIT]
            ? // Flip non-sign bits and add one. (Adding one is insignificant, so we save hardware and don't do it.)
              {1'b1, ~f[M4_FIXED_UNSIGNED_RANGE] /* + {{M4_FIXED_UNSIGNED_WIDTH-1{1'b0}}, 1'b1} */}
            : f;
   endfunction;

   function logic [M4_FIXED_RANGE] binary_to_fixed (input logic [M4_FIXED_RANGE] b);
      // The conversion is symmetric.
      binary_to_fixed = fixed_to_binary(b);
   endfunction;
                                  
   function logic [M4_FIXED_RANGE] real_to_fixed (input logic [63:0] b);
      real_to_fixed = {b[63], {1'b1, b[51:53-M4_FIXED_UNSIGNED_WIDTH]} >> (-(b[62:52] - 1023) + M4_FIXED_INT_WIDTH - 1)};
   endfunction;
      
   function logic [M4_FIXED_EXT_RANGE] real_to_ext_fixed (input logic [63:0] b);
      real_to_ext_fixed = {b[63], {1'b1, b[51:53-M4_FIXED_EXT_UNSIGNED_WIDTH]} >> (-(b[62:52] - 1023) + M4_FIXED_INT_WIDTH - 1)};
   endfunction;
      
\TLV
   
   |pipe
      @-1
         $reset = *areset;
      @0
         
         // It starts the computation
         // Must be asserted after the initial configuration (this is a hack)
         // Start will be high for more than 1 cycles
         $start_frame = *start;
         $valid_config_data_in = *s_tvalid;
         {$config_data_bogus[63:0],
          $config_max_depth[63:0],
          $config_img_size_y[63:0],
          $config_img_size_x[63:0],
          $config_data_pix_y[63:0],
          $config_data_pix_x[63:0],
          $config_data_min_y[63:0],
          $config_data_min_x[63:0]} = *s_tdata;
         
         `BOGUS_USE($config_data_bogus)
            
         // Initialization of a new frame. Generates a pulse signal
         $init_frame = >>1$start_frame & !>>2$start_frame;
         
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
         $MinX[M4_FIXED_RANGE] <= $reset ? '0 : $valid_config_data_in ? real_to_fixed($config_data_min_x) : $RETAIN;
         $MinY[M4_FIXED_RANGE] <= $reset ? '0 : $valid_config_data_in ? real_to_fixed($config_data_min_y) : $RETAIN;
         $PixX[M4_FIXED_EXT_RANGE] <= $reset ? '0 : $valid_config_data_in ? real_to_ext_fixed($config_data_pix_x) : $RETAIN;
         $PixY[M4_FIXED_EXT_RANGE] <= $reset ? '0 : $valid_config_data_in ? real_to_ext_fixed($config_data_pix_y) : $RETAIN;
         
         // The size of the image is dynamic
         $size_x[M4_FIXED_RANGE] = $reset ? '0 : $valid_config_data_in ? $config_img_size_x[31:0] : $RETAIN;
         $size_y[M4_FIXED_RANGE] = $reset ? '0 : $valid_config_data_in ? $config_img_size_y[31:0] : $RETAIN;      
         
         $max_depth[31:0] = $reset ? '0 : $valid_config_data_in ? $config_max_depth[31:0] : $RETAIN;   
         
      /M4_PE_HIER
         @0
            // Reset signal
            $reset = |pipe$reset;
            
         @1
            //
            // Screen render control
            //
            
            // Initialization of a new pixel
            $init_pix = ! $reset & (|pipe>>M4_PIPE_DEPTH$all_pix_done_pulse | |pipe$init_frame);
            
            // Cycle over pixels (vertical (outermost) and horizontal) and depth (innermost).
            // When each wraps, increment the next.
            $wrap_h = $pix_h >= |pipe$size_x - M4_PE_CNT;
            $wrap_v = $pix_v == |pipe$size_y - 1;
            
            <<M4_ITER$depth[15:0] =
               $reset       ? '0      :
               $init_pix         ? '0      :
                                   $depth + 1;
            <<M4_ITER$pix_h[31:0] =
               $reset       ? #pe :
               $init_pix         ? $wrap_h ? #pe :
                                             $pix_h + M4_PE_CNT :
                                   $RETAIN;
            <<M4_ITER$pix_v[31:0] =
               $reset                    ? '0 :
               ($init_pix && $wrap_h)         ? $wrap_v ? '0 :
                                                          $pix_v + 1 :
                                                $RETAIN;
            
            //
            // Map pixels to x,y coords
            //
            
            
         @2
            // The coordinates of the pixel we are working on.
            //**real $xx;
            // $xx = $init_pix ? $MinX + $PixX * $PixH : $RETAIN;  (in fixed-point)
            $xx_mul[M4_FIXED_EXT_UNSIGNED_RANGE] =
               (|pipe$PixX[M4_FIXED_EXT_UNSIGNED_RANGE] * `ZX($pix_h, M4_FIXED_EXT_UNSIGNED_WIDTH));
            $xx[M4_FIXED_RANGE] =
               $init_pix ? fixed_add(|pipe$MinX[M4_FIXED_RANGE],
                                 {1'b0, $xx_mul[M4_FIXED_UNSIGNED_RANGE]},
                                 1'b0)
                     : $RETAIN;
            //**real $yy;
            // $yy = $init_pix ? $MinY + $PixY * $PixV : $RETAIN;  (in fixed-point)
            $yy_mul[M4_FIXED_EXT_UNSIGNED_RANGE] =
               (|pipe$PixY[M4_FIXED_EXT_UNSIGNED_RANGE] * `ZX($pix_v, M4_FIXED_EXT_UNSIGNED_WIDTH));
            $yy[M4_FIXED_RANGE] =
               $init_pix ? fixed_add(|pipe$MinY[M4_FIXED_RANGE],
                                 {1'b0, $yy_mul[M4_FIXED_UNSIGNED_RANGE]},
                                 1'b0)
                     : $RETAIN;
            
         @3
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
            $aa_sq[M4_FIXED_RANGE] = fixed_mul($aa, $aa);
            $bb_sq[M4_FIXED_RANGE] = fixed_mul($bb, $bb);
            $aa_sq_plus_bb_sq[M4_FIXED_RANGE] = fixed_add($aa_sq, $bb_sq, 1'b0);
            $done_pix = $init_pix ? 1'b0 :
                >>1$done_pix      ? 1'b1 : //Hold value until init_pix is asserted
                // a*a + b*b
                (($aa_sq_plus_bb_sq[M4_FIXED_SIGN_BIT] == 1'b0) &&
                 ($aa_sq_plus_bb_sq[M4_FIXED_UNSIGNED_RANGE] >= real_to_fixed({1'b0, 1'b1, 9'b0, 1'b1, 52'b0}))
                ) || 
                // This term catches some overflow cases w/ the multiply and allows fewer int bits to be used.
                // |a| >= 2.0 || |b| >= 2.0
                (|{$aa[M4_FIXED_SIGN_BIT-1:M4_FIXED_SIGN_BIT-M4_FIXED_INT_WIDTH+1],
                   $bb[M4_FIXED_SIGN_BIT-1:M4_FIXED_SIGN_BIT-M4_FIXED_INT_WIDTH+1]}
                ) || 
                ($depth == |pipe$max_depth);
            $not_done = ! $done_pix;
            
            //?$not_done
            $aa_sq_minus_bb_sq[M4_FIXED_RANGE] = fixed_add($aa_sq, $bb_sq, 1'b1);
            <<M4_ITER$aa[M4_FIXED_RANGE] = $init_pix ? $xx : fixed_add($aa_sq_minus_bb_sq, $xx, 1'b0);
            $aa_times_bb[M4_FIXED_RANGE] = fixed_mul($aa, $bb);
            $aa_times_bb_times_2[M4_FIXED_RANGE] = {$aa_times_bb[M4_FIXED_SIGN_BIT], $aa_times_bb[M4_FIXED_UNSIGNED_RANGE] << 1};
            <<M4_ITER$bb[M4_FIXED_RANGE] = $init_pix ? $yy : fixed_add($aa_times_bb_times_2, $yy, 1'b0);
            
            $done_pix_pulse = $done_pix & ! >>1$done_pix;
            $depth_out[7:0] = $done_pix_pulse ? $depth[7:0] : $RETAIN;
      @3   
         *m_tdata = /pe[*]$depth_out;
         $all_pix_done = $reset ? '0 : & /pe[*]$done_pix;
         $all_pix_done_pulse = $all_pix_done & ! >>1$all_pix_done;
         
         *m_tvalid = $all_pix_done_pulse;
         $done_frame = $reset ? '0 : $all_pix_done_pulse & /pe[*]$wrap_h & /pe[*]$wrap_v;
         
         *done = $done_frame;

\SV
   endmodule
