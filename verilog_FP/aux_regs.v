 // aux_regs.v
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

module DATA_ADDRS(
    CLK,
    RESET,
    newthreadq_sel,
    thread_q2_sel,
    wrcycl,
    wrsrcAdataSext,
    Dam_q0,                   //data address mode   00= SrcA and SrcB direct/indirect, 01= SrcA direct/indirect and SrcB immediate,   
    Dam_q2,                //                    10= SrcA table-read and SrcB direct/indirect, 11= {SrcA, SrcB} 32-bit immediate
    Ind_Dest_q0,
    Ind_SrcA_q0,
    Ind_SrcB_q0,
    Imod_Dest_q2,
    Imod_SrcA_q0,
    Imod_SrcB_q0,
    OPdest_q0,
    OPdest_q2,
    OPsrcA_q0,
    OPsrcB_q0,
    OPsrc32_q0,              //for 17-bit up to 32-bit loads of ARs
    Ind_Dest_q2,
    Dest_addrs_q2,
    SrcA_addrs_q0,
    SrcB_addrs_q0,
    AR0,
    AR1,
    AR2,
    AR3,
    AR4,
    AR5,
    AR6,
    SP
    );

input         CLK;
input         RESET;
input         newthreadq_sel;
input         thread_q2_sel;
input         wrcycl;
input [17:0]  wrsrcAdataSext;
input [1:0]   Dam_q0;      
input [1:0]   Dam_q2;      
input         Ind_Dest_q0;
input         Ind_SrcA_q0;
input         Ind_SrcB_q0;
input         Imod_Dest_q2;
input         Imod_SrcA_q0;
input         Imod_SrcB_q0;
input [15:0]  OPdest_q0;
input [15:0]  OPdest_q2;
input [15:0]  OPsrcA_q0;
input [15:0]  OPsrcB_q0;
input [31:0]  OPsrc32_q0;
input         Ind_Dest_q2;
output [17:0] Dest_addrs_q2;
output [17:0] SrcA_addrs_q0;
output [17:0] SrcB_addrs_q0;
output [17:0] AR0;
output [17:0] AR1;
output [17:0] AR2;
output [17:0] AR3;
output [17:0] AR4;
output [17:0] AR5;
output [17:0] AR6;
output [17:0] SP;

parameter     ROM_ADDRS   = 18'b1111111xxxxxxxxxxx; //rom in this implementation is only 32k bytes (4k x 64), shared by all threads
parameter     RAM_ADDRS   = 18'b0000xxxxxxxxxxxxxx; //first 32k bytes (since data memory is byte-addressable and smallest RAM for this in Kintex 7 is 2k x 64 bits using two blocks next to each other
parameter     SP_ADDRS   = 18'h0FFE8;
parameter    AR6_ADDRS   = 18'h0FFE0;
parameter    AR5_ADDRS   = 18'h0FFD8;
parameter    AR4_ADDRS   = 18'h0FFD0;
parameter    AR3_ADDRS   = 18'h0FFC8;
parameter    AR2_ADDRS   = 18'h0FFC0;
parameter    AR1_ADDRS   = 18'h0FFB8;
parameter    AR0_ADDRS   = 18'h0FFB0;
parameter     PC_ADDRS   = 18'h0FFA8;
parameter      PC_COPY   = 18'h0FF90;
parameter     ST_ADDRS   = 18'h0FF88;
parameter LPCNT1_ADDRS   = 18'h0FF78;
parameter LPCNT0_ADDRS   = 18'h0FF70;
parameter  TIMER_ADDRS   = 18'h0FF68;
parameter   CREG_ADDRS   = 18'h0FF60;
parameter  CAPT3_ADDRS   = 18'h0FF58;
parameter  CAPT2_ADDRS   = 18'h0FF50;
parameter  CAPT1_ADDRS   = 18'h0FF48;
parameter  CAPT0_ADDRS   = 18'h0FF40;
parameter SCHED_ADDRS    = 18'h0FF38;
parameter SCHEDCMP_ADDRS = 18'h0FF30;
parameter    QOS_ADDRS   = 18'h0FF20;

