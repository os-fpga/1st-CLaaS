\m4_TLV_version 1d: tl-x.org

\SV
   m4_include_url(['https://raw.githubusercontent.com/stevehoover/tlv_flow_lib/master/fundamentals_lib.tlv'])
   `define NUM_SIZE 3
   `define NUM_BUFFERS 2
   `define REG_FILE_SIZE 16
   `define REG_WIDTH 32
   `define NUM_ROWS 3
   `define NUM_COLS 3

\TLV mac($_in_aa1, $_in_aa2, $_in_aa3, $_in_bb1, $_in_bb2, $_in_bb3, $_out_mac)
   $prod_aa1bb1[(2 * `NUM_SIZE)-1 : 0] = $_in_aa1 * $_in_bb1;
   $prod_aa2bb2[(2 * `NUM_SIZE)-1 : 0] = $_in_aa2 * $_in_bb2;
   $prod_aa3bb3[(2 * `NUM_SIZE)-1 : 0] = $_in_aa3 * $_in_bb3;
   
   $_out_mac[(2 * `NUM_SIZE) : 0] = $prod_aa1bb1 + $prod_aa2bb2 + $prod_aa3bb3;
   
\TLV matrix_mult()
   |mult
      @0
         $reset = *reset;
         $cyc_cntr[31:0] = $reset ? 0 : >>1$cyc_cntr + 1;
         // One matrix's info per packet
         // So everytime in_avail goes up, we increase the matrix_id
         $matrix_id[1:0] = $reset ? 0 :
                                  ($in_avail) ? (>>1$matrix_id + 1) :
                                  $RETAIN;
         
         $in_ready = (>>1$in_avail || >>1$matrix_id == 2) ? 0 : 1;
         
      /buffers[`NUM_BUFFERS - 1 : 0]
         /reg_file[`REG_FILE_SIZE - 1:0]
            @0
               $reg[`REG_WIDTH - 1:0] = (|mult$in_avail && (#buffers == (|mult$matrix_id - 1))) ? |mult$in_data[((#reg_file * `REG_WIDTH) + (`REG_WIDTH - 1)) : (#reg_file * `REG_WIDTH)] : $RETAIN;
         
      /mat_r[`NUM_ROWS - 1 : 0]
         /mat_c[`NUM_COLS - 1 : 0]
            @0
               $index[3:0] = (#mat_r * `NUM_ROWS) + #mat_c;
            @1
               $aa[`NUM_SIZE - 1 : 0] = (|mult$in_avail && |mult$matrix_id == 1) ? |mult/buffers[0]/reg_file[$index]$reg[`NUM_SIZE-1:0] : $RETAIN;
                          // |mult$reset ? $rand_val_aa[`NUM_SIZE - 1:0] : $RETAIN;
               
               $bb[`NUM_SIZE - 1 : 0] = (|mult$in_avail && |mult$matrix_id == 2) ? |mult/buffers[1]/reg_file[$index]$reg[`NUM_SIZE-1:0] : $RETAIN;
                          //|mult$reset ? $rand_val_bb[`NUM_SIZE - 1:0] : $RETAIN;
               
            @3
               // The size for $cc should come from a `define or something -- but making it 8bits here for ease of use
               $cc[7 : 0] = |mult$reset ? 0 : (|mult$load_done && #mat_r == |mult$row_ctr && #mat_c == |mult$col_ctr) ? |mult$mac_out : $RETAIN;
               
      @1
         $load_done = $reset ? 0 :
                               ($matrix_id == 2) ? 1 :
                               $RETAIN;
         
         $row_ctr[1:0] = $reset ? 0 :
                                 (>>1$col_ctr == `NUM_COLS - 1 && >>1$load_done) ? >>1$row_ctr + 1 :
                                 $RETAIN;
         $col_ctr[1:0] = $reset ? 0 :
                                  (>>1$col_ctr == `NUM_COLS - 1 && >>1$load_done) ? 0 :
                                  (>>1$load_done) ? >>1$col_ctr + 1 :
                                  $RETAIN;
         
         $mult_done = $reset ? 0 :
                                 (>>1$row_ctr == `NUM_ROWS) ? 1 :
                                 $RETAIN;
      @2
         ?$load_done
            m4+mac(/mat_r[$row_ctr]/mat_c[0]$aa, /mat_r[$row_ctr]/mat_c[1]$aa, /mat_r[$row_ctr]/mat_c[2]$aa,
                   /mat_r[0]/mat_c[$col_ctr]$bb, /mat_r[1]/mat_c[$col_ctr]$bb, /mat_r[2]/mat_c[$col_ctr]$bb,
                   $mac_out);
            
      @3
         $out_avail = $mult_done;
         
         $out_data[511:0] = $mult_done ?
                             {/mat_r[2]/mat_c[2]$cc, /mat_r[2]/mat_c[1]$cc, /mat_r[2]/mat_c[0]$cc,
                              /mat_r[1]/mat_c[2]$cc, /mat_r[1]/mat_c[1]$cc, /mat_r[1]/mat_c[0]$cc,
                              /mat_r[0]/mat_c[2]$cc, /mat_r[0]/mat_c[1]$cc, /mat_r[0]/mat_c[0]$cc } : 0;
      


   
   
\SV



   // Default Makerchip TL-Verilog Code Template
   
   // Macro providing required top-level module definition, random
   // stimulus support, and Verilator config.
    m4_makerchip_module   // (Expanded in Nav-TLV pane.)

\TLV
   |mult
      @0
         $in_avail = $reset ? 0 : ($cyc_cntr % 20 == 0) ? 1 : 0;
         $in_data[511:0] = ($in_avail && $matrix_id == 1) ? {32'h7, 32'h3, 32'h1, 32'h1, 32'h0, 32'h6, 32'h5, 32'h5, 32'h3} :
                           ($in_avail && $matrix_id == 2) ? {32'h7, 32'h5, 32'h1, 32'h4, 32'h7, 32'h5, 32'h7, 32'h7, 32'h1} :
                           0;
         
   m4+matrix_mult();
   
      
   // Assert these to end simulation (before Makerchip cycle limit).
   *passed = *cyc_cnt > 60; //(|mult>>2$row_ctr == 3) ? 1 : 0; //*cyc_cnt > 40;
   *failed = 1'b0;
\SV
   endmodule
