   // ==========================
   // Mandelbrot Set Calculation
   // ==========================

   // To relax Verilator compiler checking:
   /* verilator lint_off UNOPTFLAT */
   /* verilator lint_on WIDTH */
   /* verilator lint_off REALCVT */  // !!! SandPiper DEBUGSIGS BUG.

   // Parameters:
   

   // Fixed numbers (sign, int, fraction)
   

  // Data width for the incoming configuration data
  

  // Interleaving computation cycles
  

   // Number of replicated Processing Elements
   

   // Constants and computed values:
   
     // Fixed values are < 8.0.
    
   
   
  //m4_makerchip_module
   // Zero extend to given width.
   `define ZX(val, width) {{1'b0{width-$bits(val)}}, val}

   module clk_gate (output logic gated_clk, input logic free_clk, func_en, pwr_en, gating_override);
      logic clk_en;
      logic latched_clk_en  /*verilator clock_enable*/;
      always_comb clk_en = func_en & (pwr_en | gating_override);
      always_latch if (~free_clk) latched_clk_en <= clk_en;
      // latched_clk_en <= (~free_clk) ? clk_en : latched_clk_en;
      always_comb gated_clk = latched_clk_en & free_clk;
   endmodule  
      
   module top #(
        parameter integer C_DATA_WIDTH = 512,
        parameter integer C_ADDER_BIT_WIDTH = 32
   )
   (
        input logic aclk,
        input logic areset,
        input logic start,
      
        input logic s_tvalid,
        input logic [C_DATA_WIDTH-1:0] s_tdata,
        
        output logic m_tvalid,
        output logic [C_DATA_WIDTH-1:0] m_tdata
    );

   logic clk;
   assign clk = aclk;
   
   function logic [32:0] fixed_mul (input logic [32:0] v1, v2);
      logic [3-1:0] drop_bits;
      logic [29-1:0] insignificant_bits;
      {fixed_mul[32], drop_bits, fixed_mul[31:0], insignificant_bits} =
         {v1[32] ^ v2[32], ({{32{1'b0}}, v1[31:0]} * {{32{1'b0}}, v2[31:0]})};
   endfunction;

   function logic [32:0] fixed_add (input logic [32:0] v1, v2, input logic sub);
      logic [32:0] binary_v2;
      binary_v2 = fixed_to_binary(v1) +
                  fixed_to_binary({v2[32] ^ sub, v2[32-1:0]});
      fixed_add = binary_to_fixed(binary_v2);
   endfunction;

   function logic [32:0] fixed_to_binary (input logic [32:0] f);
      fixed_to_binary =
         f[32]
            ? // Flip non-sign bits and add one. (Adding one is insignificant, so we save hardware and don't do it.)
              {1'b1, ~f[32-1:0] /* + {{32-1{1'b0}}, 1'b1} */}
            : f;
   endfunction;

   function logic [32:0] binary_to_fixed (input logic [32:0] b);
      // The conversion is symmetric.
      binary_to_fixed = fixed_to_binary(b);
   endfunction;
                                  
   function logic [32:0] real_to_fixed (input logic [63:0] b);
      real_to_fixed = {b[63], {1'b1, b[51:53-32]} >> (-(b[62:52] - 1023) + 3 - 1)};
   endfunction;

   logic run = 0;
   always @(posedge clk) begin
     if(start) 
         run <= 1;
     else if(PIPE_done_int_a0)
         run <= 0;
     else
         run <= run;
   end      

genvar pe;


// For $reset.
logic L0_reset_a0;

//
// Scope: |pipe
//

// For |pipe$MinX.
logic [32:0] PIPE_MinX_n1,
             PIPE_MinX_a0;

// For |pipe$MinY.
logic [32:0] PIPE_MinY_n1,
             PIPE_MinY_a0;

// For |pipe$PixX.
logic [32:0] PIPE_PixX_n1,
             PIPE_PixX_a0;

// For |pipe$PixY.
logic [32:0] PIPE_PixY_n1,
             PIPE_PixY_a0;

// For |pipe$all_done.
logic PIPE_all_done_a0;

// For |pipe$config_data_bogus.
logic [63:0] PIPE_config_data_bogus_a0;

// For |pipe$config_data_min_x.
logic [63:0] PIPE_config_data_min_x_a0;

// For |pipe$config_data_min_y.
logic [63:0] PIPE_config_data_min_y_a0;

// For |pipe$config_data_pix_x.
logic [63:0] PIPE_config_data_pix_x_a0;

// For |pipe$config_data_pix_y.
logic [63:0] PIPE_config_data_pix_y_a0;

// For |pipe$config_img_size_x.
logic [63:0] PIPE_config_img_size_x_a0;

// For |pipe$config_img_size_y.
logic [63:0] PIPE_config_img_size_y_a0;

// For |pipe$config_max_depth.
logic [63:0] PIPE_config_max_depth_a0;

// For |pipe$done_int.
logic PIPE_done_int_a0;

// For |pipe$max_depth.
logic [31:0] PIPE_max_depth_a0,
             PIPE_max_depth_a1;

// For |pipe$reset.
logic PIPE_reset_a0;

// For |pipe$size_x.
logic [32:0] PIPE_size_x_a0,
             PIPE_size_x_a1;

// For |pipe$size_y.
logic [32:0] PIPE_size_y_a0,
             PIPE_size_y_a1;

// For |pipe$start_frame.
logic PIPE_start_frame_a0;

// For |pipe$valid.
logic PIPE_valid_a0;

// For |pipe$valid_config_data_in.
logic PIPE_valid_config_data_in_a0;

//
// Scope: |pipe/pe[15:0]
//

// For |pipe/pe$aa.
logic [32:0] PIPE_Pe_aa_n1 [15:0] /* verilator lint_save */ /* verilator lint_off MULTIDRIVEN */,
             PIPE_Pe_aa_a0 [15:0] /* verilator lint_restore */;

// For |pipe/pe$aa_sq.
logic [32:0] PIPE_Pe_aa_sq_a0 [15:0];

// For |pipe/pe$aa_sq_minus_bb_sq.
logic [32:0] PIPE_Pe_aa_sq_minus_bb_sq_a0 [15:0];

// For |pipe/pe$aa_sq_plus_bb_sq.
logic [32:0] PIPE_Pe_aa_sq_plus_bb_sq_a0 [15:0];

// For |pipe/pe$aa_times_bb.
logic [32:0] PIPE_Pe_aa_times_bb_a0 [15:0];

// For |pipe/pe$aa_times_bb_times_2.
logic [32:0] PIPE_Pe_aa_times_bb_times_2_a0 [15:0];

// For |pipe/pe$bb.
logic [32:0] PIPE_Pe_bb_n1 [15:0] /* verilator lint_save */ /* verilator lint_off MULTIDRIVEN */,
             PIPE_Pe_bb_a0 [15:0] /* verilator lint_restore */;

// For |pipe/pe$bb_sq.
logic [32:0] PIPE_Pe_bb_sq_a0 [15:0];

// For |pipe/pe$depth.
logic [15:0] [31:0] PIPE_Pe_depth_n1,
                    PIPE_Pe_depth_a0;

// For |pipe/pe$done_pix.
logic [15:0] PIPE_Pe_done_pix_a0;

// For |pipe/pe$init_pix.
logic PIPE_Pe_init_pix_a0 [15:0];

// For |pipe/pe$not_done.
logic PIPE_Pe_not_done_a0 [15:0];

// For |pipe/pe$pix_h.
logic [31:0] PIPE_Pe_pix_h_n1 [15:0],
             PIPE_Pe_pix_h_a0 [15:0];

// For |pipe/pe$pix_v.
logic [31:0] PIPE_Pe_pix_v_n1 [15:0],
             PIPE_Pe_pix_v_a0 [15:0];

// For |pipe/pe$wrap_h.
logic [15:0] PIPE_Pe_wrap_h_a0;

// For |pipe/pe$wrap_v.
logic [15:0] PIPE_Pe_wrap_v_a0;

// For |pipe/pe$xx.
logic [32:0] PIPE_Pe_xx_a0 [15:0],
             PIPE_Pe_xx_a1 [15:0];

// For |pipe/pe$xx_mul.
logic [31:0] PIPE_Pe_xx_mul_a0 [15:0];

// For |pipe/pe$yy.
logic [32:0] PIPE_Pe_yy_a0 [15:0],
             PIPE_Pe_yy_a1 [15:0];

// For |pipe/pe$yy_mul.
logic [31:0] PIPE_Pe_yy_mul_a0 [15:0];

// Clock signals.
logic clkP_PIPE_Pe_not_done_a1 [15:0];


generate


   //
   // Scope: |pipe
   //

      // For $MinX.
      always_ff @(posedge clk) PIPE_MinX_a0[32:0] <= PIPE_MinX_n1[32:0];

      // For $MinY.
      always_ff @(posedge clk) PIPE_MinY_a0[32:0] <= PIPE_MinY_n1[32:0];

      // For $PixX.
      always_ff @(posedge clk) PIPE_PixX_a0[32:0] <= PIPE_PixX_n1[32:0];

      // For $PixY.
      always_ff @(posedge clk) PIPE_PixY_a0[32:0] <= PIPE_PixY_n1[32:0];

      // For $max_depth.
      always_ff @(posedge clk) PIPE_max_depth_a1[31:0] <= PIPE_max_depth_a0[31:0];

      // For $size_x.
      always_ff @(posedge clk) PIPE_size_x_a1[32:0] <= PIPE_size_x_a0[32:0];

      // For $size_y.
      always_ff @(posedge clk) PIPE_size_y_a1[32:0] <= PIPE_size_y_a0[32:0];


      //
      // Scope: /pe[15:0]
      //
      for (pe = 0; pe <= 15; pe++) begin : L1gen_PIPE_Pe
         // For $aa.
         always_ff @(posedge clkP_PIPE_Pe_not_done_a1[pe]) PIPE_Pe_aa_a0[pe][32:0] <= PIPE_Pe_aa_n1[pe][32:0];

         // For $bb.
         always_ff @(posedge clkP_PIPE_Pe_not_done_a1[pe]) PIPE_Pe_bb_a0[pe][32:0] <= PIPE_Pe_bb_n1[pe][32:0];

         // For $depth.
         always_ff @(posedge clk) PIPE_Pe_depth_a0[pe][31:0] <= PIPE_Pe_depth_n1[pe][31:0];

         // For $pix_h.
         always_ff @(posedge clk) PIPE_Pe_pix_h_a0[pe][31:0] <= PIPE_Pe_pix_h_n1[pe][31:0];

         // For $pix_v.
         always_ff @(posedge clk) PIPE_Pe_pix_v_a0[pe][31:0] <= PIPE_Pe_pix_v_n1[pe][31:0];

         // For $xx.
         always_ff @(posedge clk) PIPE_Pe_xx_a1[pe][32:0] <= PIPE_Pe_xx_a0[pe][32:0];

         // For $yy.
         always_ff @(posedge clk) PIPE_Pe_yy_a1[pe][32:0] <= PIPE_Pe_yy_a0[pe][32:0];

      end



endgenerate



//
// Gated clocks.
//

generate



   //
   // Scope: |pipe
   //


      //
      // Scope: /pe[15:0]
      //
      for (pe = 0; pe <= 15; pe++) begin : L1clk_PIPE_Pe
         clk_gate gen_clkP_PIPE_Pe_not_done_a1(clkP_PIPE_Pe_not_done_a1[pe], clk, 1'b1, PIPE_Pe_not_done_a0[pe], 1'b0);
      end



endgenerate


generate   // This is awkward, but we need to go into 'generate' context in the line that `includes the declarations file.

   assign L0_reset_a0 = areset;
   
   //_|pipe
      //_@0
         assign PIPE_reset_a0 = L0_reset_a0 || ~ run;
         
         // It starts the computation
         // Must be asserted after the initial configuration (this is a hack)
         // Start will be high for more than 1 cycles
         assign PIPE_start_frame_a0 = start;
         assign PIPE_valid_config_data_in_a0 = s_tvalid;
         assign {PIPE_config_data_bogus_a0[63:0],
          PIPE_config_max_depth_a0[63:0],
          PIPE_config_img_size_y_a0[63:0],
          PIPE_config_img_size_x_a0[63:0],
          PIPE_config_data_pix_y_a0[63:0],
          PIPE_config_data_pix_x_a0[63:0],
          PIPE_config_data_min_y_a0[63:0],
          PIPE_config_data_min_x_a0[63:0]} = s_tdata;
         
         
         
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
         assign PIPE_MinX_n1[32:0] = L0_reset_a0 ? '0 : PIPE_valid_config_data_in_a0 ? real_to_fixed(PIPE_config_data_min_x_a0) : PIPE_MinX_a0[32:0];
         assign PIPE_MinY_n1[32:0] = L0_reset_a0 ? '0 : PIPE_valid_config_data_in_a0 ? real_to_fixed(PIPE_config_data_min_y_a0) : PIPE_MinY_a0[32:0];
         assign PIPE_PixX_n1[32:0] = L0_reset_a0 ? '0 : PIPE_valid_config_data_in_a0 ? real_to_fixed(PIPE_config_data_pix_x_a0) : PIPE_PixX_a0[32:0];
         assign PIPE_PixY_n1[32:0] = L0_reset_a0 ? '0 : PIPE_valid_config_data_in_a0 ? real_to_fixed(PIPE_config_data_pix_y_a0) : PIPE_PixY_a0[32:0];
         
         // The size of the image is dynamic
         assign PIPE_size_x_a0[32:0] = L0_reset_a0 ? '0 : PIPE_valid_config_data_in_a0 ? PIPE_config_img_size_x_a0[31:0] : PIPE_size_x_a1[32:0];
         assign PIPE_size_y_a0[32:0] = L0_reset_a0 ? '0 : PIPE_valid_config_data_in_a0 ? PIPE_config_img_size_y_a0[31:0] : PIPE_size_y_a1[32:0];      
         
         assign PIPE_max_depth_a0[31:0] = L0_reset_a0 ? '0 : PIPE_valid_config_data_in_a0 ? PIPE_config_max_depth_a0[31:0] : PIPE_max_depth_a1[31:0];
         for (pe = 0; pe <= 15; pe++) begin : L1_PIPE_Pe //_/pe
            //
            // Screen render control
            //

            // Cycle over pixels (vertical (outermost) and horizontal) and depth (innermost).
            // When each wraps, increment the next.
            assign PIPE_Pe_wrap_h_a0[pe] = PIPE_Pe_pix_h_a0[pe] >= PIPE_size_x_a0 - 16;
            assign PIPE_Pe_wrap_v_a0[pe] = PIPE_Pe_pix_v_a0[pe] == PIPE_size_y_a0 - 1;
            assign PIPE_Pe_depth_n1[pe][31:0] =
               PIPE_reset_a0       ? '0      :
               PIPE_all_done_a0    ? '0      :
               PIPE_Pe_done_pix_a0[pe]         ? PIPE_Pe_depth_a0[pe][31:0] :
                                   PIPE_Pe_depth_a0[pe] + 1;
            assign PIPE_Pe_pix_h_n1[pe][31:0] =
               PIPE_reset_a0    ? pe :
               PIPE_all_done_a0 ? PIPE_Pe_wrap_h_a0[pe] ? pe :
                                          PIPE_Pe_pix_h_a0[pe] + 16 :
                                PIPE_Pe_pix_h_a0[pe][31:0];
            assign PIPE_Pe_pix_v_n1[pe][31:0] =
               PIPE_reset_a0                 ? '0 :
               (PIPE_all_done_a0 && PIPE_Pe_wrap_h_a0[pe]) ? PIPE_Pe_wrap_v_a0[pe] ? '0 :
                                                       PIPE_Pe_pix_v_a0[pe] + 1 :
                                             PIPE_Pe_pix_v_a0[pe][31:0];

            //
            // Map pixels to x,y coords
            //
            assign PIPE_Pe_init_pix_a0[pe] = PIPE_Pe_depth_a0[pe] == '0;  // 1st iteration -- initializes the pixel

            // The coordinates of the pixel we are working on.
            //**real $xx;
            // $xx = $init_pix ? $MinX + $PixX * $PixH : $RETAIN;  (in fixed-point)
            assign PIPE_Pe_xx_mul_a0[pe][31:0] =
               (PIPE_PixX_a0[31:0] * `ZX(PIPE_Pe_pix_h_a0[pe], 32));
            assign PIPE_Pe_xx_a0[pe][32:0] =
               PIPE_Pe_init_pix_a0[pe] ? fixed_add(PIPE_MinX_a0[32:0],
                                 {1'b0, PIPE_Pe_xx_mul_a0[pe]},
                                 1'b0)
                     : PIPE_Pe_xx_a1[pe][32:0];
            //**real $yy;
            // $yy = $init_pix ? $MinY + $PixY * $PixV : $RETAIN;  (in fixed-point)
            assign PIPE_Pe_yy_mul_a0[pe][31:0] =
               (PIPE_PixY_a0[31:0] * `ZX(PIPE_Pe_pix_v_a0[pe], 32));
            assign PIPE_Pe_yy_a0[pe][32:0] =
               PIPE_Pe_init_pix_a0[pe] ? fixed_add(PIPE_MinY_a0[32:0],
                                 {1'b0, PIPE_Pe_yy_mul_a0[pe]},
                                 1'b0)
                     : PIPE_Pe_yy_a1[pe][32:0];
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
            assign PIPE_Pe_aa_sq_a0[pe][32:0] = fixed_mul(PIPE_Pe_aa_a0[pe], PIPE_Pe_aa_a0[pe]);
            assign PIPE_Pe_bb_sq_a0[pe][32:0] = fixed_mul(PIPE_Pe_bb_a0[pe], PIPE_Pe_bb_a0[pe]);
            assign PIPE_Pe_aa_sq_plus_bb_sq_a0[pe][32:0] = fixed_add(PIPE_Pe_aa_sq_a0[pe], PIPE_Pe_bb_sq_a0[pe], 1'b0);
            assign PIPE_Pe_done_pix_a0[pe] = PIPE_Pe_init_pix_a0[pe] ? 1'b0 :
                // a*a + b*b
                ((PIPE_Pe_aa_sq_plus_bb_sq_a0[pe][32] == 1'b0) &&
                 (PIPE_Pe_aa_sq_plus_bb_sq_a0[pe][31:0] >= real_to_fixed({1'b0, 1'b1, 9'b0, 1'b1, 52'b0}))
                ) || 
                // This term catches some overflow cases w/ the multiply and allows fewer int bits to be used.
                // |a| >= 2.0 || |b| >= 2.0
                (|{PIPE_Pe_aa_a0[pe][32-1:32-3+1],
                   PIPE_Pe_bb_a0[pe][32-1:32-3+1]}
                ) || 
                (PIPE_Pe_depth_a0[pe] == PIPE_max_depth_a0);
            assign PIPE_Pe_not_done_a0[pe] = ! PIPE_Pe_done_pix_a0[pe];
            
            //_?$not_done
               //**real $Aa;
               assign PIPE_Pe_aa_sq_minus_bb_sq_a0[pe][32:0] = fixed_add(PIPE_Pe_aa_sq_a0[pe], PIPE_Pe_bb_sq_a0[pe], 1'b1);
               assign PIPE_Pe_aa_n1[pe][32:0] = PIPE_Pe_init_pix_a0[pe] ? PIPE_Pe_xx_a0[pe] : fixed_add(PIPE_Pe_aa_sq_minus_bb_sq_a0[pe], PIPE_Pe_xx_a0[pe], 1'b0);
               assign PIPE_Pe_aa_times_bb_a0[pe][32:0] = fixed_mul(PIPE_Pe_aa_a0[pe], PIPE_Pe_bb_a0[pe]);
               assign PIPE_Pe_aa_times_bb_times_2_a0[pe][32:0] = {PIPE_Pe_aa_times_bb_a0[pe][32], PIPE_Pe_aa_times_bb_a0[pe][31:0] << 1};
               //**real $Bb;
               assign PIPE_Pe_bb_n1[pe][32:0] = PIPE_Pe_init_pix_a0[pe] ? PIPE_Pe_yy_a0[pe] : fixed_add(PIPE_Pe_aa_times_bb_times_2_a0[pe], PIPE_Pe_yy_a0[pe], 1'b0); end
         assign m_tdata = PIPE_Pe_depth_a0;
         assign PIPE_valid_a0 = & PIPE_Pe_done_pix_a0;
         assign m_tvalid = & PIPE_Pe_done_pix_a0;
         assign PIPE_done_int_a0 = L0_reset_a0 ? '0 : PIPE_valid_a0 & PIPE_Pe_wrap_h_a0 & PIPE_Pe_wrap_v_a0;
         assign PIPE_all_done_a0 = L0_reset_a0 ? '0 : PIPE_valid_a0;

      endgenerate

//_\SV
   endmodule