// integr_logic.v
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


module integr_logic(
    CLK,
    RESET,
    wren,
    Size_Dest_q1,        
    wraddrs,     
    operatr_q2,
    oprndA,
    oprndB,
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
    rdenA,
    Size_SrcA_q1,
    rdaddrsA,    
    operatrA_q0,
    rddataA,
    rdenB,
    Size_SrcB_q1,
    rdaddrsB,    
    operatrB_q0,
    rddataB,
    ready_q1
    );

input         CLK;
input         RESET;
input         wren;
input  [1:0]  Size_Dest_q1;
input  [5:0]  wraddrs;
input  [4:0]  operatr_q2;
input  [63:0] oprndA;
input  [63:0] oprndB;
input         tr0_C;
input         tr0_V;
input         tr0_N;
input         tr0_Z;
input         tr1_C;
input         tr1_V;
input         tr1_N;
input         tr1_Z;
input         tr2_C;
input         tr2_V;
input         tr2_N;
input         tr2_Z;
input         tr3_C;
input         tr3_V;
input         tr3_N;
input         tr3_Z;
input         rdenA;
input  [5:0]  rdaddrsA;
input  [1:0] Size_SrcA_q1;
input  [4:0]  operatrA_q0;
output [67:0] rddataA;
input         rdenB;
input  [1:0] Size_SrcB_q1;
input  [5:0]  rdaddrsB;
input  [4:0]  operatrB_q0;
output [67:0] rddataB;
output        ready_q1;


parameter AND_  = 5'b1111_1;   // 0xDFF8- 0xDF80
parameter OR_   = 5'b1111_0;   // 0xDF78- 0xDF00
parameter XOR_  = 5'b1110_1;   // 0xDEF8- 0xDE80
parameter ADD_  = 5'b1110_0;   // 0xDE78- 0xDE00
parameter ADDC_ = 5'b1101_1;   // 0xDDF8- 0xDD80
parameter SUB_  = 5'b1101_0;   // 0xDD78- 0xDD00
parameter SUBB_ = 5'b1100_1;   // 0xDCF8- 0xDC80
parameter MUL_  = 5'b1100_0;   // 0xDC78- 0xDC00
parameter DIV_  = 5'b1011_1;   // 0xDBF8- 0xDB80
parameter SHFT_ = 5'b1011_0;   // 0xDB78- 0xDB00
parameter MAX_  = 5'b1010_1;   // 0xDAF8- 0xDA80
parameter MIN_  = 5'b1010_0;   // 0xDA78- 0xDA00
parameter SIN_  = 5'b1001_1;   // 0xD9F8- 0xD980
parameter COS_  = 5'b1001_0;   // 0xD978- 0xD900
parameter TAN_  = 5'b1000_1;   // 0xD8F8- 0xD880
parameter COT_  = 5'b1000_0;   // 0xD878- 0xD800
parameter ENDI_ = 5'b0111_1;   // 0xD7F8- 0xD780
parameter BUBL_ = 5'b0111_0;   // 0xD778- 0xD700
parameter BSET_ = 5'b0110_1;   // 0xD6F8- 0xD680
parameter BCLR_ = 5'b0110_0;   // 0xD678- 0xD600
                                                                
                                                                                                           
reg [67:0] rddataA;                                                                                      
reg [67:0] rddataB;
reg        readyA;
reg        readyB;
reg [5:0] operatrA_q1;
reg [5:0] operatrB_q1;

reg rdenA_q1;
reg rdenB_q1;

wire [67:0] rddataA_AND;
wire [67:0] rddataB_AND;
wire        ready_AND;

wire [67:0] rddataA_OR;
wire [67:0] rddataB_OR;
wire        ready_OR;

wire [67:0] rddataA_XOR;
wire [67:0] rddataB_XOR;
wire        ready_XOR;

wire [67:0] rddataA_ADD;
wire [67:0] rddataB_ADD;
wire        ready_ADD;

