\m4_TLV_version 1d: tl-x.org
\SV

module SW #(
parameter integer C_M_AXI_ADDR_WIDTH       = 64 ,
  parameter integer C_M_AXI_DATA_WIDTH       = 512,
  parameter integer C_XFER_SIZE_WIDTH        = 32,
  parameter integer C_ADDER_BIT_WIDTH        = 32,
  parameter integer NUM_PE                  = 16,
  parameter integer SCORE_WIDTH = 20,
  parameter integer N_SIZE = 2,
  parameter integer ALPHA = 0,
  parameter integer BETA = 0,
)
(
   input wire                       clk,
   input wire                       reset,
  // Genome S
  input wire  [NUM_PE*N_SIZE - 1:0]                  S          ,
  input wire                                    S_valid         ,
  output wire                                   S_ready         ,
  

  // Genome T
  input wire  [N_SIZE-1:0]                             T               ,
  input wire                                    T_valid         ,  
  output wire                                   T_ready         ,
  input wire  [SCORE_WIDTH-1:0]                 score_last      ,

  // scores
  output wire [NUM_PE*SCORE_WIDTH - 1:0]        output_scores   ,
  output wire                                   valid           ,
  input  wire                                   stall           ,
);
   
   // Macro providing required top-level module definition, random
   // stimulus support, and Verilator config.
   m4_makerchip_module   // (Expanded in Nav-TLV pane.)
		m4_define(m4_n, NUM_PE)
		
\TLV
   |default
      @1

!        $reset = *reset;

         $nucleotide_s[NUM_PE*N_SIZE - 1:0] = *S_valid ? *nucleotide_s : $nucleotide_s;
         $nucleotide_t[N_SIZE-1:0] = *T;
         $valid_T = *T_valid;
         $valid_S = *S_valid;


         *S_ready = 1;
         *T_ready = 1;


         $stall = $shift_s==1; // TODO : implement stall
         $score_F[SCORE_WIDTH-1:0] = 0;
         $score_V[SCORE_WIDTH-1:0] = 0;
     

         /xx[m4_eval(m4_n-1):0]
            // update genome
            /prev
               $ANY = xx !=0 ? /xx[(xx + NUM_PE-1) % NUM_PE]>>1$ANY : |default>>1$ANY;
            /prev_unit
               $ANY = xx !=0 ? /xx[(xx + NUM_PE-1) % NUM_PE]>>1$ANY : 0;
            $nucleotide_s[N_SIZE-1:0] = |default$nucleotide_s[xx];
            $nucleotide_t[N_SIZE-1:0] = !$valid_T? $nucleotide_t : /prev$nucleotide_t;
            $valid_T = /prev$valid_T;
            $vdiag[SCORE_WIDTH-1:0] = |default$reset ? 0 : /prev>>1$score_V + ($nucleotide_s == /prev$nucleotide_t ? |default$shift_t : 0); // check -1
            $score_F[SCORE_WIDTH-1:0] = |default$reset? 0 : /prev$score_V - ALPHA > /prev$score_F - BETA ? /prev$score_V - ALPHA : /prev$score_F - BETA;
            $score_E[SCORE_WIDTH-1:0] = |default$reset ? 0 :
                                        >>1$score_E-BETA > >>1$score_V-ALPHA ? >>1$score_E-BETA : >>1$score_V-ALPHA;
            $score_V[SCORE_WIDTH-1:0] = |default$reset ? 0 :
                                         ($vdiag > $score_F) ? ($vdiag > $score_E ? $vdiag : $score_E) :
                                         ($score_F > $score_E ? $score_F : $score_E);
            $max[SCORE_WIDTH-1:0] = |default$reset ? 0 :           // init
                                    (xx != 0 && /prev_unit$max > >>1$score_V) ? (/prev_unit$max > >>1$max ? /prev_unit$max : >>1$max) :  // stay alive
                                    (>>1$score_V > >>1$max ? >>1$score_V : >>1$max);                 // born
            *output_scores[xx] = >>(NUM_PE-xx)$max;
            *valid = >>(NUM_PE-xx)$valid_T;
   
\SV
   endmodule