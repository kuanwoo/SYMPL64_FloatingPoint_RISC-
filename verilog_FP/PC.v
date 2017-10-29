 // PC.v
 `timescale 1ns/100ps
 // Author:  Jerry D. Harthcock
 // Version:  2.14  Sept. 22, 2017
 // Copyright (C) 2014-2017.  All rights reserved.
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

module PROG_ADDRS(
    CLK,
    RESET,
    newthreadq_sel,
    thread_q2_sel,
    Ind_Dest_q2,
    Ind_SrcB_q2,
    Size_SrcB_q2,
    Sext_SrcB_q2,
    OPdest_q2,
    wrsrcAdata,
    wrsrcAdataSext,
    ld_vector,
    vector,
    rewind_PC,
    wrcycl,        
    discont_out,
    OPsrcB_q2,
    RPT_not_z,
    next_PC,
    PC,
    PC_COPY,
    break_q0,
    int_in_service
    );
 input         CLK;
 input         RESET;
 input         newthreadq_sel;
 input         thread_q2_sel; 
 input         Ind_Dest_q2;   //    ____
 input         Ind_SrcB_q2;   // --|
 input  [1:0]  Size_SrcB_q2;  // --| these bits (can) form part of the bit# for bitsel function
 input         Sext_SrcB_q2;  // --|___
 input  [15:0] OPdest_q2;
 input  [63:0] wrsrcAdata;
 input  [15:0] wrsrcAdataSext;
 input         ld_vector;
 input  [15:0] vector;
 input         rewind_PC;
 input         wrcycl; 
 output        discont_out;       
 input  [15:0] OPsrcB_q2;
 input         RPT_not_z;
 input  [15:0] next_PC;
 output [15:0] PC;
 output [15:0] PC_COPY;
 input         break_q0;
 input         int_in_service;

parameter     BTBS_ =  16'hFFA0;   // bit test and branch if set
parameter     BTBC_ =  16'hFF98;   // bit test and branch if clear
parameter     BRAL_ =  16'hFFF8;   // branch relative long
parameter     JMPA_ =  16'hFFA8;   // jump absolute long

parameter PC_COPY_ADDRS = 16'hFF90;

reg [15:0] PC;
reg [15:0] PC_COPY;
reg [15:0] pc_q2;
reg [15:0] pc_q1;

reg discont_out;


wire BTB_; 

wire [63:0] bitsel;
wire bitmatch;
wire [5:0] bit_number;
wire [63:0] not_wrsrcAdata;

assign not_wrsrcAdata = wrsrcAdata ^ 64'hFFFF_FFFF_FFFF_FFFF;

assign bit_number = {Sext_SrcB_q2, Size_SrcB_q2[1:0], Ind_SrcB_q2, OPsrcB_q2[15:14]};

assign BTB_  = ((OPdest_q2==BTBS_) || (OPdest_q2==BTBC_)) && ~Ind_Dest_q2 && wrcycl && thread_q2_sel;
assign bitsel = 1'b1<< bit_number;
assign bitmatch = |(bitsel & ((OPdest_q2==BTBC_) ? not_wrsrcAdata : wrsrcAdata)) && BTB_;

always @(*) begin
    if(bitmatch) discont_out = 1'b1;
    else if (~Ind_Dest_q2 && wrcycl && ((OPdest_q2==JMPA_) || (OPdest_q2==BRAL_)) && thread_q2_sel) discont_out = 1'b1;
    else if ((ld_vector || rewind_PC) && thread_q2_sel) discont_out = 1'b1;
    else discont_out = 1'b0;         
end            


always @(posedge CLK or posedge RESET) begin
    if (RESET) begin
        PC <= 16'h0100;
        PC_COPY <= 16'h0100;
        pc_q2 <= 16'h0000;
        pc_q1 <= 16'h0000;
    end
    else begin
        pc_q1 <= PC;
        pc_q2 <= pc_q1;
        
        if (ld_vector) begin
            PC[15:0]  <= vector[15:0];
            if (RPT_not_z) PC_COPY <= PC;
            else if (bitmatch) PC_COPY <= pc_q2 + {{2{OPsrcB_q2[13]}}, OPsrcB_q2[13:0]};
            else if ((OPdest_q2==JMPA_) && wrcycl && ~Ind_Dest_q2 && thread_q2_sel) PC_COPY[15:0] <= wrsrcAdataSext[15:0];  
            else PC_COPY <= (break_q0 && newthreadq_sel) ? pc_q2[15:0] : PC + 1'b1;
        end   
//        else if (break_q0 && newthreadq_sel) PC[15:0] <= pc_q2[15:0];             
        else if (break_q0 && newthreadq_sel);  // do nothing to PC or PC_COPY           
        else if (rewind_PC) begin
            PC[15:0] <= pc_q2[15:0];
            PC_COPY[15:0] <= pc_q2[15:0] + 1'b1; 
        end
        else if (bitmatch) begin            
            PC[15:0] <= pc_q2[15:0] + {{2{OPsrcB_q2[13]}}, OPsrcB_q2[13:0]};             
            PC_COPY[15:0] <= pc_q2[15:0] + 1'b1; 
        end         
        else if ((OPdest_q2==JMPA_) && thread_q2_sel && wrcycl && ~Ind_Dest_q2) begin
            PC[15:0] <= wrsrcAdataSext[15:0];                       
            PC_COPY[15:0] <= pc_q2[15:0] + 1'b1;  //don't copy PC if interrupt vector fetch
        end      
        else if (newthreadq_sel && wrcycl) PC[15:0] <= (RPT_not_z && ~int_in_service) ? PC[15:0] : next_PC[15:0]; 
    end
end    

endmodule   
