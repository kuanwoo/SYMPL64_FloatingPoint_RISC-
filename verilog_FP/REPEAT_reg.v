 // REPEAT_reg.v
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

module REPEAT_reg (
    CLK,
    RESET,
    thread_q0_sel,
    Ind_Dest_q0, 
    Ind_SrcA_q0, 
    Ind_SrcB_q0, 
    Imod_Dest_q0,
    Imod_SrcA_q0,
    Imod_SrcB_q0,
    OPdest_q0,
    OPsrcB_q0,
    RPT_not_z,
    int_in_service,
    Dam_q0,
    AR0,
    AR1,
    AR2,
    AR3,
    AR4,
    AR5,
    AR6,
    REPEAT
);

input CLK;
input RESET;
input thread_q0_sel;
input Ind_Dest_q0; 
input Ind_SrcA_q0; 
input Ind_SrcB_q0; 
input Imod_Dest_q0;
input Imod_SrcA_q0;
input Imod_SrcB_q0;
input  [15:0] OPdest_q0;
input  [15:0] OPsrcB_q0;
output RPT_not_z;
input int_in_service;
input  [1:0]  Dam_q0;
input  [10:0] AR0;
input  [10:0] AR1;
input  [10:0] AR2;
input  [10:0] AR3;
input  [10:0] AR4;
input  [10:0] AR5;
input  [10:0] AR6;
output [10:0] REPEAT;

parameter REPEAT_addrs = 16'hFF80;
parameter AR0_addrs    = 16'hFFB0;
parameter AR1_addrs    = 16'hFFB8;
parameter AR2_addrs    = 16'hFFC0;
parameter AR3_addrs    = 16'hFFC8;
parameter AR4_addrs    = 16'hFFD0;
parameter AR5_addrs    = 16'hFFD8;
parameter AR6_addrs    = 16'hFFE0;

reg [10:0] REPEAT;

wire RPT_not_z;
assign RPT_not_z = |REPEAT; 

wire auto_post_modify_instr;
assign auto_post_modify_instr = thread_q0_sel && (~Dam_q0[1] || ~Dam_q0[0]) && RPT_not_z &&
                              ((Ind_Dest_q0 && ~Imod_Dest_q0) ||                                                        
                               (Ind_SrcA_q0 && ~Imod_SrcA_q0) ||                                                       
                               (Ind_SrcB_q0 && ~Imod_SrcB_q0));                                                        
                                                                                          
always @(posedge CLK or posedge RESET) begin
    if (RESET) begin
        REPEAT <= 11'h000;
    end
    else begin
        if ( ((Dam_q0[1:0]==2'b01) && (OPdest_q0==REPEAT_addrs)) && ~RPT_not_z && thread_q0_sel && ~Ind_Dest_q0) REPEAT[10:0] <= OPsrcB_q0[10:0]; //load REPEAT reg with 11-bit immediate during q0
        else if ((~|Dam_q0[1:0] && (OPdest_q0==REPEAT_addrs)) && ~RPT_not_z && thread_q0_sel && ~Ind_SrcA_q0 && ~Ind_Dest_q0) begin
            casex(OPsrcB_q0)
                AR0_addrs : REPEAT[10:0] <= AR0[10:0];  //load REPEAT reg with contents of specified ARn
                AR1_addrs : REPEAT[10:0] <= AR1[10:0];  //load REPEAT reg with contents of specified ARn
                AR2_addrs : REPEAT[10:0] <= AR2[10:0];  //load REPEAT reg with contents of specified ARn
                AR3_addrs : REPEAT[10:0] <= AR3[10:0];  //load REPEAT reg with contents of specified ARn
                AR4_addrs : REPEAT[10:0] <= AR4[10:0];  //load REPEAT reg with contents of specified ARn
                AR5_addrs : REPEAT[10:0] <= AR5[10:0];  //load REPEAT reg with contents of specified ARn
                AR6_addrs : REPEAT[10:0] <= AR6[10:0];  //load REPEAT reg with contents of specified ARn
                  default : REPEAT[10:0] <= 10'h0_00;
            endcase
        end
        else if (auto_post_modify_instr && ~int_in_service) REPEAT[10:0] <= REPEAT[10:0] - 1'b1;  
    end
end        

endmodule    
    
    
