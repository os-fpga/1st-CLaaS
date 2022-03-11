\m4_TLV_version 1d: tl-x.org
\SV
`default_nettype none
module krnl_vadd_rtl_adder #(
  parameter integer C_DATA_WIDTH   = 128, // Data width of both input and output data
  // parameter integer C_OUT_DATA_WIDTH   = 128, // Data width of both input and output data check for 4096
  parameter integer C_NUM_CHANNELS = 2   // Number of input channels.  Only a value of 2 implemented.
)
(
  input wire                                         clk,
  input wire                                         areset,

  input wire  [C_NUM_CHANNELS-1:0]                   s_tvalid,
  input wire  [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0] s_tdata,
  output wire [C_NUM_CHANNELS-1:0]                   s_tready,

  output wire                                        m_tvalid,
  output wire [C_DATA_WIDTH-1:0]                     m_tdata,
  input  wire                                        m_tready

);

timeunit 1ps;
timeprecision 1ps;

localparam X_SIZE = 16;  // Note: There's a hardcoded X_SIZE in $display statement.
localparam N_SIZE = 2;
localparam ALPHA = 2;
localparam BETA = 2;
localparam SCORE_WIDTH = 8;

reg[1:0]     state;
wire     stall_;
reg[5:0] count; //change size
parameter S = 0, T1 = 1, T2 = 2;

assign stall_ = (~s_tvalid && state == T1) || ~m_tready;

always @ (posedge clk or posedge areset) begin
  if (areset) begin
    state <= S;
    count <= 6'd0;
  end else case (state)
    S:
      if (s_tvalid[0]) begin
        state <= T1;
        count <= 6'd0;
      end else begin
        state <= S;
        count <= 6'd0;
      end
    T1:
       begin
          count <= 6'd0;
          state <= s_tvalid[0] ? T2 : T1;
       end
    T2:
       begin
          count <= count + 6'd1;
          state <= (count == C_DATA_WIDTH/2-1)? T1 : T2;
       end
  endcase
end

\TLV
   m4_define(m4_n, 16)
   |default
      @1
         $reset = *state==2'd1 && *s_tvalid[0];
         //  $valid_s = (*state==0) && *s_tvalid[0];
         //  $valid_t = *cyc_cnt < 15;
         $nucleotides[2 * X_SIZE-1:0] = *s_tdata;//[2 * X_SIZE-1:0]; //change
         $nucleotidet[C_DATA_WIDTH-1:0] = (*state == T1) ? *s_tdata : $Nucleotidet;
         $Nucleotidet[C_DATA_WIDTH-1:0] <= $nucleotidet >> 2;
         $stall = *stall_;
         $Fout[SCORE_WIDTH-1:0] <= 0;
         $Vout[SCORE_WIDTH-1:0] <= 0;
         $Maxout[SCORE_WIDTH-1:0] <= 0;
         $val = (!$stall && *state!=2'd0);
         *m_tvalid = >>m4_eval(m4_n)$val;
         /xx[m4_eval(m4_n-1):0]
            // update genome
            //m4_def(xx, xx)
            //*m_tdata[xx*8+7:xx*8] = >>m4_eval(16-xx)$Maxout;
            $prev_vout[SCORE_WIDTH-1:0] = xx !=0 ? /xx[(xx + X_SIZE-1) % X_SIZE]$Vout : |default$Vout;
            $prev_fout[SCORE_WIDTH-1:0] = xx !=0 ? /xx[(xx + X_SIZE-1) % X_SIZE]$Fout : |default$Fout;
            $prev_maxout[SCORE_WIDTH-1:0] = xx !=0 ? /xx[(xx + X_SIZE-1) % X_SIZE]$Maxout : |default$Maxout;
            $prevt[N_SIZE-1:0] = xx !=0 ? /xx[(xx + X_SIZE-1) % X_SIZE]$Nucleotidet : |default$nucleotidet[1:0];
            $prevreset = xx !=0 ? /xx[(xx + X_SIZE-1) % X_SIZE]$Reset : |default$reset;
            
            $corr_prev_vout[SCORE_WIDTH-1:0] = $prev_vout > ALPHA ? $prev_vout : ALPHA;
            $corr_prev_fout[SCORE_WIDTH-1:0] = $prev_fout > BETA ? $prev_fout : BETA;
            $corr_Vout[SCORE_WIDTH-1:0] = $Vout > ALPHA ? $Vout : ALPHA;
            $corr_Eout[SCORE_WIDTH-1:0] = $Eout > BETA ? $Eout : BETA;

            $fout[SCORE_WIDTH-1:0] = $corr_prev_vout - ALPHA > $corr_prev_fout - BETA ? $corr_prev_vout - ALPHA : $corr_prev_fout - BETA;
            $eout[SCORE_WIDTH-1:0] = $corr_Vout - ALPHA > $corr_Eout - BETA ? $corr_Vout - ALPHA : $corr_Eout - BETA;

            $matchscore[SCORE_WIDTH-1:0] = (($Nucleotides == $Nucleotidet) ? $Vdiag + 3 : ($Vdiag < 3 ? 0 : $Vdiag - 3));
            $femax[SCORE_WIDTH-1:0] = $fout > $eout ? $fout : $eout;
            $vout[SCORE_WIDTH-1:0] = $femax > $matchscore ? $femax : $matchscore;
            $maxv[SCORE_WIDTH-1:0] = $Vout > $prev_maxout ? $Vout: $prev_maxout;
            $maxout[SCORE_WIDTH-1:0] = $maxv > $Maxout ? $maxv : $Maxout;
            $stall = !|default$stall;
            
            ?$stall
               $Reset <= $prevreset;
               $Nucleotides[N_SIZE-1:0] <= (*state==2'd0 && *s_tvalid[0]) ? |default$nucleotides[xx*2+1:xx*2] : $Nucleotides;
               $Nucleotidet[N_SIZE-1:0] <= $prevt;
               $Vdiag[SCORE_WIDTH-1:0] <= $prevreset ? 0 : $prev_vout;
               $Fout[SCORE_WIDTH-1:0] <= $prevreset ? 0 : $fout;
               $Eout[SCORE_WIDTH-1:0] <= $prevreset ? 0 : $eout;
               $Vout[SCORE_WIDTH-1:0] <= $prevreset ? 0 : $vout;
               $Maxout[SCORE_WIDTH-1:0] <= $prevreset ? 0 : $maxout;
         
         *m_tdata[7:0] = /xx[0]>>m4_eval(m4_n-1)$Vout;
         *m_tdata[15:8] = /xx[1]>>m4_eval(m4_n-2)$Vout;
         *m_tdata[23:16] = /xx[2]>>m4_eval(m4_n-3)$Vout;
         *m_tdata[31:24] = /xx[3]>>m4_eval(m4_n-4)$Vout;
         *m_tdata[39:32] = /xx[4]>>m4_eval(m4_n-5)$Vout;
         *m_tdata[47:40] = /xx[5]>>m4_eval(m4_n-6)$Vout;
         *m_tdata[55:48] = /xx[6]>>m4_eval(m4_n-7)$Vout;
         *m_tdata[63:56] = /xx[7]>>m4_eval(m4_n-8)$Vout;
         *m_tdata[71:64] = /xx[8]>>m4_eval(m4_n-9)$Vout;
         *m_tdata[79:72] = /xx[9]>>m4_eval(m4_n-10)$Vout;
         *m_tdata[87:80] = /xx[10]>>m4_eval(m4_n-11)$Vout;
         *m_tdata[95:88] = /xx[11]>>m4_eval(m4_n-12)$Vout;
         *m_tdata[103:96] = /xx[12]>>m4_eval(m4_n-13)$Vout;
         *m_tdata[111:104] = /xx[13]>>m4_eval(m4_n-14)$Vout;
         *m_tdata[119:112] = /xx[14]>>m4_eval(m4_n-15)$Vout;
         *m_tdata[127:120] = /xx[15]$Vout;



\SV
// Only assert s_tready when transfer has been accepted.  tready asserted on all channels simultaneously
assign s_tready = ~stall_;

endmodule : krnl_vadd_rtl_adder

`default_nettype wire


