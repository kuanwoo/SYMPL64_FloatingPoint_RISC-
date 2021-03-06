 // integer_ADD.v
 `timescale 1ns/100ps
 // Author:  Jerry D. Harthcock
 // Version:  1.0  Oct. 3, 2017
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


  module integer_ADD(
      CLK,
      RESET,
      wren,
      wraddrs,     //includes thread#
      oprndA,
      oprndB,
      rdenA,
      rdaddrsA,    //includes thread#
      rddataA,
      rdenB,
      rdaddrsB,    //includes thread#
      rddataB,
      ready
      );

input CLK;
input RESET;
input wren;
input [5:0] wraddrs;
input [63:0] oprndA;
input [63:0] oprndB;
input rdenA;
input [5:0] rdaddrsA;
output [67:0] rddataA;
input rdenB;
input [5:0] rdaddrsB;
output [67:0] rddataB;
output ready;

reg readyA;
reg readyB;
reg [63:0] semaphor;
reg [6:0] delay0;
reg [63:0] oprndAq;
reg [63:0] oprndBq;

wire [63:0] ADD_result;
wire ready;
wire wrenq;
wire [5:0] wraddrsq;
wire [1:0] thread_q2;

wire [67:0] rddataA;
wire [67:0] rddataB;
wire z_flag;
wire n_flag;
wire c_flag;
wire v_flag;

assign ready = readyA & readyB;  
assign wrenq = delay0[6];
assign wraddrsq = delay0[5:0];  
assign z_flag = ~|ADD_result;
assign n_flag = ADD_result[63];

ADDER_64 adder_64(
    .TERM_A    (oprndAq   ), 
    .TERM_B    (oprndBq   ),
    .ADDER_OUT (ADD_result),      // adder out
    .CO        (c_flag    ),      // carry out
    .OVO       (v_flag    )      // overflow out
    ); 


RAM_func #(.ADDRS_WIDTH(6), .DATA_WIDTH(68))
    ram32_integer_ADD(
    .CLK        (CLK      ),
    .wren       (wrenq    ),
    .wraddrs    (wraddrsq ),
    .wrdata     ({c_flag, v_flag, n_flag, z_flag, ADD_result}),
    .rdenA      (rdenA    ),
    .rdaddrsA   (rdaddrsA ),
    .rddataA    (rddataA  ),
    .rdenB      (rdenB    ),
    .rdaddrsB   (rdaddrsB ),
    .rddataB    (rddataB  ));
    
always @(posedge CLK or posedge RESET) begin
    if (RESET) begin
        oprndAq <= 64'h0000_0000_0000_0000;
        oprndBq <= 64'h0000_0000_0000_0000;
     end
    else begin
        if (wren) begin
           oprndAq <= oprndA;           
           oprndBq <= oprndB;                      
        end    
        else begin
           oprndAq <= 64'h0000_0000_0000_0000;
           oprndBq <= 64'h0000_0000_0000_0000;
        end    
    end    
end            
    
always@(posedge CLK or posedge RESET) begin
    if (RESET) begin
        delay0  <= 7'h00;
    end    
    else begin
        delay0  <= {wren, wraddrs};
    end 
end        

always @(posedge CLK or posedge RESET) begin
    if (RESET) semaphor <= 64'hFFFF_FFFF_FFFF_FFFF;
    else begin
        if (wren) semaphor[wraddrs] <= 1'b0;
        if (wrenq) semaphor[wraddrsq] <= 1'b1;
    end
end

always @(posedge CLK or posedge RESET) begin
    if (RESET) begin
        readyA <= 1'b0;
        readyB <= 1'b0;
    end  
    else begin
        if (rdenA) readyA <= (wrenq & (rdaddrsA == wraddrsq)) ? 1'b1 : semaphor[rdaddrsA];
        else readyA <= rdenB;         
        if (rdenB) readyB <= (wrenq & (rdaddrsB == wraddrsq)) ? 1'b1 : semaphor[rdaddrsB];
        else readyB <=rdenA;
    end   
end

endmodule