 // STATUS_REG.v
 `timescale 1ns/100ps
 // Author:  Jerry D. Harthcock
 // Version:  1.00  Sept. 23, 2017
 // Copyright (C) 2017.  All rights reserved.
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                                 //
//                                 SYMPL 64-BIT GP-GPU Compute Engine                                              //
//                              Evaluation and Product Development License                                         //
//                                                                                                                 //
// Provided that you comply with all the terms and conditions set forth herein, Jerry D. Harthcock ("licensor"),   //
// the original author and exclusive copyright owner of these SYMPL 64-BIT ~ Verilog RTL IP cores and related      //
// development software ("this IP")  hereby grants recipient of this IP ("licensee"), a world-wide, paid-up,       //
// non-exclusi~ve license to implement this IP in Xilinx, Altera, MicroSemi or Lattice Semiconductor brand FPGAs   //
// only and used for the purposes of evaluation, education, and development of end products and related            //
// development tools only.  Furthermore, limited to the  the purposes of prototyping, evaluation, characterization //
// and testing of their implementation in a hard,  custom or semi-custom ASIC, any university or institution of    //
// higher education may have their implementation of  this IP produced for said limited purposes at any foundary   //
// of their choosing provided that such prototypes do  not ever wind up in commercial circulation with such        //
// license extending to said foundary and is in connection  with said academic pursuit and under the supervision   //
// of said university or institution of higher education.                                                          //
//                                                                                                                 //
// Any customization, modification, or derivative work of this IP must include an exact copy of this license       //
// and original copyright notice at the very top of each source file and derived netlist, and, in the case of      //
// binaries, a printed copy of this license and/or a text format copy in a separate file distributed with said     //
// netlists or binary files having the file name, "LICENSE.txt".  You, the licensee, also agree not to remove      //
// any copyright notices from any source file covered under this Evaluation and Product Development License.       //
//                                                                                                                 //
// LICENSOR DOES NOT WARRANT OR GUARANTEE THAT YOUR USE OF THIS IP WILL NOT INFRINGE THE RIGHTS OF OTHERS OR       //
// THAT IT IS SUITABLE OR FIT FOR ANY PURPOSE AND THAT YOU, THE LICENSEE, AGREE TO HOLD LICENSOR HARMLESS FROM     //
// ANY CLAIM BROUGHT BY YOU OR ANY THIRD PARTY FOR YOUR SUCH USE.                                                  //
//                                                                                                                 //
// Licensor reserves all his rights without prejudice, including, but in no way limited to, the right to change    //
// or modify the terms and conditions of this Evaluation and Product Development License anytime without notice    //
// of any kind to anyone. By using this IP for any purpose, you agree to all the terms and conditions set forth    //
// in this Evaluation and Product Development License.                                                             //
//                                                                                                                 //
// This Evaluation and Product Development License does not include the right to sell products that incorporate    //
// this IP, any IP derived from this IP.  If you would like to obtain such a license, please contact Licensor.     //
//                                                                                                                 //
// Licensor can be contacted at:  SYMPL.gpu@gmail.com                                                              //
//                                                                                                                 //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module STATUS_REG (
    CLK,
    RESET,
    wrcycl,           
    wren,
    thread_q2_sel,
    wrsrcAdataSext,        
    V_q2,
    N_q2, 
    C_q2, 
    Z_q2,
    V,
    N,
    C,
    Z,
    IRQ,
    done,
    invalid,
    alt_inv_handl,
    divby0,
    alt_div0_handl,
    overflow,
    alt_ovfl_handl,
    underflow,
    alt_unfl_handl,
    inexact,
    alt_nxact_handl,
    alt_del_nxact,
    alt_del_unfl,
    alt_del_ovfl,
    alt_del_div0,
    alt_del_inv,
    IRQ_IE,
    STATUS,
    STATUSq2,
    rd_float_q2_sel,
    rd_integr_q2_sel
);

input  CLK;
input  RESET;
input  wrcycl;           
input  wren;
input  thread_q2_sel;
input  [31:0] wrsrcAdataSext;        
input  V_q2;
input  N_q2; 
input  C_q2; 
input  Z_q2; 
output V;
output N;
output C;
output Z;
input  invalid;
input  divby0;
input  overflow;
input  underflow;
input  inexact;
input  IRQ;
output done;
output alt_del_nxact;
output alt_del_unfl; 
output alt_del_ovfl; 
output alt_del_div0; 
output alt_del_inv;  
output alt_inv_handl;
output alt_div0_handl;
output alt_ovfl_handl;
output alt_unfl_handl;
output alt_nxact_handl;
output IRQ_IE;
output [31:0] STATUS;
output [31:0] STATUSq2;
input rd_float_q2_sel;
input rd_integr_q2_sel;

parameter ST_ADDRS = 18'h0FF88;

reg IRQ_IE; 
reg alt_del_nxact; 
reg alt_del_unfl; 
reg alt_del_ovfl; 
reg alt_del_div0; 
reg alt_del_inv; 
reg alt_nxact_handl; 
reg alt_unfl_handl; 
reg alt_ovfl_handl; 
reg alt_div0_handl; 
reg alt_inv_handl;
reg invalid_flag;
reg divby0_flag;
reg overflow_flag;
reg underflow_flag;
reg inexact_flag;

reg done; 
reg V;
reg N;
reg C;
reg Z;


wire [31:0] STATUS;
wire [31:0] STATUSq2;

assign  STATUS = {  2'b10,
                    Z | V,                 // LTE (less than or equal)
                    Z & V,                 // LT  (less than)
                    5'b00000,
                    IRQ,                   // tr0 general-purpose interrupt request
                    IRQ_IE,                // tr0 general-purpose interrupt request interrupt enable
                    alt_del_nxact,         // 1 = alternate delayed handler, 0 = immediate
                    alt_del_unfl,          // 1 = alternate delayed handler, 0 = immediate
                    alt_del_ovfl,          // 1 = alternate delayed handler, 0 = immediate
                    alt_del_div0,          // 1 = alternate delayed handler, 0 = immediate
                    alt_del_inv,           // 1 = alternate delayed handler, 0 = immediate
                    alt_nxact_handl,       // enable interrupt for alternate inexact exception handler
                    alt_unfl_handl,        // enable interrupt for alternate underflow exception handler
                    alt_ovfl_handl,        // enable interrupt for alternate overflow exception handler
                    alt_div0_handl,        // enable interrupt for alternate divide by 0 exception handler
                    alt_inv_handl,         // enable interrupt for alternate invalid operation exception handler
                    inexact_flag,          // flag indicating inexact result
                    underflow_flag,        // flag indicating result underflow
                    overflow_flag,         // flag indicating result overflow
                    divby0_flag,           // flag indicating result is from divide by zero (divide or log)
                    invalid_flag,          // flag indicating invalid operation
                    done, 
                    1'b0,
                    V,                     // integer overflow flag
                    N,                     // negative (sign) flag for both float and integer
                    C,                     // integer arithmatic carry flag "<" less than if set, ">=" greater than or equal to if cleared
                    Z                      // zero flag for both integer and float "==" equal to if set, "!=" not equal to if cleared
                    };            


assign  STATUSq2 = {2'b10,
                    Z_q2 | V_q2,                // LTE (less than or equal)
                   ~Z_q2 & V_q2,                // LT  (less than)
                    5'b00000,
                    IRQ,                        // general-purpose interrupt request
                    (wren & wrcycl) ? wrsrcAdataSext[21] : IRQ_IE,
                    (wren & wrcycl) ? wrsrcAdataSext[20] : alt_del_nxact,                         
                    (wren & wrcycl) ? wrsrcAdataSext[19] : alt_del_unfl,                         
                    (wren & wrcycl) ? wrsrcAdataSext[18] : alt_del_ovfl,                         
                    (wren & wrcycl) ? wrsrcAdataSext[17] : alt_del_div0,                         
                    (wren & wrcycl) ? wrsrcAdataSext[16] : alt_del_inv,                         
                    (wren & wrcycl) ? wrsrcAdataSext[15] : alt_nxact_handl,
                    (wren & wrcycl) ? wrsrcAdataSext[14] : alt_unfl_handl,
                    (wren & wrcycl) ? wrsrcAdataSext[13] : alt_ovfl_handl,
                    (wren & wrcycl) ? wrsrcAdataSext[12] : alt_div0_handl,
                    (wren & wrcycl) ? wrsrcAdataSext[11] : alt_inv_handl,
                    (wren & wrcycl) ? wrsrcAdataSext[10] : inexact_flag,
                    (wren & wrcycl) ? wrsrcAdataSext[9]  : underflow_flag,
                    (wren & wrcycl) ? wrsrcAdataSext[8]  : overflow_flag,
                    (wren & wrcycl) ? wrsrcAdataSext[7]  : divby0_flag,
                    (wren & wrcycl) ? wrsrcAdataSext[6]  : invalid_flag,
                    (wren & wrcycl) ? wrsrcAdataSext[5]  : done, 
                    1'b0,                                                    
                    V_q2,                                                                                                        
                    N_q2,                                                                                                        
                    C_q2,                                                                                                        
                    Z_q2                                                                                                         
                    };                                                                                                           

 reg invalid_q2;  
 reg divby0_q2;   
 reg overflow_q2; 
 reg underflow_q2;

always@(posedge CLK or posedge RESET) begin
    if (RESET) begin
        IRQ_IE          <= 1'b0;     
        alt_del_nxact   <= 1'b0; 
        alt_del_unfl    <= 1'b0; 
        alt_del_ovfl    <= 1'b0; 
        alt_del_div0    <= 1'b0; 
        alt_del_inv     <= 1'b0; 
        alt_nxact_handl <= 1'b0;
        alt_unfl_handl  <= 1'b0; 
        alt_ovfl_handl  <= 1'b0; 
        alt_div0_handl  <= 1'b0; 
        alt_inv_handl   <= 1'b0;
        invalid_flag    <= 1'b0;
        divby0_flag     <= 1'b0;
        overflow_flag   <= 1'b0;
        underflow_flag  <= 1'b0;
        inexact_flag    <= 1'b0;
        
        done   <= 1'b1; 
        V      <= 1'b0;
        N      <= 1'b0;
        C      <= 1'b0;
        Z      <= 1'b1;
        
        invalid_q2   <= 1'b0;
        divby0_q2    <= 1'b0;
        overflow_q2  <= 1'b0;
        underflow_q2 <= 1'b1;
    end
    else begin
    
       invalid_q2   <= invalid;
       divby0_q2    <= divby0;
       overflow_q2  <= overflow;
       underflow_q2 <= underflow;
        
       if (invalid_q2 && ~alt_inv_handl && rd_float_q2_sel) invalid_flag <= 1'b1;                                                                    
       else if (wrcycl && thread_q2_sel && wren) invalid_flag <= wrsrcAdataSext[6];                                 

       if (divby0_q2 && ~alt_div0_handl && rd_float_q2_sel) divby0_flag <= 1'b1;
       else if ( wrcycl && thread_q2_sel && wren) divby0_flag <= wrsrcAdataSext[7];

       if (overflow_q2 && ~alt_ovfl_handl && rd_float_q2_sel) overflow_flag <= 1'b1;
       else if (wrcycl && thread_q2_sel && wren) overflow_flag <= wrsrcAdataSext[8];

       if (underflow_q2 && ~alt_unfl_handl && rd_float_q2_sel) underflow_flag <= 1'b1;
       else if (wrcycl && thread_q2_sel && wren) underflow_flag <= wrsrcAdataSext[9];

       if (wrcycl && thread_q2_sel && wren) inexact_flag <= wrsrcAdataSext[10];

       if (wren && wrcycl && thread_q2_sel) 
              {IRQ_IE, 
              alt_del_nxact, 
              alt_del_unfl, 
              alt_del_ovfl, 
              alt_del_div0, 
              alt_del_inv, 
              alt_nxact_handl, 
              alt_unfl_handl, 
              alt_ovfl_handl, 
              alt_div0_handl, 
              alt_inv_handl, 
              done, 
              V, 
              N, 
              C, 
              Z} <= {wrsrcAdataSext[21:11], wrsrcAdataSext[5], wrsrcAdataSext[3:0]};
               
       else if (wrcycl && thread_q2_sel && rd_integr_q2_sel)
              {V, N, C, Z} <= {V_q2, N_q2, C_q2, Z_q2};
    end
end    
endmodule
