 // integr_trig.v
 `timescale 1ns/100ps
 // Author:  Jerry D. Harthcock
 // Version:  1.0  Oct. 6, 2017
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



//SIN COS TAN COT with one degree resolution accepts 10-bit integer and delivers 32-bit float
module trig(                                   
    CLK,                   
    RESET,                 
    SIN_wren,              
    COS_wren,              
    TAN_wren,              
    COT_wren,              
    wraddrs,                             
    oprndA,                
    tr0_C,
    tr0_V,
    tr0_N,
    tr0_Z,
    tr1_C,
    tr1_V,
    tr1_N,
    tr1_Z,
    tr2_C,
    tr2_V,
    tr2_N,
    tr2_Z,
    tr3_C,
    tr3_V,
    tr3_N,
    tr3_Z,
    SIN_rdenA,             
    COS_rdenA,             
    TAN_rdenA,             
    COT_rdenA,             
    rdaddrsA,              
    SIN_rddataA,    
    COS_rddataA,    
    TAN_rddataA,    
    COT_rddataA,    
    SIN_rdenB,             
    COS_rdenB,             
    TAN_rdenB,             
    COT_rdenB,             
    rdaddrsB,              
    SIN_rddataB,
    COS_rddataB,
    TAN_rddataB,
    COT_rddataB,
    SIN_ready,    
    COS_ready,
    TAN_ready,
    COT_ready    
    );                                                             


input  CLK;
input  RESET;
input  SIN_wren;   
input  COS_wren;   
input  TAN_wren;   
input  COT_wren;   
input  [5:0]  wraddrs;    
input  [9:0]  oprndA;
input  tr0_C;
input  tr0_V;
input  tr0_N;
input  tr0_Z;
input  tr1_C;
input  tr1_V;
input  tr1_N;
input  tr1_Z;
input  tr2_C;
input  tr2_V;
input  tr2_N;
input  tr2_Z;
input  tr3_C;
input  tr3_V;
input  tr3_N;
input  tr3_Z;
input  SIN_rdenA;  
input  COS_rdenA;  
input  TAN_rdenA;  
input  COT_rdenA;  
input  [5:0]  rdaddrsA; 
output [35:0] SIN_rddataA;                                               
output [35:0] COS_rddataA;                                               
output [35:0] TAN_rddataA;                                               
output [35:0] COT_rddataA;                                               
input  SIN_rdenB;                                                        
input  COS_rdenB;                                                        
input  TAN_rdenB;                                                        
input  COT_rdenB;                                                        
input  [5:0]  rdaddrsB;                                                  
output [35:0] SIN_rddataB;                                               
output [35:0] COS_rddataB;                                               
output [35:0] TAN_rddataB;                                               
output [35:0] COT_rddataB;                                               
output SIN_ready;
output COS_ready;
output TAN_ready;
output COT_ready;
 
reg SIN_readyA;
reg SIN_readyB;
reg COS_readyA;
reg COS_readyB;
reg TAN_readyA;
reg TAN_readyB;
reg COT_readyA;
reg COT_readyB;
reg [63:0] SIN_semaphor;
reg [63:0] COS_semaphor;
reg [63:0] TAN_semaphor;
reg [63:0] COT_semaphor;
reg [9:0] delay0;
reg Cin;       //carry in
reg Vin;
reg Zin; 
reg Nin; 

wire SIN_ready;
wire COS_ready;
wire TAN_ready;
wire COT_ready;

wire [9:0] wraddrsq;

assign SIN_ready = SIN_readyA && SIN_readyB;  
assign COS_ready = COS_readyA && COS_readyB;  
assign TAN_ready = TAN_readyA && TAN_readyB;  
assign COT_ready = COT_readyA && COT_readyB;  

assign SIN_wrenq = delay0[9];
assign COS_wrenq = delay0[8];
assign TAN_wrenq = delay0[7];
assign COT_wrenq = delay0[6];
assign wraddrsq = delay0[5:0]; 

wire [35:0] SIN_rddataA;
wire [35:0] SIN_rddataB;
wire [35:0] COS_rddataA;
wire [35:0] COS_rddataB;
wire [35:0] TAN_rddataA;
wire [35:0] TAN_rddataB;
wire [35:0] COT_rddataA;
wire [35:0] COT_rddataB;

reg [9:0] TRIGin;

wire [31:0] SINout;                         
wire [31:0] COSout;                         
wire [31:0] TANout;                         
wire [31:0] COTout;                         

wire wren;
assign wren = SIN_wren || COS_wren || TAN_wren || COT_wren;

wire [1:0] thread_q2;
assign thread_q2 = wraddrs[5:4];


trigd trigd(
    .func_sel({SIN_wrenq, COS_wrenq, TAN_wrenq, COT_wrenq}),
    .x       (TRIGin ),
    .sin     (SINout ),
    .cos     (COSout ),
    .tan     (TANout ),
    .cot     (COTout )
    );               



RAM_func #(.ADDRS_WIDTH(6), .DATA_WIDTH(36))
    ram32_SIN(
    .CLK        (CLK      ),
    .wren       (SIN_wrenq),
    .wraddrs    (wraddrsq[5:0] ),
    .wrdata     ({Cin, Vin, Nin, Zin, SINout}),
    .rdenA      (SIN_rdenA),
    .rdaddrsA   (rdaddrsA ),
    .rddataA    (SIN_rddataA  ),                                  
    .rdenB      (SIN_rdenB),                                      
    .rdaddrsB   (rdaddrsB ),
    .rddataB    (SIN_rddataB  ));

RAM_func #(.ADDRS_WIDTH(6), .DATA_WIDTH(36))
    ram32_COS(
    .CLK        (CLK      ),
    .wren       (COS_wrenq),
    .wraddrs    (wraddrsq[5:0] ),
    .wrdata     ({Cin, Vin, Nin, Zin, COSout}),
    .rdenA      (COS_rdenA),
    .rdaddrsA   (rdaddrsA ),
    .rddataA    (COS_rddataA  ),
    .rdenB      (COS_rdenB),
    .rdaddrsB   (rdaddrsB ),
    .rddataB    (COS_rddataB  ));

RAM_func #(.ADDRS_WIDTH(6), .DATA_WIDTH(36))
    ram32_TAN(
    .CLK        (CLK      ),
    .wren       (TAN_wrenq),
    .wraddrs    (wraddrsq[5:0] ),
    .wrdata     ({Cin, Vin, Nin, Zin, TANout}),
    .rdenA      (TAN_rdenA),
    .rdaddrsA   (rdaddrsA ),
    .rddataA    (TAN_rddataA  ),
    .rdenB      (TAN_rdenB),
    .rdaddrsB   (rdaddrsB ),
    .rddataB    (TAN_rddataB  ));

RAM_func #(.ADDRS_WIDTH(6), .DATA_WIDTH(36))
    ram32_COT(
    .CLK        (CLK      ),
    .wren       (COT_wrenq),
    .wraddrs    (wraddrsq[5:0] ),
    .wrdata     ({Cin, Vin, Nin, Zin, COTout}),
    .rdenA      (COT_rdenA),
    .rdaddrsA   (rdaddrsA ),
    .rddataA    (COT_rddataA  ),
    .rdenB      (COT_rdenB),
    .rdaddrsB   (rdaddrsB ),
    .rddataB    (COT_rddataB  ));
    

always @(posedge CLK or posedge RESET) begin
    if (RESET) begin
        TRIGin <= 10'b00_0000_0000;
        Cin <= 1'b0; 
        Vin <= 1'b0; 
        Nin <= 1'b0; 
        Zin <= 1'b0;
     end
    else begin
        if (wren) begin
            TRIGin <= oprndA;
            case (thread_q2)
               2'b00 : begin
                        Cin <= tr0_C;
                        Vin <= tr0_V;
                        Nin <= tr0_N;
                        Zin <= tr0_Z;
                       end 
               2'b01 : begin
                        Cin <= tr1_C;
                        Vin <= tr1_V;
                        Nin <= tr1_N;
                        Zin <= tr1_Z;
                       end 
               2'b10 : begin
                        Cin <= tr2_C;
                        Vin <= tr2_V;
                        Nin <= tr2_N;
                        Zin <= tr2_Z;
                       end 
               2'b11 : begin
                        Cin <= tr3_C;
                        Vin <= tr3_V;
                        Nin <= tr3_N;
                        Zin <= tr3_Z;
                       end 
            endcase
        end    
        else begin
            TRIGin <= 10'b00_0000_0000;    
        end    
    end    
end            


always@(posedge CLK or posedge RESET) begin
    if (RESET) begin
        delay0  <= 10'h0_00;
    end    
    else begin                                                                            
        delay0  <= {SIN_wren, COS_wren, TAN_wren, COT_wren, wraddrs};                     
    end                                                                                   
end                                                                                       

always @(posedge CLK or posedge RESET) begin
    if (RESET) SIN_semaphor <= 64'hFFFF_FFFF_FFFF_FFFF;
    else begin
        if (SIN_wren) SIN_semaphor[wraddrs] <= 1'b0;
        if (SIN_wrenq) SIN_semaphor[wraddrsq] <= 1'b1;
    end
end

always @(posedge CLK or posedge RESET) begin
    if (RESET) COS_semaphor <= 64'hFFFF_FFFF_FFFF_FFFF;
    else begin
        if (COS_wren) COS_semaphor[wraddrs] <= 1'b0;
        if (COS_wrenq) COS_semaphor[wraddrsq] <= 1'b1;
    end
end

always @(posedge CLK or posedge RESET) begin
    if (RESET) TAN_semaphor <= 64'hFFFF_FFFF_FFFF_FFFF;
    else begin
        if (TAN_wren) TAN_semaphor[wraddrs] <= 1'b0;
        if (TAN_wrenq) TAN_semaphor[wraddrsq] <= 1'b1;
    end
end

always @(posedge CLK or posedge RESET) begin
    if (RESET) COT_semaphor <= 64'hFFFF_FFFF_FFFF_FFFF;
    else begin
        if (COT_wren) COT_semaphor[wraddrs] <= 1'b0;
        if (COT_wrenq) COT_semaphor[wraddrsq] <= 1'b1;
    end
end

always @(posedge CLK or posedge RESET) begin
    if (RESET) begin
        SIN_readyA <= 1'b0;
        SIN_readyB <= 1'b0;
    end  
    else begin
        if (SIN_rdenA) SIN_readyA <= (SIN_wrenq & (rdaddrsA == wraddrsq)) ? 1'b1 : SIN_semaphor[rdaddrsA];
        else SIN_readyA <= SIN_rdenB;         
        if (SIN_rdenB) SIN_readyB <= (SIN_wrenq & (rdaddrsB == wraddrsq)) ? 1'b1 : SIN_semaphor[rdaddrsB];
        else SIN_readyB <=SIN_rdenA;
    end   
end


always @(posedge CLK or posedge RESET) begin
    if (RESET) begin
        COS_readyA <= 1'b0;
        COS_readyB <= 1'b0;
    end  
    else begin
        if (COS_rdenA) COS_readyA <= (COS_wrenq & (rdaddrsA == wraddrsq)) ? 1'b1 : COS_semaphor[rdaddrsA];
        else COS_readyA <= COS_rdenB;         
        if (COS_rdenB) COS_readyB <= (COS_wrenq & (rdaddrsB == wraddrsq)) ? 1'b1 : COS_semaphor[rdaddrsB];
        else COS_readyB <=COS_rdenA;
    end   
end

always @(posedge CLK or posedge RESET) begin
    if (RESET) begin
        TAN_readyA <= 1'b0;
        TAN_readyB <= 1'b0;
    end  
    else begin
        if (TAN_rdenA) TAN_readyA <= (TAN_wrenq & (rdaddrsA == wraddrsq)) ? 1'b1 : TAN_semaphor[rdaddrsA];
        else TAN_readyA <= TAN_rdenB;         
        if (TAN_rdenB) TAN_readyB <= (TAN_wrenq & (rdaddrsB == wraddrsq)) ? 1'b1 : TAN_semaphor[rdaddrsB];
        else TAN_readyB <=TAN_rdenA;
    end   
end

always @(posedge CLK or posedge RESET) begin
    if (RESET) begin
        COT_readyA <= 1'b0;
        COT_readyB <= 1'b0;
    end  
    else begin
        if (COT_rdenA) COT_readyA <= (COT_wrenq & (rdaddrsA == wraddrsq)) ? 1'b1 : COT_semaphor[rdaddrsA];
        else COT_readyA <= COT_rdenB;         
        if (COT_rdenB) COT_readyB <= (COT_wrenq & (rdaddrsB == wraddrsq)) ? 1'b1 : COT_semaphor[rdaddrsB];
        else COT_readyB <=COT_rdenA;
    end   
end

endmodule