wire [67:0] rddataA_SUB;
wire [67:0] rddataB_SUB;
wire        ready_SUB;

wire [67:0] rddataA_MUL;
wire [67:0] rddataB_MUL;
wire        ready_MUL;

wire [67:0] rddataA_SHFT;
wire [67:0] rddataB_SHFT;
wire        ready_SHFT;

wire [67:0] rddataA_MAX;
wire [67:0] rddataB_MAX;
wire        ready_MAX;

wire [67:0] rddataA_MIN;
wire [67:0] rddataB_MIN;
wire        ready_MIN;

wire [35:0] SIN_rddataA;
wire [35:0] COS_rddataA;
wire [35:0] TAN_rddataA;
wire [35:0] COT_rddataA;

wire [35:0] SIN_rddataB;
wire [35:0] COS_rddataB;
wire [35:0] TAN_rddataB;
wire [35:0] COT_rddataB;

wire [67:0] rddataA_ENDI;
wire [67:0] rddataB_ENDI;
wire        ready_ENDI;

wire [67:0] rddataA_BSET;
wire [67:0] rddataB_BSET;
wire        ready_BSET;

wire [67:0] rddataA_BCLR;
wire [67:0] rddataB_BCLR;
wire        ready_BCLR;

wire SIN_ready;
wire COS_ready;
wire TAN_ready;
wire COT_ready;

wire ready_q1;
assign ready_q1 = readyA & readyB;                      

logic_SHIFT logic_SHIFT(
    .CLK      (CLK          ),
    .RESET    (RESET        ),
    .wren     (wren && (operatr_q2==SHFT_)),
    .wraddrs  (wraddrs[5:0]),      //includes thread#
    .oprndA   (oprndA       ),
    .oprndB   (oprndB       ),
    .tr0_C    (tr0_C        ),
    .tr0_V    (tr0_V        ),
    .tr0_N    (tr0_N        ),
    .tr0_Z    (tr0_Z        ),
    .tr1_C    (tr1_C        ),
    .tr1_V    (tr1_V        ),
    .tr1_N    (tr1_N        ),
    .tr1_Z    (tr1_Z        ),
    .tr2_C    (tr2_C        ),
    .tr2_V    (tr2_V        ),
    .tr2_N    (tr2_N        ),
    .tr2_Z    (tr2_Z        ),
    .tr3_C    (tr3_C        ),
    .tr3_V    (tr3_V        ),
    .tr3_N    (tr3_N        ),
    .tr3_Z    (tr3_Z        ),
    .rdenA    (rdenA && (operatrA_q0==SHFT_)),
    .rdaddrsA (rdaddrsA[5:0]),   
    .rddataA  (rddataA_SHFT  ),
    .rdenB    (rdenB && (operatrA_q0==SHFT_)),
    .rdaddrsB (rdaddrsB[5:0]),   
    .rddataB  (rddataB_SHFT  ),
    .ready    (ready_SHFT    )
    );

logic_AND logic_AND(
    .CLK      (CLK          ),
    .RESET    (RESET        ),
    .wren     (wren && (operatr_q2==AND_)),
    .wraddrs  (wraddrs[5:0] ),      //includes thread#
    .oprndA   (oprndA       ),
    .oprndB   (oprndB       ),
    .tr0_C    (tr0_C        ),
    .tr0_V    (tr0_V        ),
    .tr1_C    (tr1_C        ),
    .tr1_V    (tr1_V        ),
    .tr2_C    (tr2_C        ),
    .tr2_V    (tr2_V        ),
    .tr3_C    (tr3_C        ),
    .tr3_V    (tr3_V        ),
    .rdenA    (rdenA && (operatrA_q0==AND_)),
    .rdaddrsA (rdaddrsA[5:0]),   
    .rddataA  (rddataA_AND  ),
    .rdenB    (rdenB && (operatrB_q0==AND_)),
    .rdaddrsB (rdaddrsB[5:0]),   
    .rddataB  (rddataB_AND  ),
    .ready    (ready_AND    )
    );