reg [17:0] DEST_ind; 
reg [17:0] SRC_A_ind; 
reg [17:0] SRC_B_ind;

reg [17:0] AR0;
reg [17:0] AR1;
reg [17:0] AR2;
reg [17:0] AR3;
reg [17:0] AR4;
reg [17:0] AR5;
reg [17:0] AR6;
reg [17:0]  SP;

wire [2:0] DEST_ARn_sel;
wire [2:0] SRC_A_sel; 	
wire [2:0] SRC_B_sel; 

wire [17:0] Dest_addrs_q2;
wire [17:0] SrcA_addrs_q0;
wire [17:0] SrcB_addrs_q0;

wire table_read;      //direct read of program memory
	
assign DEST_ARn_sel[2:0] = OPdest_q2[2:0];
assign SRC_A_sel[2:0] 	 = OPsrcA_q0[2:0];
assign SRC_B_sel[2:0] 	 = OPsrcB_q0[2:0];

assign table_read = Dam_q0[0] & ~Dam_q0[1];

assign Dest_addrs_q2 = Ind_Dest_q2 ?  DEST_ind : {2'b00, OPdest_q2[15:0]};
//assign srcA = indir_mode_srcA ?  {14'h0000, SRC_A_ind} : {Imod_srcA ? OPsrc32[30:0] : {15'h0000, OPsrcB[15:0]};
assign SrcA_addrs_q0 = Ind_SrcA_q0 ?  SRC_A_ind : {2'b00, OPsrcA_q0[15:0]};
assign SrcB_addrs_q0 = Ind_SrcB_q0 ?  SRC_B_ind : {2'b00, OPsrcB_q0[15:0]};

always @(*) begin
     case (DEST_ARn_sel) 
     	3'b000 : DEST_ind = (Imod_Dest_q2 && Ind_Dest_q2) ? AR0[17:0] + {{6{OPdest_q2[15]}}, OPdest_q2[15:3]}        : AR0[17:0]; 
     	3'b001 : DEST_ind = (Imod_Dest_q2 && Ind_Dest_q2) ? AR1[17:0] + {{6{OPdest_q2[15]}}, OPdest_q2[15:3]}        : AR1[17:0]; 
     	3'b010 : DEST_ind = (Imod_Dest_q2 && Ind_Dest_q2) ? AR2[17:0] + {{6{OPdest_q2[15]}}, OPdest_q2[15:3]}        : AR2[17:0]; 
     	3'b011 : DEST_ind = (Imod_Dest_q2 && Ind_Dest_q2) ? AR3[17:0] + {{6{OPdest_q2[15]}}, OPdest_q2[15:3]}        : AR3[17:0];
     	3'b100 : DEST_ind = (Imod_Dest_q2 && Ind_Dest_q2) ? AR4[17:0] + {{6{OPdest_q2[15]}}, OPdest_q2[15:3]}        : AR4[17:0]; 
     	3'b101 : DEST_ind = (Imod_Dest_q2 && Ind_Dest_q2) ? AR5[17:0] + {{6{OPdest_q2[15]}}, OPdest_q2[15:3]}        : AR5[17:0]; 
     	3'b110 : DEST_ind = (Imod_Dest_q2 && Ind_Dest_q2) ? AR6[17:0] + {{6{OPdest_q2[15]}}, OPdest_q2[15:3]}        : AR6[17:0]; 
     	3'b111 : DEST_ind = (Imod_Dest_q2 && Ind_Dest_q2) ?  SP[17:0] + {{6{OPdest_q2[15]}}, OPdest_q2[15:3]} - 1'b1 :  SP[17:0] - 1'b1; 
     endcase
end

always @(*) begin
   case (SRC_A_sel) 
   	   3'b000 : SRC_A_ind = (Imod_SrcA_q0 && Ind_SrcA_q0) ? AR0[17:0] + {{6{OPsrcA_q0[15]}}, OPsrcA_q0[15:3]}        : AR0[17:0]; 
   	   3'b001 : SRC_A_ind = (Imod_SrcA_q0 && Ind_SrcA_q0) ? AR1[17:0] + {{6{OPsrcA_q0[15]}}, OPsrcA_q0[15:3]}        : AR1[17:0]; 
   	   3'b010 : SRC_A_ind = (Imod_SrcA_q0 && Ind_SrcA_q0) ? AR2[17:0] + {{6{OPsrcA_q0[15]}}, OPsrcA_q0[15:3]}        : AR2[17:0]; 
   	   3'b011 : SRC_A_ind = (Imod_SrcA_q0 && Ind_SrcA_q0) ? AR3[17:0] + {{6{OPsrcA_q0[15]}}, OPsrcA_q0[15:3]}        : AR3[17:0];
   	   3'b100 : SRC_A_ind = (Imod_SrcA_q0 && Ind_SrcA_q0) ? AR4[17:0] + {{6{OPsrcA_q0[15]}}, OPsrcA_q0[15:3]}        : AR4[17:0]; 
   	   3'b101 : SRC_A_ind = (Imod_SrcA_q0 && Ind_SrcA_q0) ? AR5[17:0] + {{6{OPsrcA_q0[15]}}, OPsrcA_q0[15:3]}        : AR5[17:0]; 
   	   3'b110 : SRC_A_ind = (Imod_SrcA_q0 && Ind_SrcA_q0) ? AR6[17:0] + {{6{OPsrcA_q0[15]}}, OPsrcA_q0[15:3]}        : AR6[17:0]; 
   	   3'b111 : SRC_A_ind = (Imod_SrcA_q0 && Ind_SrcA_q0) ?  SP[17:0] + {{6{OPsrcA_q0[15]}}, OPsrcA_q0[15:3]}:  SP[17:0];
   endcase
end



always @(*) begin
   case (SRC_B_sel) 
   	   3'b000 : SRC_B_ind = (Imod_SrcB_q0 && Ind_SrcB_q0) ? AR0[17:0] + {{6{OPsrcB_q0[15]}}, OPsrcB_q0[15:3]}        : AR0[17:0]; 
   	   3'b001 : SRC_B_ind = (Imod_SrcB_q0 && Ind_SrcB_q0) ? AR1[17:0] + {{6{OPsrcB_q0[15]}}, OPsrcB_q0[15:3]}        : AR1[17:0]; 
   	   3'b010 : SRC_B_ind = (Imod_SrcB_q0 && Ind_SrcB_q0) ? AR2[17:0] + {{6{OPsrcB_q0[15]}}, OPsrcB_q0[15:3]}        : AR2[17:0]; 
   	   3'b011 : SRC_B_ind = (Imod_SrcB_q0 && Ind_SrcB_q0) ? AR3[17:0] + {{6{OPsrcB_q0[15]}}, OPsrcB_q0[15:3]}        : AR3[17:0];
   	   3'b100 : SRC_B_ind = (Imod_SrcB_q0 && Ind_SrcB_q0) ? AR4[17:0] + {{6{OPsrcB_q0[15]}}, OPsrcB_q0[15:3]}        : AR4[17:0]; 
   	   3'b101 : SRC_B_ind = (Imod_SrcB_q0 && Ind_SrcB_q0) ? AR5[17:0] + {{6{OPsrcB_q0[15]}}, OPsrcB_q0[15:3]}        : AR5[17:0]; 
   	   3'b110 : SRC_B_ind = (Imod_SrcB_q0 && Ind_SrcB_q0) ? AR6[17:0] + {{6{OPsrcB_q0[15]}}, OPsrcB_q0[15:3]}        : AR6[17:0]; 
   	   3'b111 : SRC_B_ind = (Imod_SrcB_q0 && Ind_SrcB_q0) ?  SP[17:0] + {{6{OPsrcB_q0[15]}}, OPsrcB_q0[15:3]} :  SP[17:0];
   endcase
end        

always @(posedge CLK or posedge RESET) begin
    if (RESET) begin
       AR0 <= 18'h0_0000;  
       AR1 <= 18'h0_0000; 
       AR2 <= 18'h0_0000; 
       AR3 <= 18'h0_0000;
       AR4 <= 18'h0_0000; 
       AR5 <= 18'h0_0000; 
       AR6 <= 18'h0_0000; 
       SP  <= 18'h0_0FF8;             //initialize to middle of direct RAM
    end
    else begin
    
        //immediate loads of ARn occur during instruction fetch (state0) -- dest must be direct
        //direct write to ARn during newthreadq has priority over any update
        if ( Dam_q0[1] && Dam_q0[0] && ~Ind_Dest_q0 && newthreadq_sel && OPdest_q0==AR0_ADDRS[15:0]) AR0[17:0] <= OPsrc32_q0[17:0];     //immediate (up to 32 bits with Dam = 11) loads of ARn occur during instruction fetch (state0)
        if (~Dam_q0[1] && Dam_q0[0] && ~Ind_Dest_q0 && newthreadq_sel && OPdest_q0==AR0_ADDRS[15:0]) AR0[17:0] <= {2'b00, OPsrcB_q0[15:0]};   //immediate (up to 16 bits with Dam = 01) loads of ARn occur during instruction fetch (state0)
        //direct or table-read loads of ARn occur during usual write (state2)
        if (wrcycl && ~Ind_Dest_q2 && thread_q2_sel && OPdest_q2[15:0]==AR0_ADDRS[15:0]) AR0[17:0] <= wrsrcAdataSext[17:0];                                                  
        
        if ( Dam_q0[1] && Dam_q0[0] && ~Ind_Dest_q0 && newthreadq_sel && OPdest_q0==AR1_ADDRS[15:0]) AR1[17:0] <= OPsrc32_q0[17:0];     //immediate (up to 32 bits with Dam = 11) loads of ARn occur during instruction fetch (state0)
        if (~Dam_q0[1] && Dam_q0[0] && ~Ind_Dest_q0 && newthreadq_sel && OPdest_q0==AR1_ADDRS[15:0]) AR1[17:0] <= {2'b00, OPsrcB_q0[15:0]};   //immediate (up to 16 bits with Dam = 01) loads of ARn occur during instruction fetch (state0)
        //direct or table-read loads of ARn occur during usual write (state2)
        if (wrcycl && ~Ind_Dest_q2 && thread_q2_sel && OPdest_q2[15:0]==AR1_ADDRS[15:0]) AR1[17:0] <= wrsrcAdataSext[17:0];                                                  
    
        if ( Dam_q0[1] && Dam_q0[0] && ~Ind_Dest_q0 && newthreadq_sel && OPdest_q0==AR2_ADDRS[15:0]) AR2[17:0] <= OPsrc32_q0[17:0];     //immediate (up to 32 bits with Dam = 11) loads of ARn occur during instruction fetch (state0)
        if (~Dam_q0[1] && Dam_q0[0] && ~Ind_Dest_q0 && newthreadq_sel && OPdest_q0==AR2_ADDRS[15:0]) AR2[17:0] <= {2'b00, OPsrcB_q0[15:0]};   //immediate (up to 16 bits with Dam = 01) loads of ARn occur during instruction fetch (state0)
        //direct or table-read loads of ARn occur during usual write (state2)
        if (wrcycl && ~Ind_Dest_q2 && thread_q2_sel && OPdest_q2[15:0]==AR2_ADDRS[15:0]) AR2[17:0] <= wrsrcAdataSext[17:0];                                                  
    
        if ( Dam_q0[1] && Dam_q0[0] && ~Ind_Dest_q0 && newthreadq_sel && OPdest_q0==AR3_ADDRS[15:0]) AR3[17:0] <= OPsrc32_q0[17:0];     //immediate (up to 32 bits with Dam = 11) loads of ARn occur during instruction fetch (state0)
        if (~Dam_q0[1] && Dam_q0[0] && ~Ind_Dest_q0 && newthreadq_sel && OPdest_q0==AR3_ADDRS[15:0]) AR3[17:0] <= {2'b00, OPsrcB_q0[15:0]};   //immediate (up to 16 bits with Dam = 01) loads of ARn occur during instruction fetch (state0)
        //direct or table-read loads of ARn occur during usual write (state2)
        if (wrcycl && ~Ind_Dest_q2 && thread_q2_sel && OPdest_q2[15:0]==AR3_ADDRS[15:0]) AR3[17:0] <= wrsrcAdataSext[17:0];                                                  
    
        if ( Dam_q0[1] && Dam_q0[0] && ~Ind_Dest_q0 && newthreadq_sel && OPdest_q0==AR4_ADDRS[15:0]) AR4[17:0] <= OPsrc32_q0[17:0];     //immediate (up to 32 bits with Dam = 11) loads of ARn occur during instruction fetch (state0)
        if (~Dam_q0[1] && Dam_q0[0] && ~Ind_Dest_q0 && newthreadq_sel && OPdest_q0==AR4_ADDRS[15:0]) AR4[17:0] <= {2'b00, OPsrcB_q0[15:0]};   //immediate (up to 16 bits with Dam = 01) loads of ARn occur during instruction fetch (state0)
        //direct or table-read loads of ARn occur during usual write (state2)
        if (wrcycl && ~Ind_Dest_q2 && thread_q2_sel && OPdest_q2[15:0]==AR4_ADDRS[15:0]) AR4[17:0] <= wrsrcAdataSext[17:0];                                                  
    
        if ( Dam_q0[1] && Dam_q0[0] && ~Ind_Dest_q0 && newthreadq_sel && OPdest_q0==AR5_ADDRS[15:0]) AR5[17:0] <= OPsrc32_q0[17:0];     //immediate (up to 32 bits with Dam = 11) loads of ARn occur during instruction fetch (state0)
        if (~Dam_q0[1] && Dam_q0[0] && ~Ind_Dest_q0 && newthreadq_sel && OPdest_q0==AR5_ADDRS[15:0]) AR5[17:0] <= {2'b00, OPsrcB_q0[15:0]};   //immediate (up to 16 bits with Dam = 01) loads of ARn occur during instruction fetch (state0)
        //direct or table-read loads of ARn occur during usual write (state2)
        if (wrcycl && ~Ind_Dest_q2 && thread_q2_sel && OPdest_q2[15:0]==AR5_ADDRS[15:0]) AR5[17:0] <= wrsrcAdataSext[17:0];                                                  
    
        if ( Dam_q0[1] && Dam_q0[0] && ~Ind_Dest_q0 && newthreadq_sel && OPdest_q0==AR6_ADDRS[15:0]) AR6[17:0] <= OPsrc32_q0[17:0];     //immediate (up to 32 bits with Dam = 11) loads of ARn occur during instruction fetch (state0)
        if (~Dam_q0[1] && Dam_q0[0] && ~Ind_Dest_q0 && newthreadq_sel && OPdest_q0==AR6_ADDRS[15:0]) AR6[17:0] <= {2'b00, OPsrcB_q0[15:0]};   //immediate (up to 16 bits with Dam = 01) loads of ARn occur during instruction fetch (state0)
        //direct or table-read loads of ARn occur during usual write (state2)
        if (wrcycl && ~Ind_Dest_q2 && thread_q2_sel && OPdest_q2[15:0]==AR6_ADDRS[15:0]) AR6[17:0] <= wrsrcAdataSext[17:0];                                                  
    
        if ( Dam_q0[1] && Dam_q0[0] && ~Ind_Dest_q0 && newthreadq_sel && OPdest_q0==SP_ADDRS[15:0])   SP[17:0] <= OPsrc32_q0[17:0];     //immediate (up to 32 bits with Dam = 11) loads of ARn occur during instruction fetch (state0)
        if (~Dam_q0[1] && Dam_q0[0] && ~Ind_Dest_q0 && newthreadq_sel && OPdest_q0==SP_ADDRS[15:0])   SP[17:0] <= {2'b00, OPsrcB_q0[15:0]};   //immediate (up to 16 bits with Dam = 01) loads of ARn occur during instruction fetch (state0)
        //direct or table-read loads of ARn occur during usual write (state2)
        if (wrcycl && ~Ind_Dest_q2 && thread_q2_sel && OPdest_q2[15:0]==SP_ADDRS[15:0] )  SP[17:0] <= wrsrcAdataSext[17:0];
                                                          
//auto-post-modification section 
            //auto post modification of ARs and SP for read cycle occur after state 1
            if ((OPsrcA_q0[2:0]==3'b000) && newthreadq_sel && Ind_SrcA_q0 && ~Dam_q0[0] && ~Imod_SrcA_q0) AR0[17:0] <= AR0[17:0] +  {{6{OPsrcA_q0[14]}}, OPsrcA_q0[14:3]};
            if ((OPsrcB_q0[2:0]==3'b000) && newthreadq_sel && Ind_SrcB_q0 && ~Dam_q0[1] && ~Imod_SrcB_q0) AR0[17:0] <= AR0[17:0] +  {{6{OPsrcB_q0[14]}}, OPsrcB_q0[14:3]};
            //auto post modification of ARs and SP for write cycle occur after state 2
            if ((wrcycl && OPdest_q2[2:0]==3'b000) && thread_q2_sel && Ind_Dest_q2 && ~Imod_Dest_q2) AR0[17:0] <= AR0[17:0] + {{6{OPdest_q2[14]}}, OPdest_q2[14:3]};

            //auto post modification of ARs and SP for read cycle occur after state 1
            if ((OPsrcA_q0[2:0]==3'b001) && newthreadq_sel && Ind_SrcA_q0 && ~Dam_q0[0] && ~Imod_SrcA_q0) AR1[17:0] <= AR1[17:0] +  {{6{OPsrcA_q0[14]}},  OPsrcA_q0[14:3]};
            if ((OPsrcB_q0[2:0]==3'b001) && newthreadq_sel && Ind_SrcB_q0 && ~Dam_q0[1] && ~Imod_SrcB_q0) AR1[17:0] <= AR1[17:0] +  {{6{OPsrcB_q0[14]}},  OPsrcB_q0[14:3]};
            //auto post modification of ARs and SP for write cycle occur after state 2
            if ((wrcycl && OPdest_q2[2:0]==3'b001) && thread_q2_sel && Ind_Dest_q2 && ~Imod_Dest_q2) AR1[17:0] <= AR1[17:0] + {{6{OPdest_q2[14]}}, OPdest_q2[14:3]};

            //auto post modification of ARs and SP for read cycle occur after state 1
            if ((OPsrcA_q0[2:0]==3'b010) && newthreadq_sel && Ind_SrcA_q0 && ~Dam_q0[0] && ~Imod_SrcA_q0) AR2[17:0] <= AR2[17:0] +  {{6{OPsrcA_q0[14]}},  OPsrcA_q0[14:3]};
            if ((OPsrcB_q0[2:0]==3'b010) && newthreadq_sel && Ind_SrcB_q0 && ~Dam_q0[1] && ~Imod_SrcB_q0) AR2[17:0] <= AR2[17:0] +  {{6{OPsrcB_q0[14]}},  OPsrcB_q0[14:3]};
            //auto post modification of ARs and SP for write cycle occur after state 2
            if ((wrcycl && OPdest_q2[2:0]==3'b010) && thread_q2_sel && Ind_Dest_q2 && ~Imod_Dest_q2) AR2[17:0] <= AR2[17:0] + {{6{OPdest_q2[14]}}, OPdest_q2[14:3]};

            //auto post modification of ARs and SP for read cycle occur after state 1
            if ((OPsrcA_q0[2:0]==3'b011) && newthreadq_sel && Ind_SrcA_q0 && ~Dam_q0[0] && ~Imod_SrcA_q0) AR3[17:0] <= AR3[17:0] +  {{6{OPsrcA_q0[14]}},  OPsrcA_q0[14:3]};
            if ((OPsrcB_q0[2:0]==3'b011) && newthreadq_sel && Ind_SrcB_q0 && ~Dam_q0[1] && ~Imod_SrcB_q0) AR3[17:0] <= AR3[17:0] +  {{6{OPsrcB_q0[14]}},  OPsrcB_q0[14:3]};
            //auto post modification of ARs and SP for write cycle occur after state 2
            if ((wrcycl && OPdest_q2[2:0]==3'b011) && thread_q2_sel && Ind_Dest_q2 && ~Imod_Dest_q2) AR3[17:0] <= AR3[17:0] + {{6{OPdest_q2[14]}}, OPdest_q2[14:3]};

            //auto post modification of ARs and SP for read cycle occur after state 1
            if ((OPsrcA_q0[2:0]==3'b100) && newthreadq_sel && Ind_SrcA_q0 && ~Dam_q0[0] && ~Imod_SrcA_q0) AR4[17:0] <= AR4[17:0] +  {{6{OPsrcA_q0[14]}},  OPsrcA_q0[14:3]};
            if ((OPsrcB_q0[2:0]==3'b100) && newthreadq_sel && Ind_SrcB_q0 && ~Dam_q0[1] && ~Imod_SrcB_q0) AR4[17:0] <= AR4[17:0] +  {{6{OPsrcB_q0[14]}},  OPsrcB_q0[14:3]};
            //auto post modification of ARs and SP for write cycle occur after state 2
            if ((wrcycl && OPdest_q2[2:0]==3'b100) && thread_q2_sel && Ind_Dest_q2 && ~Imod_Dest_q2) AR4[17:0] <= AR4[17:0] + {{6{OPdest_q2[14]}}, OPdest_q2[14:3]};

            //auto post modification of ARs and SP for read cycle occur after state 1
            if ((OPsrcA_q0[2:0]==3'b101) && newthreadq_sel && Ind_SrcA_q0 && ~Dam_q0[0] && ~Imod_SrcA_q0) AR5[17:0] <= AR5[17:0] +  {{6{OPsrcA_q0[14]}},  OPsrcA_q0[14:3]};
            if ((OPsrcB_q0[2:0]==3'b101) && newthreadq_sel && Ind_SrcB_q0 && ~Dam_q0[1] && ~Imod_SrcB_q0) AR5[17:0] <= AR5[17:0] +  {{6{OPsrcB_q0[14]}},  OPsrcB_q0[14:3]};
            //auto post modification of ARs and SP for write cycle occur after state 2
            if ((wrcycl && OPdest_q2[2:0]==3'b101) && thread_q2_sel && Ind_Dest_q2 && ~Imod_Dest_q2) AR5[17:0] <= AR5[17:0] + {{6{OPdest_q2[14]}}, OPdest_q2[14:3]};

            //auto post modification of ARs and SP for read cycle occur after state 1
            if ((OPsrcA_q0[2:0]==3'b110) && newthreadq_sel && Ind_SrcA_q0 && ~Dam_q0[0] && ~Imod_SrcA_q0) AR6[17:0] <= AR6[17:0] +  {{6{OPsrcA_q0[14]}},  OPsrcA_q0[14:3]};
            if ((OPsrcB_q0[2:0]==3'b110) && newthreadq_sel && Ind_SrcB_q0 && ~Dam_q0[1] && ~Imod_SrcB_q0) AR6[17:0] <= AR6[17:0] +  {{6{OPsrcB_q0[14]}},  OPsrcB_q0[14:3]};
            //auto post modification of ARs and SP for write cycle occur after state 2
            if ((wrcycl && OPdest_q2[2:0]==3'b110) && thread_q2_sel && Ind_Dest_q2 && ~Imod_Dest_q2) AR6[17:0] <= AR6[17:0] + {{6{OPdest_q2[14]}}, OPdest_q2[14:3]};

            //auto post modification of ARs and SP for read cycle occur after state 1
            if ((OPsrcA_q0[2:0]==3'b111) && newthreadq_sel && Ind_SrcA_q0 && ~Dam_q0[0] && ~Imod_SrcA_q0)  SP[17:0] <=  SP[17:0] +  {{6{OPsrcA_q0[14]}},  OPsrcA_q0[14:3]};
            if ((OPsrcB_q0[2:0]==3'b111) && newthreadq_sel && Ind_SrcB_q0 && ~Dam_q0[1] && ~Imod_SrcB_q0)  SP[17:0] <=  SP[17:0] +  {{6{OPsrcB_q0[14]}},  OPsrcB_q0[14:3]};
            //auto post modification of ARs and SP for write cycle occur after state 2
            if ((wrcycl && OPdest_q2[2:0]==3'b111) && thread_q2_sel && Ind_Dest_q2 && ~Imod_Dest_q2)  SP[17:0] <=  SP[17:0] + {{6{OPdest_q2[14]}}, OPdest_q2[14:3]};
       
    end
end    
endmodule   
