//debug.v
 `timescale 1ns/100ps
 // Author:  Jerry D. Harthcock
 // Version:  1.0  October 15, 2017
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


module debug (
    CLK,
    RESET,
    Instruction_q0,
    Instruction_q0_del,
    pre_PC,
    newthread,
    tr0_PC,     
    tr1_PC,     
    tr2_PC,     
    tr3_PC,     
    pc_q2,      
    thread_q2, 
    tr0_discont,
    tr1_discont,
    tr2_discont,
    tr3_discont,
    wrdata,
    wren,
    wraddrs,
    rden,
    rdaddrs,
    rddata,
    break_q0,
    mon_write_reg,
    tr0_mon_rd_reg,   
    tr1_mon_rd_reg,   
    tr2_mon_rd_reg,   
    tr3_mon_rd_reg
    );
    
input         CLK;
input         RESET;
input  [63:0] Instruction_q0;
output [63:0] Instruction_q0_del;
input  [15:0] pre_PC;
input   [1:0] newthread;
input  [15:0] tr0_PC;   
input  [15:0] tr1_PC;   
input  [15:0] tr2_PC;   
input  [15:0] tr3_PC;   
input  [15:0] pc_q2;    
input   [1:0] thread_q2;
input         tr0_discont;
input         tr1_discont;
input         tr2_discont;
input         tr3_discont;
input  [63:0] wrdata;
input         wren;
input   [4:0] wraddrs;
input         rden;
input   [4:0] rdaddrs;
output [63:0] rddata;
output        break_q0;
output [63:0] mon_write_reg;
input  [63:0] tr0_mon_rd_reg;
input  [63:0] tr1_mon_rd_reg;
input  [63:0] tr2_mon_rd_reg;
input  [63:0] tr3_mon_rd_reg;

parameter mon_addrs_addrs     = 5'b00000;
parameter mon_write_reg_addrs = 5'b00001; 
parameter tr0_monrd_reg_addrs = 5'b00010;
parameter tr1_monrd_reg_addrs = 5'b00011;
parameter tr2_monrd_reg_addrs = 5'b00100;
parameter tr3_monrd_reg_addrs = 5'b00101;
parameter tr0_evnt_cntr_addrs = 5'b00110;   
parameter tr1_evnt_cntr_addrs = 5'b00111;    
parameter tr2_evnt_cntr_addrs = 5'b01000;   
parameter tr3_evnt_cntr_addrs = 5'b01001;   
parameter trigger_A_addrs     = 5'b01010;
parameter trigger_B_addrs     = 5'b01011;
parameter brk_cntrl_addrs     = 5'b01100;
parameter brk_status_addrs    = 5'b01101;
parameter tr0_trace_newest_ad = 5'b10000;
parameter tr0_trace_1_ad      = 5'b10001;
parameter tr0_trace_2_ad      = 5'b10010;
parameter tr0_trace_oldest_ad = 5'b10011;
parameter tr1_trace_newest_ad = 5'b10100;
parameter tr1_trace_1_ad      = 5'b10101;
parameter tr1_trace_2_ad      = 5'b10110;
parameter tr1_trace_oldest_ad = 5'b10111;
parameter tr2_trace_newest_ad = 5'b11000;
parameter tr2_trace_1_ad      = 5'b11001;
parameter tr2_trace_2_ad      = 5'b11010;
parameter tr2_trace_oldest_ad = 5'b11011;
parameter tr3_trace_newest_ad = 5'b11100;
parameter tr3_trace_1_ad      = 5'b11101;
parameter tr3_trace_2_ad      = 5'b11110;
parameter tr3_trace_oldest_ad = 5'b11111;

reg tr0_sstep;  
reg tr0_frc_brk;
reg tr0_mon_req;
reg tr0_PC_EQ_BRKA_en;
reg tr0_PC_EQ_BRKB_en;
reg tr0_PC_GT_BRKA_en;
reg tr0_PC_LT_BRKB_en;
reg tr0_PC_AND_en;

reg tr1_sstep;  
reg tr1_frc_brk;
reg tr1_mon_req;
reg tr1_PC_EQ_BRKA_en;
reg tr1_PC_EQ_BRKB_en;
reg tr1_PC_GT_BRKA_en;
reg tr1_PC_LT_BRKB_en;
reg tr1_PC_AND_en;

reg tr2_sstep;  
reg tr2_frc_brk;
reg tr2_mon_req;
reg tr2_PC_EQ_BRKA_en;
reg tr2_PC_EQ_BRKB_en;
reg tr2_PC_GT_BRKA_en;
reg tr2_PC_LT_BRKB_en;
reg tr2_PC_AND_en;
             
reg tr3_sstep;  
reg tr3_frc_brk;
reg tr3_mon_req;
reg tr3_PC_EQ_BRKA_en;
reg tr3_PC_EQ_BRKB_en;
reg tr3_PC_GT_BRKA_en;
reg tr3_PC_LT_BRKB_en;
reg tr3_PC_AND_en;

reg [15:0] tr0_evnt_cntr;
reg [15:0] tr1_evnt_cntr;
reg [15:0] tr2_evnt_cntr;
reg [15:0] tr3_evnt_cntr;

reg [15:0] tr0_trigger_A;
reg [15:0] tr0_trigger_B;
reg [15:0] tr1_trigger_A;
reg [15:0] tr1_trigger_B;
reg [15:0] tr2_trigger_A;
reg [15:0] tr2_trigger_B;
reg [15:0] tr3_trigger_A;
reg [15:0] tr3_trigger_B;

reg [63:0] rddata;

reg [15:0] mon_read_addrs;
reg [15:0] mon_write_addrs;
reg [63:0] mon_write_reg;

wire  [63:0] Instruction_q0_del;

wire  break_q0;                                                                   
                                                                                  
wire  tr0_broke;                                                                  
wire  tr1_broke;                                                                  
wire  tr2_broke;                                                                  
wire  tr3_broke;                                                                  
                                                                                  
wire  tr0_skip_cmplt;                                                             
wire  tr1_skip_cmplt; 
wire  tr2_skip_cmplt; 
wire  tr3_skip_cmplt;

wire  tr0_event_det;
wire  tr1_event_det;
wire  tr2_event_det;
wire  tr3_event_det;

wire [31:0] tr0_trace_newest;
wire [31:0] tr0_trace_1;
wire [31:0] tr0_trace_2;
wire [31:0] tr0_trace_oldest;

wire [31:0] tr1_trace_newest;
wire [31:0] tr1_trace_1;
wire [31:0] tr1_trace_2;
wire [31:0] tr1_trace_oldest;

wire [31:0] tr2_trace_newest;
wire [31:0] tr2_trace_1;
wire [31:0] tr2_trace_2;
wire [31:0] tr2_trace_oldest;

wire [31:0] tr3_trace_newest;
wire [31:0] tr3_trace_1;
wire [31:0] tr3_trace_2;
wire [31:0] tr3_trace_oldest;


wire trigger_A_wren;
wire trigger_B_wren;
wire tr0_evnt_cntr_wren;
wire tr1_evnt_cntr_wren;
wire tr2_evnt_cntr_wren;
wire tr3_evnt_cntr_wren;
wire mon_addrs_wren;
wire mon_write_reg_wren;
wire brk_cntrl_wren;


wire [63:0] brk_status_reg;
assign brk_status_reg = {56'h0000_0000_0000_00, tr3_broke, tr2_broke, tr1_broke, tr0_broke, tr3_skip_cmplt, tr2_skip_cmplt, tr1_skip_cmplt, tr0_skip_cmplt};


assign trigger_A_wren      = wren && (wraddrs==trigger_A_addrs)    ;
assign trigger_B_wren      = wren && (wraddrs==trigger_B_addrs)    ;                                                                               
assign tr0_evnt_cntr_wren  = wren && (wraddrs==tr0_evnt_cntr_addrs);                                                                                                  
assign tr1_evnt_cntr_wren  = wren && (wraddrs==tr1_evnt_cntr_addrs);                                      
assign tr2_evnt_cntr_wren  = wren && (wraddrs==tr2_evnt_cntr_addrs);                                      
assign tr3_evnt_cntr_wren  = wren && (wraddrs==tr3_evnt_cntr_addrs);                                      
assign mon_addrs_wren      = wren && (wraddrs==mon_addrs_addrs)    ;                                        
assign mon_write_reg_wren  = wren && (wraddrs==mon_write_reg_addrs);                                      
assign brk_cntrl_wren      = wren && (wraddrs==brk_cntrl_addrs)    ;   

                                                                                                                                                                                                                      
breakpoints breakpoints(                                                                                   
    .CLK               (CLK               ),                                                               
    .RESET             (RESET             ),                                                               
    .Instruction_q0    (Instruction_q0    ),                                                               
    .Instruction_q0_del(Instruction_q0_del),                                                               
    .pre_PC            (pre_PC            ),                                                               
    .newthread         (newthread         ),
                                           
    .tr0_PC_EQ_BRKA_en (tr0_PC_EQ_BRKA_en ),
    .tr0_PC_EQ_BRKB_en (tr0_PC_EQ_BRKB_en ),
    .tr0_PC_GT_BRKA_en (tr0_PC_GT_BRKA_en ),
    .tr0_PC_LT_BRKB_en (tr0_PC_LT_BRKB_en ),
    .tr0_PC_AND_en     (tr0_PC_AND_en     ),
    
    .tr1_PC_EQ_BRKA_en (tr1_PC_EQ_BRKA_en ),
    .tr1_PC_EQ_BRKB_en (tr1_PC_EQ_BRKB_en ),
    .tr1_PC_GT_BRKA_en (tr1_PC_GT_BRKA_en ),
    .tr1_PC_LT_BRKB_en (tr1_PC_LT_BRKB_en ),
    .tr1_PC_AND_en     (tr1_PC_AND_en     ),
    
    .tr2_PC_EQ_BRKA_en (tr2_PC_EQ_BRKA_en ),
    .tr2_PC_EQ_BRKB_en (tr2_PC_EQ_BRKB_en ),
    .tr2_PC_GT_BRKA_en (tr2_PC_GT_BRKA_en ),
    .tr2_PC_LT_BRKB_en (tr2_PC_LT_BRKB_en ),
    .tr2_PC_AND_en     (tr2_PC_AND_en     ),
                                           
    .tr3_PC_EQ_BRKA_en (tr3_PC_EQ_BRKA_en ),
    .tr3_PC_EQ_BRKB_en (tr3_PC_EQ_BRKB_en ),
    .tr3_PC_GT_BRKA_en (tr3_PC_GT_BRKA_en ),
    .tr3_PC_LT_BRKB_en (tr3_PC_LT_BRKB_en ),
    .tr3_PC_AND_en     (tr3_PC_AND_en     ),
    
    .tr0_event_det     (tr0_event_det     ),
    .tr1_event_det     (tr1_event_det     ),
    .tr2_event_det     (tr2_event_det     ),
    .tr3_event_det     (tr3_event_det     ),
    
    .tr0_evnt_cntr     (tr0_evnt_cntr     ),
    .tr1_evnt_cntr     (tr1_evnt_cntr     ),
    .tr2_evnt_cntr     (tr2_evnt_cntr     ),
    .tr3_evnt_cntr     (tr3_evnt_cntr     ),

    .tr0_trigger_A     (tr0_trigger_A     ),
    .tr0_trigger_B     (tr0_trigger_B     ),
    .tr1_trigger_A     (tr1_trigger_A     ),
    .tr1_trigger_B     (tr1_trigger_B     ),
    .tr2_trigger_A     (tr2_trigger_A     ),
    .tr2_trigger_B     (tr2_trigger_B     ),
    .tr3_trigger_A     (tr3_trigger_A     ),
    .tr3_trigger_B     (tr3_trigger_B     ),
    
    .tr0_sstep         (tr0_sstep         ),
    .tr1_sstep         (tr1_sstep         ),                                     
    .tr2_sstep         (tr2_sstep         ),                                     
    .tr3_sstep         (tr3_sstep         ),                                     
    .tr0_frc_brk       (tr0_frc_brk       ),                                     
    .tr1_frc_brk       (tr1_frc_brk       ),                                     
    .tr2_frc_brk       (tr2_frc_brk       ),                                     
    .tr3_frc_brk       (tr3_frc_brk       ),                                     
    .tr0_broke         (tr0_broke         ),                                     
    .tr1_broke         (tr1_broke         ),                                     
    .tr2_broke         (tr2_broke         ),                                     
    .tr3_broke         (tr3_broke         ),                                     
    .tr0_skip_cmplt    (tr0_skip_cmplt    ),                                     
    .tr1_skip_cmplt    (tr1_skip_cmplt    ),
    .tr2_skip_cmplt    (tr2_skip_cmplt    ),
    .tr3_skip_cmplt    (tr3_skip_cmplt    ),
    .break_q0          (break_q0          ),
    .mon_read_addrs    (mon_read_addrs    ),
    .mon_write_addrs   (mon_write_addrs   ),
    .tr0_mon_req       (tr0_mon_req       ),
    .tr1_mon_req       (tr1_mon_req       ),
    .tr2_mon_req       (tr2_mon_req       ),
    .tr3_mon_req       (tr3_mon_req       ),
    .wrdata            (wrdata            )
    );                 

trace_buf trace_buf(
    .CLK             (CLK        ),
    .RESET           (RESET      ),
    .tr0_discont     (tr0_discont),
    .tr1_discont     (tr1_discont),
    .tr2_discont     (tr2_discont),
    .tr3_discont     (tr3_discont),
    .tr0_PC          (tr0_PC     ),
    .tr1_PC          (tr1_PC     ),
    .tr2_PC          (tr2_PC     ),
    .tr3_PC          (tr3_PC     ),
    .pc_q2           (pc_q2      ),
    .thread_q2       (thread_q2  ),
    .tr0_trace_reg0(tr0_trace_newest),
    .tr0_trace_reg1(     tr0_trace_1),
    .tr0_trace_reg2(     tr0_trace_2),
    .tr0_trace_reg3(tr0_trace_oldest),
    
    .tr1_trace_reg0(tr1_trace_newest),
    .tr1_trace_reg1(     tr1_trace_1),
    .tr1_trace_reg2(     tr1_trace_2),
    .tr1_trace_reg3(tr1_trace_oldest),
    
    .tr2_trace_reg0(tr2_trace_newest),
    .tr2_trace_reg1(     tr2_trace_1),
    .tr2_trace_reg2(     tr2_trace_2),
    .tr2_trace_reg3(tr2_trace_oldest),
    
    .tr3_trace_reg0(tr3_trace_newest),
    .tr3_trace_reg1(     tr3_trace_1),
    .tr3_trace_reg2(     tr3_trace_2),
    .tr3_trace_reg3(tr3_trace_oldest)
    );    

always @(*)
    if (rden)
        case(rdaddrs)
                mon_addrs_addrs : rddata = {32'h0000_0000, mon_read_addrs, mon_write_addrs};  
            mon_write_reg_addrs : rddata = mon_write_reg[63:0];
            tr0_monrd_reg_addrs : rddata = tr0_mon_rd_reg;
            tr1_monrd_reg_addrs : rddata = tr1_mon_rd_reg;
            tr2_monrd_reg_addrs : rddata = tr2_mon_rd_reg;
            tr3_monrd_reg_addrs : rddata = tr3_mon_rd_reg;
            tr0_evnt_cntr_addrs : rddata = {48'h0000_0000_0000, tr0_evnt_cntr}; 
            tr1_evnt_cntr_addrs : rddata = {48'h0000_0000_0000, tr1_evnt_cntr};
            tr2_evnt_cntr_addrs : rddata = {48'h0000_0000_0000, tr2_evnt_cntr};
            tr3_evnt_cntr_addrs : rddata = {48'h0000_0000_0000, tr3_evnt_cntr};
                trigger_A_addrs : rddata = {tr3_trigger_A,  tr2_trigger_A, tr1_trigger_A, tr0_trigger_A};  
                trigger_B_addrs : rddata = {tr3_trigger_B,  tr2_trigger_B, tr1_trigger_B, tr0_trigger_B};  
                brk_cntrl_addrs : rddata = {tr3_sstep,  
                                            tr3_frc_brk,
                                            tr3_mon_req,
                                            tr3_PC_EQ_BRKA_en,
                                            tr3_PC_EQ_BRKB_en,
                                            tr3_PC_GT_BRKA_en,
                                            tr3_PC_LT_BRKB_en,
                                            tr3_PC_AND_en,
                                            
                                            tr2_sstep,  
                                            tr2_frc_brk,
                                            tr2_mon_req,
                                            tr2_PC_EQ_BRKA_en,
                                            tr2_PC_EQ_BRKB_en,
                                            tr2_PC_GT_BRKA_en,
                                            tr2_PC_LT_BRKB_en,
                                            tr2_PC_AND_en,
                                            
                                            tr1_sstep,  
                                            tr1_frc_brk,
                                            tr1_mon_req,
                                            tr1_PC_EQ_BRKA_en,
                                            tr1_PC_EQ_BRKB_en,
                                            tr1_PC_GT_BRKA_en,
                                            tr1_PC_LT_BRKB_en,
                                            tr1_PC_AND_en,
                                            
                                            tr0_sstep,  
                                            tr0_frc_brk,
                                            tr0_mon_req,
                                            tr0_PC_EQ_BRKA_en,
                                            tr0_PC_EQ_BRKB_en,
                                            tr0_PC_GT_BRKA_en,
                                            tr0_PC_LT_BRKB_en,
                                            tr0_PC_AND_en};
                                            
                brk_status_addrs : rddata = brk_status_reg;                                   
             tr0_trace_newest_ad : rddata = {32'h0000_0000, tr0_trace_newest}; 
                  tr0_trace_1_ad : rddata = {32'h0000_0000,      tr0_trace_1};      
                  tr0_trace_2_ad : rddata = {32'h0000_0000,      tr0_trace_2};      
             tr0_trace_oldest_ad : rddata = {32'h0000_0000, tr0_trace_oldest}; 
             tr1_trace_newest_ad : rddata = {32'h0000_0000, tr1_trace_newest}; 
                  tr1_trace_1_ad : rddata = {32'h0000_0000,      tr1_trace_1};      
                  tr1_trace_2_ad : rddata = {32'h0000_0000,      tr1_trace_2};      
             tr1_trace_oldest_ad : rddata = {32'h0000_0000, tr1_trace_oldest}; 
             tr2_trace_newest_ad : rddata = {32'h0000_0000, tr2_trace_newest}; 
                  tr2_trace_1_ad : rddata = {32'h0000_0000,      tr2_trace_1};      
                  tr2_trace_2_ad : rddata = {32'h0000_0000,      tr2_trace_2};      
             tr2_trace_oldest_ad : rddata = {32'h0000_0000, tr2_trace_oldest}; 
             tr3_trace_newest_ad : rddata = {32'h0000_0000, tr3_trace_newest}; 
                  tr3_trace_1_ad : rddata = {32'h0000_0000,      tr3_trace_1};      
                  tr3_trace_2_ad : rddata = {32'h0000_0000,      tr3_trace_2};      
             tr3_trace_oldest_ad : rddata = {32'h0000_0000, tr3_trace_oldest}; 
                         default : rddata = 64'h0000_0000_0000_0000; 
        endcase                     
    else rddata = 64'h0000_0000_0000_0000;                             
                                

always @(posedge CLK or posedge RESET) begin
    if (RESET) begin
        mon_read_addrs  <= 16'h0000;                                                                   
        mon_write_addrs <= 16'h0000;                                                                   
        mon_write_reg   <= 64'h0000_0000_0000_0000;                                                    
    end                                                                                                
    else begin                                                                                         
        if (mon_addrs_wren) {mon_read_addrs, mon_write_addrs} <= {32'h0000_0000, wrdata[31:0]};                     
        if (mon_write_reg_wren) mon_write_reg[63:0] <= wrdata[63:0];                                   
    end                                                                                                
end                                                                                                    


always @(posedge CLK or posedge RESET) begin
    if (RESET) begin
        tr0_evnt_cntr <= 16'h0001;
        tr1_evnt_cntr <= 16'h0001;
        tr2_evnt_cntr <= 16'h0001;
        tr3_evnt_cntr <= 16'h0001;
    end
    else begin
        if (tr0_evnt_cntr_wren && ~|wrdata[15:0]) tr0_evnt_cntr <= wrdata[15:0]; 
        else if (tr0_event_det && (tr0_evnt_cntr > 16'h0001)) tr0_evnt_cntr <= tr0_evnt_cntr - 1'b1;
         
        if (tr1_evnt_cntr_wren && ~|wrdata[15:0]) tr1_evnt_cntr <= wrdata[15:0]; 
        else if (tr1_event_det && (tr1_evnt_cntr > 16'h0001)) tr1_evnt_cntr <= tr1_evnt_cntr - 1'b1;
         
        if (tr2_evnt_cntr_wren && ~|wrdata[15:0]) tr2_evnt_cntr <= wrdata[15:0]; 
        else if (tr2_event_det && (tr2_evnt_cntr > 16'h0001)) tr2_evnt_cntr <= tr2_evnt_cntr - 1'b1;
         
        if (tr3_evnt_cntr_wren && ~|wrdata[15:0]) tr3_evnt_cntr <= wrdata[15:0]; 
        else if (tr3_event_det && (tr3_evnt_cntr > 16'h0001)) tr3_evnt_cntr <= tr3_evnt_cntr - 1'b1; 
    end
end  

always @(posedge CLK or posedge RESET) begin
    if (RESET) begin
        tr0_trigger_A <= 16'h0000;
        tr0_trigger_B <= 16'h0000;
        tr1_trigger_A <= 16'h0000;
        tr1_trigger_B <= 16'h0000;
        tr2_trigger_A <= 16'h0000;
        tr2_trigger_B <= 16'h0000;
        tr3_trigger_A <= 16'h0000;
        tr3_trigger_B <= 16'h0000;
    end
    else begin
        if (trigger_A_wren) {tr3_trigger_A,  tr2_trigger_A, tr1_trigger_A, tr0_trigger_A} <= wrdata[63:0]; 
        if (trigger_B_wren) {tr3_trigger_B,  tr2_trigger_B, tr1_trigger_B, tr0_trigger_B} <= wrdata[63:0]; 
    end
end  

always @(posedge CLK or posedge RESET) begin
    if (RESET) {tr3_sstep,  
                tr3_frc_brk,
                tr3_mon_req,
                tr3_PC_EQ_BRKA_en,
                tr3_PC_EQ_BRKB_en,
                tr3_PC_GT_BRKA_en,
                tr3_PC_LT_BRKB_en,
                tr3_PC_AND_en,
                
                tr2_sstep,  
                tr2_frc_brk,
                tr2_mon_req,
                tr2_PC_EQ_BRKA_en,
                tr2_PC_EQ_BRKB_en,
                tr2_PC_GT_BRKA_en,
                tr2_PC_LT_BRKB_en,
                tr2_PC_AND_en,
                
                tr1_sstep,  
                tr1_frc_brk,
                tr1_mon_req,
                tr1_PC_EQ_BRKA_en,
                tr1_PC_EQ_BRKB_en,
                tr1_PC_GT_BRKA_en,
                tr1_PC_LT_BRKB_en,
                tr1_PC_AND_en,
                
                tr0_sstep,  
                tr0_frc_brk,
                tr0_mon_req,
                tr0_PC_EQ_BRKA_en,
                tr0_PC_EQ_BRKB_en,
                tr0_PC_GT_BRKA_en,
                tr0_PC_LT_BRKB_en,
                tr0_PC_AND_en}    <= 64'h0000_0000_0000_0000;  
    
    else if (brk_cntrl_wren) {tr3_sstep,  
                              tr3_frc_brk,
                              tr3_mon_req,
                              tr3_PC_EQ_BRKA_en,
                              tr3_PC_EQ_BRKB_en,
                              tr3_PC_GT_BRKA_en,
                              tr3_PC_LT_BRKB_en,
                              tr3_PC_AND_en,
                              
                              tr2_sstep,  
                              tr2_frc_brk,
                              tr2_mon_req,
                              tr2_PC_EQ_BRKA_en,
                              tr2_PC_EQ_BRKB_en,
                              tr2_PC_GT_BRKA_en,
                              tr2_PC_LT_BRKB_en,
                              tr2_PC_AND_en,
                              
                              tr1_sstep,  
                              tr1_frc_brk,
                              tr1_mon_req,
                              tr1_PC_EQ_BRKA_en,
                              tr1_PC_EQ_BRKB_en,
                              tr1_PC_GT_BRKA_en,
                              tr1_PC_LT_BRKB_en,
                              tr1_PC_AND_en,
                              
                              tr0_sstep,  
                              tr0_frc_brk,
                              tr0_mon_req,
                              tr0_PC_EQ_BRKA_en,
                              tr0_PC_EQ_BRKB_en,
                              tr0_PC_GT_BRKA_en,
                              tr0_PC_LT_BRKB_en,
                              tr0_PC_AND_en}     <= wrdata[63:0];
end  


endmodule