logic_OR logic_OR(
    .CLK      (CLK          ),
    .RESET    (RESET        ),
    .wren     (wren && (operatr_q2==OR_)),
    .wraddrs  (wraddrs[5:0] ),      //includes thread#
    .oprndA   (oprndA       ),
    .oprndB   (oprndB       ),
    .tr0_C    (tr0_C        ),
    .tr0_V    (tr0_V        ),
    .tr1_C    (tr1_C        ),
    .tr1_V    (tr1_V        ),
    .tr2_C    (tr2_C        ),
    .tr2_V    (tr2_V        ),
    .tr3_C    (tr3_C        ),
    .tr3_V    (tr3_V        ),
    .rdenA    (rdenA && (operatrA_q0==OR_)),
    .rdaddrsA (rdaddrsA[5:0]),   
    .rddataA  (rddataA_OR  ),
    .rdenB    (rdenB && (operatrB_q0==OR_)),
    .rdaddrsB (rdaddrsB[5:0]),   
    .rddataB  (rddataB_OR  ),
    .ready    (ready_OR    )
    );

logic_XOR logic_XOR(
    .CLK      (CLK          ),
    .RESET    (RESET        ),
    .wren     (wren && (operatr_q2==XOR_)),
    .wraddrs  (wraddrs[5:0] ),      //includes thread#
    .oprndA   (oprndA       ),
    .oprndB   (oprndB       ),
    .tr0_C    (tr0_C        ),
    .tr0_V    (tr0_V        ),
    .tr1_C    (tr1_C        ),
    .tr1_V    (tr1_V        ),
    .tr2_C    (tr2_C        ),
    .tr2_V    (tr2_V        ),
    .tr3_C    (tr3_C        ),
    .tr3_V    (tr3_V        ),
    .rdenA    (rdenA && (operatrA_q0==XOR_)),
    .rdaddrsA (rdaddrsA[5:0]),   
    .rddataA  (rddataA_XOR  ),
    .rdenB    (rdenB && (operatrB_q0==XOR_)),
    .rdaddrsB (rdaddrsB[5:0]),   
    .rddataB  (rddataB_XOR  ),
    .ready    (ready_XOR    )
    );

integer_ADD integer_ADD(
    .CLK      (CLK          ),
    .RESET    (RESET        ),
    .wren     (wren && (operatr_q2==ADD_)),
    .wraddrs  (wraddrs[5:0] ),      //includes thread#
    .oprndA   (oprndA       ),
    .oprndB   (oprndB       ),
    .rdenA    (rdenA && (operatrA_q0==ADD_)),
    .rdaddrsA (rdaddrsA[5:0]),   
    .rddataA  (rddataA_ADD  ),
    .rdenB    (rdenB && (operatrB_q0==ADD_)),
    .rdaddrsB (rdaddrsB[5:0]),   
    .rddataB  (rddataB_ADD  ),
    .ready    (ready_ADD    )
    );

integer_SUB integer_SUB(
    .CLK      (CLK          ),
    .RESET    (RESET        ),
    .wren     (wren && (operatr_q2==SUB_)),
    .wraddrs  (wraddrs[5:0] ),      //includes thread#
    .oprndA   (oprndA       ),
    .oprndB   (oprndB       ),
    .rdenA    (rdenA && (operatrA_q0==SUB_)),
    .rdaddrsA (rdaddrsA[5:0]),   
    .rddataA  (rddataA_SUB  ),
    .rdenB    (rdenB && (operatrB_q0==SUB_)),
    .rdaddrsB (rdaddrsB[5:0]),   
    .rddataB  (rddataB_SUB  ),
    .ready    (ready_SUB    )
    );

