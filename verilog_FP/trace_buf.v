
 // trace_buffer.v
 `timescale 1ns/100ps
 // Author:  Jerry D. Harthcock
 // Version:  2.14  Sept. 24, 2017
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

module trace_buf (
    CLK,
    RESET,
    tr0_discont,
    tr1_discont,
    tr2_discont,
    tr3_discont,
    tr0_PC,
    tr1_PC,
    tr2_PC,
    tr3_PC,
    pc_q2,
    thread_q2,
    
    tr0_trace_reg0,
    tr0_trace_reg1,
    tr0_trace_reg2,
    tr0_trace_reg3,
    
    tr1_trace_reg0,
    tr1_trace_reg1,
    tr1_trace_reg2,
    tr1_trace_reg3,
    
    tr2_trace_reg0,
    tr2_trace_reg1,
    tr2_trace_reg2,
    tr2_trace_reg3,
    
    tr3_trace_reg0,
    tr3_trace_reg1,
    tr3_trace_reg2,
    tr3_trace_reg3
    );

input  CLK;
input  RESET;
input  tr0_discont;
input  tr1_discont;
input  tr2_discont;
input  tr3_discont;
input  [15:0] tr0_PC;
input  [15:0] tr1_PC;
input  [15:0] tr2_PC;
input  [15:0] tr3_PC;
input  [15:0] pc_q2;
input  [1:0] thread_q2;

output [31:0] tr0_trace_reg0;
output [31:0] tr0_trace_reg1;
output [31:0] tr0_trace_reg2;
output [31:0] tr0_trace_reg3;

output [31:0] tr1_trace_reg0;
output [31:0] tr1_trace_reg1;
output [31:0] tr1_trace_reg2;
output [31:0] tr1_trace_reg3;

output [31:0] tr2_trace_reg0;
output [31:0] tr2_trace_reg1;
output [31:0] tr2_trace_reg2;
output [31:0] tr2_trace_reg3;

output [31:0] tr3_trace_reg0;
output [31:0] tr3_trace_reg1;
output [31:0] tr3_trace_reg2;
output [31:0] tr3_trace_reg3;

reg [31:0] tr0_trace_reg0;
reg [31:0] tr0_trace_reg1;
reg [31:0] tr0_trace_reg2;
reg [31:0] tr0_trace_reg3;

reg [31:0] tr1_trace_reg0;
reg [31:0] tr1_trace_reg1;
reg [31:0] tr1_trace_reg2;
reg [31:0] tr1_trace_reg3;

reg [31:0] tr2_trace_reg0;
reg [31:0] tr2_trace_reg1;
reg [31:0] tr2_trace_reg2;
reg [31:0] tr2_trace_reg3;

reg [31:0] tr3_trace_reg0;
reg [31:0] tr3_trace_reg1;
reg [31:0] tr3_trace_reg2;
reg [31:0] tr3_trace_reg3;

reg [15:0] pc_q3;

reg tr0_discont_q3;
reg tr1_discont_q3;
reg tr2_discont_q3;
reg tr3_discont_q3;
                
always @(posedge CLK or posedge RESET) begin
    if (RESET) begin
        tr0_trace_reg0 <= 32'h0000_0000;
        tr0_trace_reg1 <= 32'h0000_0000;
        tr0_trace_reg2 <= 32'h0000_0000;
        tr0_trace_reg3 <= 32'h0000_0000;

        tr1_trace_reg0 <= 32'h0000_0000;
        tr1_trace_reg1 <= 32'h0000_0000;
        tr1_trace_reg2 <= 32'h0000_0000;
        tr1_trace_reg3 <= 32'h0000_0000;

        tr2_trace_reg0 <= 32'h0000_0000;
        tr2_trace_reg1 <= 32'h0000_0000;
        tr2_trace_reg2 <= 32'h0000_0000;
        tr2_trace_reg3 <= 32'h0000_0000;

        tr3_trace_reg0 <= 32'h0000_0000;
        tr3_trace_reg1 <= 32'h0000_0000;
        tr3_trace_reg2 <= 32'h0000_0000;
        tr3_trace_reg3 <= 32'h0000_0000;
                
        pc_q3 <= 16'h0000;
        
        tr0_discont_q3 <= 1'b0;
        tr1_discont_q3 <= 1'b0; 
        tr2_discont_q3 <= 1'b0; 
        tr3_discont_q3 <= 1'b0; 
    end
    else begin
        tr0_discont_q3 <= tr0_discont;
        tr1_discont_q3 <= tr1_discont; 
        tr2_discont_q3 <= tr2_discont; 
        tr3_discont_q3 <= tr3_discont; 
        pc_q3 <= pc_q2;
        if (tr0_discont_q3) begin
            tr0_trace_reg0 <= {tr0_PC, pc_q3};
            tr0_trace_reg1 <= tr0_trace_reg0;
            tr0_trace_reg2 <= tr0_trace_reg1;
            tr0_trace_reg3 <= tr0_trace_reg2;
        end
        if (tr1_discont_q3) begin
            tr1_trace_reg0 <= {tr1_PC, pc_q3};
            tr1_trace_reg1 <= tr1_trace_reg0;
            tr1_trace_reg2 <= tr1_trace_reg1;
            tr1_trace_reg3 <= tr1_trace_reg2;
        end
        if (tr2_discont_q3) begin
            tr2_trace_reg0 <= {tr2_PC, pc_q3};
            tr2_trace_reg1 <= tr2_trace_reg0;
            tr2_trace_reg2 <= tr2_trace_reg1;
            tr2_trace_reg3 <= tr2_trace_reg2;
        end
        if (tr3_discont_q3) begin
            tr3_trace_reg0 <= {tr3_PC, pc_q3};
            tr3_trace_reg1 <= tr3_trace_reg0;
            tr3_trace_reg2 <= tr3_trace_reg1;
            tr3_trace_reg3 <= tr3_trace_reg2;
        end
    end
end

endmodule