integer_MUL integer_MUL(
    .CLK      (CLK          ),
    .RESET    (RESET        ),
    .wren     (wren && (operatr_q2==MUL_)),
    .wraddrs  (wraddrs[5:0] ),      //includes thread#
    .oprndA   (oprndA       ),
    .oprndB   (oprndB       ),
    .tr0_C    (tr0_C        ),
    .tr0_V    (tr0_V        ),
    .tr1_C    (tr1_C        ),
    .tr1_V    (tr1_V        ),
    .tr2_C    (tr2_C        ),
    .tr2_V    (tr2_V        ),
    .tr3_C    (tr3_C        ),
    .tr3_V    (tr3_V        ),
    .rdenA    (rdenA && (operatrA_q0==MUL_)),
    .rdaddrsA (rdaddrsA[5:0]),   
    .rddataA  (rddataA_MUL  ),
    .rdenB    (rdenB && (operatrB_q0==MUL_)),
    .rdaddrsB (rdaddrsB[5:0]),   
    .rddataB  (rddataB_MUL  ),
    .ready    (ready_MUL    )
    );

logic_ENDI logic_ENDI(
    .CLK      (CLK          ),
    .RESET    (RESET        ),
    .wren     (wren && (operatr_q2==ENDI_)),
    .Size_Dest_q1(Size_Dest_q1),
    .wraddrs  (wraddrs[5:0] ),      //includes thread#
    .oprndA   (oprndA       ),
    .oprndB   (oprndB       ),
    .tr0_C    (tr0_C        ),
    .tr0_V    (tr0_V        ),
    .tr1_C    (tr1_C        ),
    .tr1_V    (tr1_V        ),
    .tr2_C    (tr2_C        ),
    .tr2_V    (tr2_V        ),
    .tr3_C    (tr3_C        ),
    .tr3_V    (tr3_V        ),
    .rdenA    (rdenA && (operatrA_q0==ENDI_)),
    .Size_SrcA_q1(Size_SrcA_q1),
    .rdaddrsA (rdaddrsA[5:0]  ),   
    .rddataA  (rddataA_ENDI   ),
    .rdenB    (rdenB && (operatrB_q0==ENDI_)),
    .Size_SrcB_q1(Size_SrcB_q1),
    .rdaddrsB (rdaddrsB[5:0]  ),   
    .rddataB  (rddataB_ENDI   ),
    .ready    (ready_ENDI     )
    );

logic_BSET logic_BSET(
    .CLK      (CLK          ),
    .RESET    (RESET        ),
    .wren     (wren && (operatr_q2==BSET_)),
    .wraddrs  (wraddrs[5:0] ),      //includes thread#
    .oprndA   (oprndA       ),
    .oprndB   (oprndB       ),
    .tr0_C    (tr0_C        ),
    .tr0_V    (tr0_V        ),
    .tr1_C    (tr1_C        ),
    .tr1_V    (tr1_V        ),
    .tr2_C    (tr2_C        ),
    .tr2_V    (tr2_V        ),
    .tr3_C    (tr3_C        ),
    .tr3_V    (tr3_V        ),
    .rdenA    (rdenA && (operatrA_q0==BSET_)),
    .rdaddrsA (rdaddrsA[5:0]),   
    .rddataA  (rddataA_BSET  ),
    .rdenB    (rdenB && (operatrB_q0==BSET_)),
    .rdaddrsB (rdaddrsB[5:0]),   
    .rddataB  (rddataB_BSET  ),
    .ready    (ready_BSET    )
    );
    
logic_BCLR logic_BCLR(
    .CLK      (CLK          ),
    .RESET    (RESET        ),
    .wren     (wren && (operatr_q2==BCLR_)),
    .wraddrs  (wraddrs[5:0] ),      //includes thread#
    .oprndA   (oprndA       ),
    .oprndB   (oprndB       ),
    .tr0_C    (tr0_C        ),
    .tr0_V    (tr0_V        ),
    .tr1_C    (tr1_C        ),
    .tr1_V    (tr1_V        ),
    .tr2_C    (tr2_C        ),
    .tr2_V    (tr2_V        ),
    .tr3_C    (tr3_C        ),
    .tr3_V    (tr3_V        ),
    .rdenA    (rdenA && (operatrA_q0==BCLR_)),
    .rdaddrsA (rdaddrsA[5:0]),   
    .rddataA  (rddataA_BCLR  ),
    .rdenB    (rdenB && (operatrB_q0==BCLR_)),
    .rdaddrsB (rdaddrsB[5:0]),   
    .rddataB  (rddataB_BCLR  ),
    .ready    (ready_BCLR    )
    );
    
logic_MAX logic_MAX(
    .CLK      (CLK          ),
    .RESET    (RESET        ),
    .wren     (wren && (operatr_q2==MAX_)),
    .wraddrs  (wraddrs[5:0] ),      //includes thread#
    .oprndA   (oprndA       ),
    .oprndB   (oprndB       ),
    .tr0_C    (tr0_C        ),
    .tr0_V    (tr0_V        ),
    .tr1_C    (tr1_C        ),
    .tr1_V    (tr1_V        ),
    .tr2_C    (tr2_C        ),
    .tr2_V    (tr2_V        ),
    .tr3_C    (tr3_C        ),
    .tr3_V    (tr3_V        ),
    .rdenA    (rdenA && (operatrA_q0==MAX_)),
    .rdaddrsA (rdaddrsA[5:0]),   
    .rddataA  (rddataA_MAX  ),
    .rdenB    (rdenB && (operatrB_q0==MAX_)),
    .rdaddrsB (rdaddrsB[5:0]),   
    .rddataB  (rddataB_MAX  ),
    .ready    (ready_MAX    )
    );
    
logic_MIN logic_MIN(
    .CLK      (CLK          ),
    .RESET    (RESET        ),
    .wren     (wren && (operatr_q2==MIN_)),
    .wraddrs  (wraddrs[5:0] ),      //includes thread#
    .oprndA   (oprndA       ),
    .oprndB   (oprndB       ),
    .tr0_C    (tr0_C        ),
    .tr0_V    (tr0_V        ),
    .tr1_C    (tr1_C        ),
    .tr1_V    (tr1_V        ),
    .tr2_C    (tr2_C        ),
    .tr2_V    (tr2_V        ),
    .tr3_C    (tr3_C        ),
    .tr3_V    (tr3_V        ),
    .rdenA    (rdenA && (operatrA_q0==MIN_)),
    .rdaddrsA (rdaddrsA[5:0]),   
    .rddataA  (rddataA_MIN  ),
    .rdenB    (rdenB && (operatrB_q0==MIN_)),
    .rdaddrsB (rdaddrsB[5:0]),   
    .rddataB  (rddataB_MIN  ),
    .ready    (ready_MIN    )
    );
    
trig trig(                                   //SIN COS TAN COT with one degree resolution accepts 10-bit integer and delivers 32-bit float
    .CLK            (CLK          ),
    .RESET          (RESET        ),
    .SIN_wren       (wren && (operatr_q2==SIN_)),
    .COS_wren       (wren && (operatr_q2==COS_)),
    .TAN_wren       (wren && (operatr_q2==TAN_)),
    .COT_wren       (wren && (operatr_q2==COT_)),
    .wraddrs        (wraddrs[5:0] ),      //includes thread#
    .oprndA         (oprndA[9:0]  ),
    .tr0_C          (tr0_C        ),
    .tr0_V          (tr0_V        ),
    .tr0_N          (tr0_N        ),
    .tr0_Z          (tr0_Z        ),
    .tr1_C          (tr1_C        ),
    .tr1_V          (tr1_V        ),
    .tr1_N          (tr1_N        ),
    .tr1_Z          (tr1_Z        ),
    .tr2_C          (tr2_C        ),
    .tr2_V          (tr2_V        ),
    .tr2_N          (tr2_N        ),
    .tr2_Z          (tr2_Z        ),
    .tr3_C          (tr3_C        ),
    .tr3_V          (tr3_V        ),
    .tr3_N          (tr3_N        ),
    .tr3_Z          (tr3_Z        ),
    .SIN_rdenA      (rdenA && (operatrA_q0==SIN_)),
    .COS_rdenA      (rdenA && (operatrA_q0==COS_)),
    .TAN_rdenA      (rdenA && (operatrA_q0==TAN_)),
    .COT_rdenA      (rdenA && (operatrA_q0==COT_)),
    .rdaddrsA       (rdaddrsA[5:0]),   
    .SIN_rddataA    (SIN_rddataA  ),                                          
    .COS_rddataA    (COS_rddataA  ),                                          
    .TAN_rddataA    (TAN_rddataA  ),                                          
    .COT_rddataA    (COT_rddataA  ),                                          
    .SIN_rdenB      (rdenB && (operatrB_q0==SIN_)),                                    
    .COS_rdenB      (rdenB && (operatrB_q0==COS_)),                                    
    .TAN_rdenB      (rdenB && (operatrB_q0==TAN_)),                                    
    .COT_rdenB      (rdenB && (operatrB_q0==COT_)),                        
    .rdaddrsB       (rdaddrsB[5:0]),                             
    .SIN_rddataB    (SIN_rddataB  ),                                          
    .COS_rddataB    (COS_rddataB  ),                                          
    .TAN_rddataB    (TAN_rddataB  ),                                          
    .COT_rddataB    (COT_rddataB  ),
    .SIN_ready      (SIN_ready    ),
    .COS_ready      (COS_ready    ),
    .TAN_ready      (TAN_ready    ),
    .COT_ready      (COT_ready    )
    );

always @(*) begin
    if (rdenA_q1)
        casex(operatrA_q1)
            AND_  : begin
                        rddataA = rddataA_AND;
                        readyA = ready_AND;
                    end    
            OR_   : begin
                        rddataA = rddataA_OR;
                        readyA = ready_OR;
                    end    
            XOR_  : begin
                        rddataA = rddataA_XOR;
                        readyA = ready_XOR;
                    end    
            ADD_  : begin
                        rddataA = rddataA_ADD;
                        readyA = ready_ADD;
                    end    
 //           ADDC_ : begin
 //                       rddataA = rddataA_ADDC;
 //                       readyA = ready_ADDC;
 //                   end
            SUB_  : begin
                        rddataA = rddataA_SUB;
                        readyA = ready_SUB;
                    end
                        
//            SUBB_ : begin
//                        rddataA = rddataA_SUBB;
//                        readyA = ready_SUBB;
//                    end    
            MUL_  : begin
                        rddataA = rddataA_MUL;
                        readyA = ready_MUL;
                    end    
//            DIV_  : begin
//                        rddataA = rddataA_DIV;
//                        readyA = ready_DIV;
//                    end    
            SHFT_ : begin
                        rddataA = rddataA_SHFT;
                        readyA = ready_SHFT;
                    end
                    
             MAX_ : begin
                        rddataA = rddataA_MAX;
                        readyA = ready_MAX;
                    end
                     
             MIN_ : begin
                        rddataA = rddataA_MIN;
                        readyA = ready_MIN;
                    end

             SIN_ : begin
                        rddataA = {SIN_rddataA[35:32], 32'h0000_0000, SIN_rddataA[31:0]};
                        readyA = SIN_ready;
                    end 
                       
             COS_ : begin
                        rddataA = {COS_rddataA[35:32], 32'h0000_0000, COS_rddataA[31:0]};
                        readyA = COS_ready;
                    end 
                     
             TAN_ : begin
                        rddataA = {TAN_rddataA[35:32], 32'h0000_0000, TAN_rddataA[31:0]};
                        readyA = TAN_ready;
                    end 
                     
             COT_ : begin
                        rddataA = {COT_rddataA[35:32], 32'h0000_0000, COT_rddataA[31:0]};
                        readyA = COT_ready;
                    end
                     
            ENDI_ : begin
                        rddataA = rddataA_ENDI;
                        readyA = ready_ENDI;
                    end
                    
            BSET_ : begin
                        rddataA = rddataA_BSET;
                        readyA = ready_BSET;
                    end
                    
            BCLR_ : begin
                        rddataA = rddataA_BCLR;
                        readyA = ready_BCLR;
                    end
            
          default : begin
                        rddataA = 68'h0_0000_0000_0000_0000;
                        readyA = rdenB_q1;
                    end
        endcase                 
    else begin
        rddataA = 68'h0_0000_0000_0000_0000;
        readyA = rdenB_q1;
    end    
end

always @(*) begin
    if (rdenB_q1)
        casex(operatrB_q1)
            AND_  : begin
                        rddataB = rddataB_AND;
                        readyB = ready_AND;
                    end    
            OR_   : begin
                        rddataB = rddataB_OR;
                        readyB = ready_OR;
                    end    
            XOR_  : begin
                        rddataB = rddataB_XOR;
                        readyB = ready_XOR;
                    end    
            ADD_  : begin
                        rddataB = rddataB_ADD;
                        readyB = ready_ADD;
                    end    
//            ADDC_ : begin
//                        rddataB = rddataB_ADDC;
//                        readyB = ready_ADDC;
//                    end
            SUB_  : begin
                        rddataB = rddataB_SUB;
                        readyB = ready_SUB;
                    end
                        
//            SUBB_ : begin
//                        rddataB = rddataB_SUBB;
//                        readyB = ready_SUBB;
//                    end    
             MUL_ : begin
                        rddataB = rddataB_MUL;
                        readyB = ready_MUL;
                    end    
//            DIV_  : begin
//                        rddataB = rddataB_DIV;
//                        readyB = ready_DIV;
//                    end    
            SHFT_ : begin
                        rddataB = rddataB_SHFT;
                        readyB = ready_SHFT;
                    end  
                    
             MAX_ : begin
                        rddataB = rddataB_MAX;
                        readyB = ready_MAX;
                    end
                     
             MIN_ : begin
                        rddataB = rddataB_MIN;
                        readyB = ready_MIN;
                    end
                    
             SIN_ : begin
                        rddataB = {SIN_rddataB[35:32], 32'h0000_0000, SIN_rddataB[31:0]};
                        readyB = SIN_ready;
                    end 
                       
             COS_ : begin
                        rddataB = {COS_rddataB[35:32], 32'h0000_0000, COS_rddataB[31:0]};
                        readyB = COS_ready;
                    end 
                     
             TAN_ : begin
                        rddataB = {TAN_rddataB[35:32], 32'h0000_0000, TAN_rddataB[31:0]};
                        readyB = TAN_ready;
                    end 
                     
             COT_ : begin
                        rddataB = {COT_rddataB[35:32], 32'h0000_0000, COT_rddataB[31:0]};
                        readyB = COT_ready;
                    end 
                    
            ENDI_ : begin
                        rddataB = rddataB_ENDI;
                        readyB = ready_ENDI;
                    end

            BSET_ : begin
                        rddataB = rddataB_BSET;
                        readyB = ready_BSET;
                    end
                    
            BCLR_ : begin
                        rddataB = rddataB_BCLR;
                        readyB = ready_BCLR;
                    end
                    
          default : begin
                        rddataB = 68'h0_0000_0000_0000_0000;
                        readyB = rdenA_q1;
                    end 
        endcase                
    else begin
        rddataB = 68'h0_0000_0000_0000_0000;
        readyB = rdenA_q1;
    end    
end

always @(posedge CLK or posedge RESET) begin
    if (RESET) begin
        rdenA_q1 <= 1'b0;
        rdenB_q1 <= 1'b0;
        operatrA_q1 <= 5'b00000;
        operatrB_q1 <= 5'b00000;
    end
    else begin
        rdenA_q1 <= rdenA;    
        rdenB_q1 <= rdenB;
        operatrA_q1 <= operatrA_q0;
        operatrB_q1 <= operatrB_q0;
    end
end
    
endmodule
