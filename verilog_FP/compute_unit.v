 // compute_unit.v
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

module compute_unit (
    CLK,
    RESET_IN,

    debug_wrdata, 
    debug_wren,   
    debug_wraddrs,
    debug_rden,   
    debug_rdaddrs,
    debug_rddata,

    h_wren,
    h_wrsize,
    h_wraddrs,
    h_wrdata,
    h_rden,
    h_rdsize,
    h_rdaddrs,
    h_rddata, 

    tr0_done,                                                            
    tr1_done,                                                            
    tr2_done,                                                            
    tr3_done,
    
    tr0_IRQ,
    tr1_IRQ,
    tr2_IRQ,
    tr3_IRQ
    );

input CLK;
input  RESET_IN;
output tr0_done;
output tr1_done;
output tr2_done;
output tr3_done;
input tr0_IRQ;
input tr1_IRQ;
input tr2_IRQ;
input tr3_IRQ;
input [63:0] debug_wrdata; 
input debug_wren;   
input [4:0] debug_wraddrs;
input debug_rden;   
input [4:0] debug_rdaddrs;
output [63:0] debug_rddata; 
input h_wren;
input [1:0] h_wrsize;
input [17:0]h_wraddrs;
input [63:0]h_wrdata;
input h_rden;
input [1:0] h_rdsize;
input [17:0] h_rdaddrs;
input [63:0] h_rddata; 

parameter     BTBS_ =  16'hFFA0;   // bit test and branch if set
parameter     BTBC_ =  16'hFF98;   // bit test and branch if clear
parameter     BRAL_ =  16'hFFF8;   // branch relative long
parameter     JMPA_ =  16'hFFA8;   // jump absolute long

parameter     BRAL_ADDRS = 18'h0FFF8;   // branch relative long
parameter     JMPA_ADDRS = 18'h0FFA8;   // jump absolute long
parameter     BTBS_ADDRS = 18'h0FFA0;   // bit test and branch if set
parameter     BTBC_ADDRS = 18'h0FF98;   // bit test and branch if clear

parameter  GLOB_RAM_ADDRS = 18'b01_0xxx_xxxx_xxxx_xxxx; //globabl RAM address (in bytes)
parameter        SP_ADDRS = 18'h0FFE8;
parameter       AR6_ADDRS = 18'h0FFE0;
parameter       AR5_ADDRS = 18'h0FFD8;
parameter       AR4_ADDRS = 18'h0FFD0;
parameter       AR3_ADDRS = 18'h0FFC8;
parameter       AR2_ADDRS = 18'h0FFC0;
parameter       AR1_ADDRS = 18'h0FFB8;
parameter       AR0_ADDRS = 18'h0FFB0;
parameter        PC_ADDRS = 18'h0FFA8;
parameter   PC_COPY_ADDRS = 18'h0FF90;
parameter        ST_ADDRS = 18'h0FF88;
parameter    REPEAT_ADDRS = 18'h0FF80;
parameter    LPCNT1_ADDRS = 18'h0FF78;
parameter    LPCNT0_ADDRS = 18'h0FF70;
parameter     TIMER_ADDRS = 18'h0FF68;
parameter      CREG_ADDRS = 18'h0FF60;
parameter     CAPT3_ADDRS = 18'h0FF58;
parameter     CAPT2_ADDRS = 18'h0FF50;
parameter     CAPT1_ADDRS = 18'h0FF48;
parameter     CAPT0_ADDRS = 18'h0FF40;
parameter     SCHED_ADDRS = 18'h0FF38;
parameter  SCHEDCMP_ADDRS = 18'h0FF30;
parameter       QOS_ADDRS = 18'h0FF20;
parameter       MON_ADDRS = 18'h0FF00;
parameter     FLOAT_ADDRS = 18'b00_1110_xxxxxxxxxxxx;  //floating-point operator block
parameter    INTEGR_ADDRS = 18'b00_1101_xxxxxxxxxxxx;  // integer and logic operator block
parameter  PRIV_RAM_ADDRS = 18'b00_0xxx_xxxx_xxxx_xxxx;    //first 32k bytes (since data memory is byte-addressable and smallest RAM for this in Kintex 7 is 2k x 64 bits using two blocks next to each other

reg [15:0] PC;
reg [15:0] pre_PC;
reg [15:0] pc_q1;
reg [15:0] pc_q2;
reg [1:0]  newthread;
reg [1:0]  newthreadq;
reg [1:0]  thread_q1;
reg [1:0]  thread_q2;

reg LD_newthread;
reg [63:0] wrsrcAdataSext;
reg [63:0] wrsrcBdataSext;
reg [63:0] rdSrcAdata;
reg [63:0] rdSrcBdata;
reg [63:0] wrsrcAdata;
reg [63:0] wrsrcBdata;

reg fp_ready_q2;
reg fp_sel_q2;
reg ready_integer_q2;
reg integer_sel_q2;

reg  [63:0] mon_rd_regs;

reg [31:0] sched_cmp;
reg [31:0] scheduler;
reg [3:0]  sched_state;
reg [5:0]  STATE;
                                                                                            
reg [1:0]  RM_q1; 
reg [1:0]  Dam_q1; 
reg        Sext_Dest_q1;
reg [1:0]  Size_Dest_q1;  
reg        Ind_Dest_q1;
reg        Imod_Dest_q1; 
reg [15:0] OPdest_q1;
reg        Sext_SrcA_q1; 
reg [1:0]  Size_SrcA_q1;  
reg        Ind_SrcA_q1; 
reg        Imod_SrcA_q1; 
reg [15:0] OPsrcA_q1; 
reg        Sext_SrcB_q1; 
reg  [1:0] Size_SrcB_q1;  
reg        Ind_SrcB_q1; 
reg        Imod_SrcB_q1; 
reg [15:0] OPsrcB_q1; 
reg [31:0] OPsrc32_q1; 

reg [1:0]   RM_q2; 
reg [1:0]  Dam_q2; 
reg        Sext_Dest_q2;
reg [1:0]  Size_Dest_q2;  
reg        Ind_Dest_q2;
reg        Imod_Dest_q2; 
reg [15:0] OPdest_q2;
reg        Sext_SrcA_q2; 
reg [1:0]  Size_SrcA_q2;  
reg        Ind_SrcA_q2; 
reg        Imod_SrcA_q2; 
reg [15:0] OPsrcA_q2; 
reg        Sext_SrcB_q2; 
reg  [1:0] Size_SrcB_q2;  
reg        Ind_SrcB_q2; 
reg        Imod_SrcB_q2; 
reg [15:0] OPsrcB_q2; 
reg [31:0] OPsrc32_q2;
reg [17:0] SrcA_addrs_q1;
reg [17:0] SrcB_addrs_q1;
reg [17:0] SrcA_addrs_q2;
reg [17:0] SrcB_addrs_q2;

reg [17:0] Dest_addrs_q2;
reg [17:0] SrcA_addrs_q0;
reg [17:0] SrcB_addrs_q0;

reg [15:0] next_PC;

reg RESET;

reg C_q2;
reg V_q2;
reg N_q2;
reg Z_q2;

wire [63:0] debug_rddata;

wire [63:0] h_rddata;
wire h_rom_rdsel;
wire h_ram_wrsel;
wire h_ram_rdsel;

wire [63:0] tr0_mon_rd_reg;    
wire [63:0] tr1_mon_rd_reg;    
wire [63:0] tr2_mon_rd_reg;    
wire [63:0] tr3_mon_rd_reg;   

wire [1:0] RM_q0;
wire [1:0] Dam_q0;
wire Ind_SrcA_q0;
wire Ind_SrcB_q0;
wire Ind_Dest_q0;
wire Imod_SrcA_q0;
wire Imod_SrcB_q0;
wire Imod_Dest_q0;
wire [1:0] Size_SrcA_q0;
wire [1:0] Size_SrcB_q0;
wire [1:0] Size_Dest_q0;
wire Sext_SrcA_q0;
wire Sext_SrcB_q0;
wire Sext_Dest_q0;
wire [31:0] OPsrc32_q0;
wire [15:0] OPsrcA_q0;
wire [15:0] OPsrcB_q0;
wire [15:0] OPdest_q0;

wire [3:0] sextA_sel;
wire [3:0] sextB_sel;

wire tr0_C;
wire tr0_V;
wire tr0_N;
wire tr0_Z;
wire tr1_C;
wire tr1_V;
wire tr1_N;
wire tr1_Z;
wire tr2_C;
wire tr2_V;
wire tr2_N;
wire tr2_Z;
wire tr3_C;
wire tr3_V;
wire tr3_N;
wire tr3_Z;

wire C_q1;
wire V_q1;
wire N_q1;
wire Z_q1;

wire sched_0;       
wire sched_0q;
wire sched_1;
wire sched_1q;
wire sched_2;
wire sched_2q;
wire sched_3;
wire sched_3q;

wire fp_ready_q1;
wire fp_sel_q1;


wire [63:0] tr0_rdSrcAdata;
wire [63:0] tr0_rdSrcBdata;
wire [63:0] tr1_rdSrcAdata;
wire [63:0] tr1_rdSrcBdata;
wire [63:0] tr2_rdSrcAdata;
wire [63:0] tr2_rdSrcBdata;
wire [63:0] tr3_rdSrcAdata;
wire [63:0] tr3_rdSrcBdata;

wire [17:0] tr0_Dest_addrs_q2;
wire [17:0] tr0_SrcA_addrs_q0;
wire [17:0] tr0_SrcB_addrs_q0;

wire [17:0] tr1_Dest_addrs_q2;
wire [17:0] tr1_SrcA_addrs_q0;
wire [17:0] tr1_SrcB_addrs_q0;

wire [17:0] tr2_Dest_addrs_q2;
wire [17:0] tr2_SrcA_addrs_q0;
wire [17:0] tr2_SrcB_addrs_q0;

wire [17:0] tr3_Dest_addrs_q2;
wire [17:0] tr3_SrcA_addrs_q0;
wire [17:0] tr3_SrcB_addrs_q0;

wire [15:0] tr0_PC;
wire [15:0] tr1_PC;
wire [15:0] tr2_PC;
wire [15:0] tr3_PC;

wire [63:0] Instruction_q0;
wire [63:0] Instruction_q0_del;
wire [63:0] priv_RAM_rddataA;
wire [63:0] priv_RAM_rddataB;
wire [63:0] glob_RAM_rddataA;
wire [63:0] glob_RAM_rddataB;
wire [63:0] Table_data;

wire [3:0] exc_codeA;
wire [3:0] exc_codeB;

wire tr3_invalid;  
wire tr3_divby0; 
wire tr3_overflow; 
wire tr3_underflow;
wire tr3_inexact;  

wire tr2_invalid;  
wire tr2_divby0; 
wire tr2_overflow; 
wire tr2_underflow;
wire tr2_inexact;  

wire tr1_invalid;  
wire tr1_divby0; 
wire tr1_overflow; 
wire tr1_underflow;
wire tr1_inexact;  

wire tr0_invalid;  
wire tr0_divby0; 
wire tr0_overflow; 
wire tr0_underflow;
wire tr0_inexact;

wire tr3_invalid_imm;  
wire tr3_divby0_imm;   
wire tr3_overflow_imm; 
wire tr3_underflow_imm;
wire tr3_inexact_imm;  

wire tr2_invalid_imm;  
wire tr2_divby0_imm;   
wire tr2_overflow_imm; 
wire tr2_underflow_imm;
wire tr2_inexact_imm;  

wire tr1_invalid_imm;  
wire tr1_divby0_imm;   
wire tr1_overflow_imm; 
wire tr1_underflow_imm;
wire tr1_inexact_imm;  

wire tr0_invalid_imm;  
wire tr0_divby0_imm;   
wire tr0_overflow_imm; 
wire tr0_underflow_imm;
wire tr0_inexact_imm;  

wire tr3_invalid_del;  
wire tr3_divby0_del;   
wire tr3_overflow_del; 
wire tr3_underflow_del;
wire tr3_inexact_del;  

wire tr2_invalid_del;  
wire tr2_divby0_del;   
wire tr2_overflow_del; 
wire tr2_underflow_del;
wire tr2_inexact_del;  

wire tr1_invalid_del;  
wire tr1_divby0_del;   
wire tr1_overflow_del; 
wire tr1_underflow_del;
wire tr1_inexact_del;  

wire tr0_invalid_del;  
wire tr0_divby0_del;   
wire tr0_overflow_del; 
wire tr0_underflow_del;
wire tr0_inexact_del;  

wire tr0_int_in_service;
wire tr1_int_in_service;
wire tr2_int_in_service;
wire tr3_int_in_service;

wire tr0_IRQ;
wire tr0_done;
wire tr0_alt_inv_handl;
wire tr0_alt_div0_handl;
wire tr0_alt_ovfl_handl;
wire tr0_alt_unfl_handl;
wire tr0_IRQ_IE;

wire tr1_IRQ;
wire tr1_done;
wire tr1_alt_inv_handl;
wire tr1_alt_div0_handl;
wire tr1_alt_ovfl_handl;
wire tr1_alt_unfl_handl;
wire tr1_IRQ_IE;

wire tr2_IRQ;
wire tr2_done;
wire tr2_alt_inv_handl;
wire tr2_alt_div0_handl;
wire tr2_alt_ovfl_handl;
wire tr2_alt_unfl_handl;
wire tr2_IRQ_IE;

wire tr3_IRQ;
wire tr3_done;
wire tr3_alt_inv_handl;
wire tr3_alt_div0_handl;
wire tr3_alt_ovfl_handl;
wire tr3_alt_unfl_handl;
wire tr3_IRQ_IE;

wire tr0_alt_del_nxact;
wire tr0_alt_del_unfl; 
wire tr0_alt_del_ovfl; 
wire tr0_alt_del_div0; 
wire tr0_alt_del_inv;  

wire tr1_alt_del_nxact;
wire tr1_alt_del_unfl; 
wire tr1_alt_del_ovfl; 
wire tr1_alt_del_div0; 
wire tr1_alt_del_inv;  

wire tr2_alt_del_nxact;
wire tr2_alt_del_unfl; 
wire tr2_alt_del_ovfl; 
wire tr2_alt_del_div0; 
wire tr2_alt_del_inv;  

wire tr3_alt_del_nxact;
wire tr3_alt_del_unfl; 
wire tr3_alt_del_ovfl; 
wire tr3_alt_del_div0; 
wire tr3_alt_del_inv;  

wire tr0_RPT_not_z;
wire tr1_RPT_not_z;
wire tr2_RPT_not_z;
wire tr3_RPT_not_z;

wire tr0_rewind_PC;
wire tr1_rewind_PC;
wire tr2_rewind_PC;
wire tr3_rewind_PC;

wire tr0_ld_vector;
wire tr1_ld_vector;
wire tr2_ld_vector;
wire tr3_ld_vector;

wire tr0_discont;
wire tr1_discont;
wire tr2_discont;
wire tr3_discont;

wire tr0_skip_cmplt;
wire tr1_skip_cmplt;
wire tr2_skip_cmplt;
wire tr3_skip_cmplt;

wire tr0_broke;
wire tr1_broke;
wire tr2_broke;
wire tr3_broke;

wire break_q0;

wire rdcycl;
wire wrcycl;

wire [63:0] tr0_C_reg;
wire [63:0] tr1_C_reg;
wire [63:0] tr2_C_reg;
wire [63:0] tr3_C_reg;

wire tr3_CREG_wr;                                                                                                           
wire tr2_CREG_wr;                                                                                                           
wire tr1_CREG_wr;                                                                                                           
wire tr0_CREG_wr;

wire [31:0] float_rddataA;
wire [31:0] float_rddataB;                                                                                                           

wire [67:0] rddataA_integer;             
wire [67:0] rddataB_integer; 
wire ready_integer_q1;
wire integer_sel_q1;
wire [63:0] trace_rddata;

wire [63:0] bitsel;
wire bitmatch;
wire [5:0] bit_number;

assign bit_number = {Sext_SrcB_q2, Size_SrcB_q2[1:0], Ind_SrcB_q2, OPsrcB_q2[15:14]};

assign bitsel = 1'b1<< bit_number;
assign bitmatch = |(bitsel & wrsrcAdata) ;

assign h_ram_wrsel = h_wren && (h_wraddrs[17:15]==3'b010);
assign h_ram_rdsel = h_rden && (h_rdaddrs[17:15]==3'b010);
assign h_rom_rdsel = h_rden && (h_rdaddrs[17:15]==3'b111);
assign h_rddata = h_rom_rdsel ? Table_data[63:0] : glob_RAM_rddataB[63:0];

assign C_q1 = rddataA_integer[67];
assign V_q1 = rddataA_integer[66];
assign N_q1 = rddataA_integer[65];
assign Z_q1 = rddataA_integer[64];

assign tr3_CREG_wr = wrcycl & (Dest_addrs_q2==CREG_ADDRS) & (thread_q2==2'b11);                                                                                                           
assign tr2_CREG_wr = wrcycl & (Dest_addrs_q2==CREG_ADDRS) & (thread_q2==2'b10);                                                                                                           
assign tr1_CREG_wr = wrcycl & (Dest_addrs_q2==CREG_ADDRS) & (thread_q2==2'b01);                                                                                                           
assign tr0_CREG_wr = wrcycl & (Dest_addrs_q2==CREG_ADDRS) & (thread_q2==2'b00);                                                                                                           

assign tr3_invalid   = tr3_invalid_imm;
assign tr3_divby0    = tr3_alt_del_div0  ? tr3_divby0_del    : tr3_divby0_imm;
assign tr3_overflow  = tr3_alt_del_ovfl  ? tr3_overflow_del  : tr3_overflow_imm;
assign tr3_underflow = tr3_alt_del_unfl  ? tr3_underflow_del : tr3_underflow_imm;
assign tr3_inexact   = tr3_alt_del_nxact ? tr3_inexact_del   : tr3_inexact_imm;
                                                                                                                                       
assign tr2_invalid   = tr2_invalid_imm;
assign tr2_divby0    = tr2_alt_del_div0  ? tr2_divby0_del    : tr2_divby0_imm;
assign tr2_overflow  = tr2_alt_del_ovfl  ? tr2_overflow_del  : tr2_overflow_imm;
assign tr2_underflow = tr2_alt_del_unfl  ? tr2_underflow_del : tr2_underflow_imm;
assign tr2_inexact   = tr2_alt_del_nxact ? tr2_inexact_del   : tr2_inexact_imm;

assign tr1_invalid   = tr1_invalid_imm;
assign tr1_divby0    = tr1_alt_del_div0  ? tr1_divby0_del    : tr1_divby0_imm;
assign tr1_overflow  = tr1_alt_del_ovfl  ? tr1_overflow_del  : tr1_overflow_imm;
assign tr1_underflow = tr1_alt_del_unfl  ? tr1_underflow_del : tr1_underflow_imm;
assign tr1_inexact   = tr1_alt_del_nxact ? tr1_inexact_del   : tr1_inexact_imm;

assign tr0_invalid   = tr0_invalid_imm;
assign tr0_divby0    = tr0_alt_del_div0  ? tr0_divby0_del    : tr0_divby0_imm;
assign tr0_overflow  = tr0_alt_del_ovfl  ? tr0_overflow_del  : tr0_overflow_imm;
assign tr0_underflow = tr0_alt_del_unfl  ? tr0_underflow_del : tr0_underflow_imm;
assign tr0_inexact   = tr0_alt_del_nxact ? tr0_inexact_del   : tr0_inexact_imm;

assign sextA_sel = {Size_Dest_q2[1:0], Size_SrcA_q2[1:0]};       
assign sextB_sel = {Size_Dest_q2[1:0], Size_SrcB_q2[1:0]};

assign  RM_q0[1:0]       = Instruction_q0_del[63:62];
assign Dam_q0[1:0]       = Instruction_q0_del[61:60]; 
assign Sext_Dest_q0      = Instruction_q0_del[59];   
assign Size_Dest_q0[1:0] = Instruction_q0_del[58:57]; 
assign Ind_Dest_q0       = Instruction_q0_del[56]; 
assign Imod_Dest_q0      = Instruction_q0_del[55];   //barrows msb of destination operand
assign OPdest_q0[15:0]   = Instruction_q0_del[55:40]; 
assign Sext_SrcA_q0      = Instruction_q0_del[39]; 
assign Size_SrcA_q0[1:0] = Instruction_q0_del[38:37]; 
assign Ind_SrcA_q0       = Instruction_q0_del[36]; 
assign Imod_SrcA_q0      = Instruction_q0_del[35];   //barrows msb of SrcA operand
assign OPsrcA_q0[15:0]   = Instruction_q0_del[35:20];
assign Sext_SrcB_q0      = Instruction_q0_del[19]; 
assign Size_SrcB_q0[1:0] = Instruction_q0_del[18:17]; 
assign Ind_SrcB_q0       = Instruction_q0_del[16];   
assign Imod_SrcB_q0      = Instruction_q0_del[15];   //barrows msb of SrcB operand
assign OPsrcB_q0[15:0]   = Instruction_q0_del[15:0]; 
assign OPsrc32_q0[31:0]  = Instruction_q0_del[31:0]; 
      
assign sched_0 = |sched_cmp[7:0]   && (scheduler[7:0]   == sched_cmp[7:0])   && sched_state[0];  
assign sched_1 = |sched_cmp[15:8]  && (scheduler[15:8]  == sched_cmp[15:8])  && sched_state[1];
assign sched_2 = |sched_cmp[23:16] && (scheduler[23:16] == sched_cmp[23:16]) && sched_state[2];
assign sched_3 = |sched_cmp[31:24] && (scheduler[31:24] == sched_cmp[31:24]) && sched_state[3]; 

assign fp_sel_q1 =      ((SrcA_addrs_q1[17:12]==6'b00_1110) && ~Dam_q1[1]) || ((SrcB_addrs_q1[17:12]==6'b00_1110) && ~Dam_q1[0]); 
assign integer_sel_q1 = ((SrcA_addrs_q1[17:12]==6'b00_1101) && ~Dam_q1[1]) || ((SrcB_addrs_q1[17:12]==6'b00_1101) && ~Dam_q1[0]);                                                                                

assign tr0_rewind_PC = (~fp_ready_q2 && (thread_q2==2'b00) && fp_sel_q2) || (~ready_integer_q2 && (thread_q2==2'b00) && integer_sel_q2);
assign tr1_rewind_PC = (~fp_ready_q2 && (thread_q2==2'b01) && fp_sel_q2) || (~ready_integer_q2 && (thread_q2==2'b01) && integer_sel_q2);
assign tr2_rewind_PC = (~fp_ready_q2 && (thread_q2==2'b10) && fp_sel_q2) || (~ready_integer_q2 && (thread_q2==2'b10) && integer_sel_q2);
assign tr3_rewind_PC = (~fp_ready_q2 && (thread_q2==2'b11) && fp_sel_q2) || (~ready_integer_q2 && (thread_q2==2'b11) && integer_sel_q2);                       

assign rdcycl = 1'b1;
assign wrcycl = STATE[3];

wire [63:0] mon_write_reg;

debug debug(
    .CLK               (CLK                ),
    .RESET             (RESET              ),
    .Instruction_q0    (Instruction_q0     ),
    .Instruction_q0_del(Instruction_q0_del ),
    .pre_PC            (pre_PC             ),
    .newthread         (newthread          ),
    .tr0_PC            (tr0_PC             ),
    .tr1_PC            (tr1_PC             ),
    .tr2_PC            (tr2_PC             ),
    .tr3_PC            (tr3_PC             ),
    .pc_q2             (pc_q2              ),
    .thread_q2         (thread_q2          ),
    .tr0_discont       (tr0_discont        ),
    .tr1_discont       (tr1_discont        ),
    .tr2_discont       (tr2_discont        ),
    .tr3_discont       (tr3_discont        ),
    .wrdata            (debug_wrdata       ),
    .wren              (debug_wren         ),
    .wraddrs           (debug_wraddrs      ),
    .rden              (debug_rden         ),
    .rdaddrs           (debug_rdaddrs      ),
    .rddata            (debug_rddata       ),
    .break_q0          (break_q0           ),
    .mon_write_reg     (mon_write_reg      ),
    .tr0_mon_rd_reg    (tr0_mon_rd_reg     ),                           
    .tr1_mon_rd_reg    (tr1_mon_rd_reg     ),
    .tr2_mon_rd_reg    (tr2_mon_rd_reg     ),
    .tr3_mon_rd_reg    (tr3_mon_rd_reg     )
    );                                    
                        
aSYMPL_func fpmath( 
   .RESET    (RESET),
   .CLK      (CLK ),
   .pc_q2    (pc_q2),
   .thread   (newthreadq[1:0]),
   .thread_q1(thread_q1[1:0]),
   .thread_q2(thread_q2[1:0]),
   .constn_q1 (Dam_q1[1:0]),
   .OPsrcA_q1(OPsrcA_q1),
   .OPsrcB_q1(OPsrcB_q1),
   .OPsrc32_q1(OPsrc32_q1),
   .wren     (wrcycl && (Dest_addrs_q2[17:12]==6'b00_1110)),  //float operator block select
   .wraddrs  (Dest_addrs_q2[11:3]),
   .rdSrcAdata (rdSrcAdata[31:0]),
   .rdSrcBdata (rdSrcBdata[31:0]),
   .rdenA    (~Dam_q0[1] && (SrcA_addrs_q0[17:12]==6'b00_1110)),    //direct or indirect read
   .rdaddrsA (SrcA_addrs_q0[11:3]),
   .rddataA  (float_rddataA[31:0]),                                                                          
   .rdenB    (~Dam_q0[0] && (SrcB_addrs_q0[17:12]==6'b00_1110)),                                             
   .rdaddrsB (SrcB_addrs_q0[11:3]),
   .rddataB  (float_rddataB[31:0]),
   .tr0_C_reg(tr0_C_reg[31:0] ),
   .tr1_C_reg(tr1_C_reg[31:0] ),
   .tr2_C_reg(tr2_C_reg[31:0] ),
   .tr3_C_reg(tr3_C_reg[31:0] ),
   .exc_codeA(exc_codeA ), 
   .exc_codeB(exc_codeB ),
   
   .tr3_CREG_wr(tr3_CREG_wr), 
   .tr2_CREG_wr(tr2_CREG_wr), 
   .tr1_CREG_wr(tr1_CREG_wr), 
   .tr0_CREG_wr(tr0_CREG_wr), 
   
   .ready    (fp_ready_q1),
   
   .round_mode_q1(RM_q1    ),
   
   .tr3_invalid  (tr3_invalid_imm  ),
   .tr3_div_by_0 (tr3_divby0_imm   ),
   .tr3_overflow (tr3_overflow_imm ),
   .tr3_underflow(tr3_underflow_imm),
   .tr3_inexact  (tr3_inexact_imm  ),
   
   .tr2_invalid  (tr2_invalid_imm  ),
   .tr2_div_by_0 (tr2_divby0_imm   ),
   .tr2_overflow (tr2_overflow_imm ),
   .tr2_underflow(tr2_underflow_imm),
   .tr2_inexact  (tr2_inexact_imm  ),
   
   .tr1_invalid  (tr1_invalid_imm  ),
   .tr1_div_by_0 (tr1_divby0_imm   ),
   .tr1_overflow (tr1_overflow_imm ),
   .tr1_underflow(tr1_underflow_imm),
   .tr1_inexact  (tr1_inexact_imm  ),
   
   .tr0_invalid  (tr0_invalid_imm  ),
   .tr0_div_by_0 (tr0_divby0_imm   ),
   .tr0_overflow (tr0_overflow_imm ),
   .tr0_underflow(tr0_underflow_imm),
   .tr0_inexact  (tr0_inexact_imm  )
   );    


thread_unit thread0 (                                         
    .CLK            (CLK             ),                       
    .RESET          (RESET           ),                       
    .newthreadq_sel (newthreadq==2'b00),                      
    .thread_q1_sel  (thread_q1==2'b00),                       
    .thread_q2_sel  ((thread_q2==2'b00) && STATE[1]),              
    .thread_q1      (thread_q1       ),                        
    .wrsrcAdataSext (wrsrcAdataSext  ),                       
    .wrsrcAdata     (wrsrcAdata      ),                       
    .rdSrcAdataT    (tr0_rdSrcAdata  ),                       
    .rdSrcBdata     (tr0_rdSrcBdata  ),                       
    .priv_RAM_rddataA (priv_RAM_rddataA[63:0]),                      
    .priv_RAM_rddataB (priv_RAM_rddataB[63:0]),                      
    .glob_RAM_rddataA (glob_RAM_rddataA[63:0]),                      
    .glob_RAM_rddataB (glob_RAM_rddataB[63:0]),                      
    .Table_data     (Table_data[63:0]),                       
    .ld_vector      (tr0_ld_vector   ),                       
    .rewind_PC      (tr0_rewind_PC   ),                       
    .wrcycl         (wrcycl          ),                       
    .discont_out    (tr0_discont     ),                       
    .OPsrcA_q0      (OPsrcA_q0[15:0] ),                       
    .OPsrcA_q2      (OPsrcA_q2[15:0]  ),                       
    .OPsrcB_q0      (OPsrcB_q0[15:0] ),                       
    .OPsrcB_q2      (OPsrcB_q2[15:0] ),                       
    .OPdest_q0      (OPdest_q0[15:0] ),                       
    .OPdest_q2      (OPdest_q2[15:0] ),                       
    .RPT_not_z      (tr0_RPT_not_z   ),                       
    .next_PC        (next_PC[15:0]   ),                       
    .Dam_q0         (Dam_q0[1:0]     ),                       
    .Dam_q1         (Dam_q1[1:0]     ),                          
    .Dam_q2         (Dam_q2[1:0]     ),                       
    .Ind_Dest_q2    (Ind_Dest_q2     ),                       
    .Ind_SrcA_q0    (Ind_SrcA_q0     ),                       
    .Ind_SrcA_q2    (Ind_SrcA_q2     ),                       
    .Ind_SrcB_q0    (Ind_SrcB_q0     ),
    .Imod_Dest_q0   (Imod_Dest_q0    ),                       
    .Imod_Dest_q2   (Imod_Dest_q2    ),                       
    .Imod_SrcA_q0   (Imod_SrcA_q0    ),                       
    .Imod_SrcB_q0   (Imod_SrcB_q0    ),                       
    .Ind_SrcB_q2    (Ind_SrcB_q2      ),                      
    .Size_SrcB_q2   (Size_SrcB_q2     ),
    .Sext_SrcB_q2   (Sext_SrcB_q2     ),                      
    .OPsrc32_q0     (OPsrc32_q0[31:0] ),                      
    .Ind_Dest_q0    (Ind_Dest_q0      ),                      
    .Dest_addrs_q2  (tr0_Dest_addrs_q2[17:0]),                
    .SrcA_addrs_q0  (tr0_SrcA_addrs_q0[17:0]),                
    .SrcB_addrs_q0  (tr0_SrcB_addrs_q0[17:0]),                
    .SrcA_addrs_q1  (SrcA_addrs_q1[17:0]),                    
    .SrcB_addrs_q1  (SrcB_addrs_q1[17:0]),                    
    .SrcA_addrs_q2  (SrcA_addrs_q2[17:0]),                    
    .PC             (tr0_PC[15:0]     ),                      
    .V_q2           (V_q2             ),                      
    .N_q2           (N_q2             ),                      
    .C_q2           (C_q2             ),                      
    .Z_q2           (Z_q2             ),                      
    .V              (tr0_V            ),                      
    .N              (tr0_N            ),                      
    .C              (tr0_C            ),                      
    .Z              (tr0_Z            ),                      
    .IRQ            (tr0_IRQ          ),                      
    .done           (tr0_done         ),                      
    .inexact        (tr0_inexact      ),                                       
    .invalid        (tr0_invalid      ),                      
    .divby0         (tr0_divby0       ),                      
    .overflow       (tr0_overflow     ),                      
    .underflow      (tr0_underflow    ),                      
    .IRQ_IE         (tr0_IRQ_IE       ),                      
    .break_q0       (break_q0         ),                       
    .rddataA_integer(rddataA_integer[63:0]),                  
    .rddataB_integer(rddataB_integer[63:0]),                  
    .MON_SrcA_data  (mon_write_reg    ), 
    .mon_srcA_data_capture(tr0_mon_rd_reg),                            
    .C_reg          (tr0_C_reg        ),                                 
    .exc_codeA      (exc_codeA        ),                      
    .exc_codeB      (exc_codeB        ),                      
    .float_rddataA  (float_rddataA    ),                      
    .float_rddataB  (float_rddataB    ),                      
    .invalid_del    (tr0_invalid_del  ),                      
    .divby0_del     (tr0_divby0_del   ),                      
    .overflow_del   (tr0_overflow_del ),                      
    .underflow_del  (tr0_underflow_del),                      
    .inexact_del    (tr0_inexact_del  ),                      
    .alt_del_nxact  (tr0_alt_del_nxact),                      
    .alt_del_unfl   (tr0_alt_del_unfl ),                      
    .alt_del_ovfl   (tr0_alt_del_ovfl ),                      
    .alt_del_div0   (tr0_alt_del_div0 ),                      
    .alt_del_inv    (tr0_alt_del_inv  ),                      
    .RM_q1          (RM_q1            ),                       
    .pc_q1          (pc_q1            ),                      
    .fp_ready_q1    (fp_ready_q1      ),                             
    .int_in_service (tr0_int_in_service)            
    );                                                        
                                                              
thread_unit thread1 (
    .CLK            (CLK             ),
    .RESET          (RESET           ),
    .newthreadq_sel (newthreadq==2'b01),
    .thread_q1_sel  (thread_q1==2'b01),
    .thread_q2_sel  (thread_q2==2'b01),
    .thread_q1      (thread_q1       ),           
    .wrsrcAdataSext (wrsrcAdataSext  ),  
    .wrsrcAdata     (wrsrcAdata      ),  
    .rdSrcAdataT    (tr1_rdSrcAdata  ),
    .rdSrcBdata     (tr1_rdSrcBdata  ),
    .priv_RAM_rddataA (priv_RAM_rddataA[63:0]),                      
    .priv_RAM_rddataB (priv_RAM_rddataB[63:0]),                      
    .glob_RAM_rddataA (glob_RAM_rddataA[63:0]),                      
    .glob_RAM_rddataB (glob_RAM_rddataB[63:0]),                      
    .Table_data     (Table_data[63:0]),
    .ld_vector      (tr1_ld_vector   ),
    .rewind_PC      (tr1_rewind_PC   ),
    .wrcycl         (wrcycl          ),
    .discont_out    (tr1_discont     ),
    .OPsrcA_q0      (OPsrcA_q0[15:0] ),
    .OPsrcA_q2      (OPsrcA_q2[15:0]  ),
    .OPsrcB_q0      (OPsrcB_q0[15:0] ),
    .OPsrcB_q2      (OPsrcB_q2[15:0] ),
    .OPdest_q0      (OPdest_q0[15:0] ),
    .OPdest_q2      (OPdest_q2[15:0] ),
    .RPT_not_z      (tr1_RPT_not_z   ),
    .next_PC        (next_PC[15:0]   ),
    .Dam_q0         (Dam_q0[1:0]     ),
    .Dam_q1         (Dam_q1[1:0]     ),             
    .Dam_q2         (Dam_q2[1:0]     ),
    .Ind_Dest_q2    (Ind_Dest_q2     ),
    .Ind_SrcA_q0    (Ind_SrcA_q0     ),
    .Ind_SrcA_q2    (Ind_SrcA_q2     ),
    .Ind_SrcB_q0    (Ind_SrcB_q0     ),
    .Imod_Dest_q0   (Imod_Dest_q0    ),                       
    .Imod_Dest_q2   (Imod_Dest_q2    ),
    .Imod_SrcA_q0   (Imod_SrcA_q0    ),
    .Imod_SrcB_q0   (Imod_SrcB_q0    ),
    .Ind_SrcB_q2    (Ind_SrcB_q2      ),
    .Size_SrcB_q2   (Size_SrcB_q2     ),
    .Sext_SrcB_q2   (Sext_SrcB_q2     ),
    .OPsrc32_q0     (OPsrc32_q0[31:0] ),
    .Ind_Dest_q0    (Ind_Dest_q0      ),    
    .Dest_addrs_q2  (tr1_Dest_addrs_q2[17:0]),
    .SrcA_addrs_q0  (tr1_SrcA_addrs_q0[17:0]),
    .SrcB_addrs_q0  (tr1_SrcB_addrs_q0[17:0]),
    .SrcA_addrs_q1  (SrcA_addrs_q1[17:0]),
    .SrcB_addrs_q1  (SrcB_addrs_q1[17:0]),
    .SrcA_addrs_q2  (SrcA_addrs_q2[17:0]),                   
    .PC             (tr1_PC[15:0]     ),
    .V_q2           (V_q2             ),
    .N_q2           (N_q2             ),
    .C_q2           (C_q2             ),
    .Z_q2           (Z_q2             ),
    .V              (tr1_V            ),
    .N              (tr1_N            ),
    .C              (tr1_C            ),
    .Z              (tr1_Z            ),
    .IRQ            (tr1_IRQ          ),
    .done           (tr1_done         ),
    .inexact        (tr1_inexact      ),                            
    .invalid        (tr1_invalid      ),
    .divby0         (tr1_divby0       ),
    .overflow       (tr1_overflow     ),
    .underflow      (tr1_underflow    ),
    .IRQ_IE         (tr1_IRQ_IE       ),
    .break_q0       (break_q0         ),          
    .rddataA_integer(rddataA_integer[63:0]),
    .rddataB_integer(rddataB_integer[63:0]),
    .MON_SrcA_data  (mon_write_reg    ),                                                                                  
    .mon_srcA_data_capture(tr1_mon_rd_reg),
    .C_reg          (tr1_C_reg        ),                                                                                  
    .exc_codeA      (exc_codeA        ), 
    .exc_codeB      (exc_codeB        ),
    .float_rddataA  (float_rddataA    ),
    .float_rddataB  (float_rddataB    ),
    .invalid_del    (tr1_invalid_del  ),
    .divby0_del     (tr1_divby0_del   ),
    .overflow_del   (tr1_overflow_del ),
    .underflow_del  (tr1_underflow_del),
    .inexact_del    (tr1_inexact_del  ),
    .alt_del_nxact  (tr1_alt_del_nxact),
    .alt_del_unfl   (tr1_alt_del_unfl ),
    .alt_del_ovfl   (tr1_alt_del_ovfl ),
    .alt_del_div0   (tr1_alt_del_div0 ),
    .alt_del_inv    (tr1_alt_del_inv  ),
    .RM_q1          (RM_q1            ),          
    .pc_q1          (pc_q1            ),
    .fp_ready_q1    (fp_ready_q1      ),                
    .int_in_service (tr1_int_in_service)            
    );
    
thread_unit thread2 (
    .CLK            (CLK             ),
    .RESET          (RESET           ),
    .newthreadq_sel (newthreadq==2'b10),
    .thread_q1_sel  (thread_q1==2'b10),
    .thread_q2_sel  (thread_q2==2'b10),
    .thread_q1      (thread_q1       ),           
    .wrsrcAdataSext (wrsrcAdataSext  ),  
    .wrsrcAdata    (wrsrcAdata      ),  
    .rdSrcAdataT     (tr2_rdSrcAdata  ),
    .rdSrcBdata     (tr2_rdSrcBdata  ),
    .priv_RAM_rddataA (priv_RAM_rddataA[63:0]),                      
    .priv_RAM_rddataB (priv_RAM_rddataB[63:0]),                      
    .glob_RAM_rddataA (glob_RAM_rddataA[63:0]),                      
    .glob_RAM_rddataB (glob_RAM_rddataB[63:0]),                      
    .Table_data     (Table_data[63:0]),
    .ld_vector      (tr2_ld_vector   ),
    .rewind_PC      (tr2_rewind_PC   ),
    .wrcycl         (wrcycl          ),
    .discont_out    (tr2_discont     ),
    .OPsrcA_q0      (OPsrcA_q0[15:0] ),
    .OPsrcA_q2      (OPsrcA_q2[15:0]  ),
    .OPsrcB_q0      (OPsrcB_q0[15:0] ),
    .OPsrcB_q2      (OPsrcB_q2[15:0] ),
    .OPdest_q0      (OPdest_q0[15:0] ),
    .OPdest_q2      (OPdest_q2[15:0] ),
    .RPT_not_z      (tr2_RPT_not_z   ),
    .next_PC        (next_PC[15:0]   ),
    .Dam_q0         (Dam_q0[1:0]     ),
    .Dam_q1         (Dam_q1[1:0]     ),             
    .Dam_q2         (Dam_q2[1:0]     ),
    .Ind_Dest_q2    (Ind_Dest_q2     ),
    .Ind_SrcA_q0    (Ind_SrcA_q0     ),
    .Ind_SrcA_q2    (Ind_SrcA_q2     ),
    .Ind_SrcB_q0    (Ind_SrcB_q0     ),
    .Imod_Dest_q0   (Imod_Dest_q0    ),                       
    .Imod_Dest_q2   (Imod_Dest_q2    ),
    .Imod_SrcA_q0   (Imod_SrcA_q0    ),
    .Imod_SrcB_q0   (Imod_SrcB_q0    ),
    .Ind_SrcB_q2    (Ind_SrcB_q2      ),
    .Size_SrcB_q2   (Size_SrcB_q2     ),
    .Sext_SrcB_q2   (Sext_SrcB_q2     ),
    .OPsrc32_q0     (OPsrc32_q0[31:0] ),
    .Ind_Dest_q0    (Ind_Dest_q0      ),    
    .Dest_addrs_q2  (tr2_Dest_addrs_q2[17:0]),
    .SrcA_addrs_q0  (tr2_SrcA_addrs_q0[17:0]),
    .SrcB_addrs_q0  (tr2_SrcB_addrs_q0[17:0]),
    .SrcA_addrs_q1  (SrcA_addrs_q1[17:0]),
    .SrcB_addrs_q1  (SrcB_addrs_q1[17:0]),
    .SrcA_addrs_q2  (SrcA_addrs_q2[17:0]),                   
    .PC             (tr2_PC[15:0]    ),
    .V_q2           (V_q2            ),
    .N_q2           (N_q2            ),
    .C_q2           (C_q2            ),
    .Z_q2           (Z_q2            ),
    .V              (tr2_V           ),
    .N              (tr2_N           ),
    .C              (tr2_C           ),
    .Z              (tr2_Z           ),
    .IRQ            (tr2_IRQ         ),
    .done           (tr2_done        ),
    .inexact        (tr2_inexact     ),                            
    .invalid        (tr2_invalid     ),
    .divby0         (tr2_divby0      ),
    .overflow       (tr2_overflow    ),
    .underflow      (tr2_underflow   ),
    .IRQ_IE         (tr2_IRQ_IE      ),
    .break_q0       (break_q0        ),          
    .rddataA_integer(rddataA_integer[63:0]),
    .rddataB_integer(rddataB_integer[63:0]),
    .MON_SrcA_data  (mon_write_reg    ),     
    .mon_srcA_data_capture(tr2_mon_rd_reg),
    .C_reg          (tr2_C_reg        ),   
    .exc_codeA      (exc_codeA        ), 
    .exc_codeB      (exc_codeB        ),
    .float_rddataA  (float_rddataA    ),
    .float_rddataB  (float_rddataB    ),
    .invalid_del    (tr2_invalid_del  ),
    .divby0_del     (tr2_divby0_del   ),
    .overflow_del   (tr2_overflow_del ),
    .underflow_del  (tr2_underflow_del),
    .inexact_del    (tr2_inexact_del  ),   
    .alt_del_nxact  (tr2_alt_del_nxact),
    .alt_del_unfl   (tr2_alt_del_unfl ),
    .alt_del_ovfl   (tr2_alt_del_ovfl ),
    .alt_del_div0   (tr2_alt_del_div0 ),
    .alt_del_inv    (tr2_alt_del_inv  ),
    .RM_q1          (RM_q1            ),      
    .pc_q1          (pc_q1            ),
    .fp_ready_q1    (fp_ready_q1      ),            
    .int_in_service (tr2_int_in_service)            
    );

thread_unit thread3 (
    .CLK            (CLK             ),
    .RESET          (RESET           ),
    .newthreadq_sel (newthreadq==2'b11),
    .thread_q1_sel  (thread_q1==2'b11),
    .thread_q2_sel  (thread_q2==2'b11),
    .thread_q1      (thread_q1       ),           
    .wrsrcAdataSext (wrsrcAdataSext  ),  
    .wrsrcAdata     (wrsrcAdata      ),  
    .rdSrcAdataT    (tr3_rdSrcAdata  ),
    .rdSrcBdata     (tr3_rdSrcBdata  ),
    .priv_RAM_rddataA (priv_RAM_rddataA[63:0]),                      
    .priv_RAM_rddataB (priv_RAM_rddataB[63:0]),                      
    .glob_RAM_rddataA (glob_RAM_rddataA[63:0]),                      
    .glob_RAM_rddataB (glob_RAM_rddataB[63:0]),                      
    .Table_data     (Table_data[63:0]),
    .ld_vector      (tr3_ld_vector   ),
    .rewind_PC      (tr3_rewind_PC   ),
    .wrcycl         (wrcycl          ),
    .discont_out    (tr3_discont     ),
    .OPsrcA_q0      (OPsrcA_q0[15:0] ),
    .OPsrcA_q2      (OPsrcA_q2[15:0]  ),
    .OPsrcB_q0      (OPsrcB_q0[15:0] ),
    .OPsrcB_q2      (OPsrcB_q2[15:0] ),
    .OPdest_q0      (OPdest_q0[15:0] ),
    .OPdest_q2      (OPdest_q2[15:0] ),
    .RPT_not_z      (tr3_RPT_not_z   ),
    .next_PC        (next_PC[15:0]   ),
    .Dam_q0         (Dam_q0[1:0]     ),
    .Dam_q1         (Dam_q1[1:0]     ),             
    .Dam_q2         (Dam_q2[1:0]     ),
    .Ind_Dest_q2    (Ind_Dest_q2     ),
    .Ind_SrcA_q0    (Ind_SrcA_q0     ),
    .Ind_SrcA_q2    (Ind_SrcA_q2     ),
    .Ind_SrcB_q0    (Ind_SrcB_q0     ),
    .Imod_Dest_q0   (Imod_Dest_q0    ),                       
    .Imod_Dest_q2   (Imod_Dest_q2    ),
    .Imod_SrcA_q0   (Imod_SrcA_q0    ),
    .Imod_SrcB_q0   (Imod_SrcB_q0    ),
    .Ind_SrcB_q2    (Ind_SrcB_q2      ),
    .Size_SrcB_q2   (Size_SrcB_q2     ),
    .Sext_SrcB_q2   (Sext_SrcB_q2     ),
    .OPsrc32_q0     (OPsrc32_q0[31:0] ),
    .Ind_Dest_q0    (Ind_Dest_q0      ),
    .Dest_addrs_q2  (tr3_Dest_addrs_q2[17:0]),
    .SrcA_addrs_q0  (tr3_SrcA_addrs_q0[17:0]),
    .SrcB_addrs_q0  (tr3_SrcB_addrs_q0[17:0]),
    .SrcA_addrs_q1  (SrcA_addrs_q1[17:0]),
    .SrcB_addrs_q1  (SrcB_addrs_q1[17:0]),
    .SrcA_addrs_q2  (SrcA_addrs_q2[17:0]),                   
    .PC             (tr3_PC[15:0]    ),
    .V_q2           (V_q2            ),
    .N_q2           (N_q2            ),
    .C_q2           (C_q2            ),
    .Z_q2           (Z_q2            ),
    .V              (tr3_V           ),
    .N              (tr3_N           ),
    .C              (tr3_C           ),
    .Z              (tr3_Z           ),
    .IRQ            (tr3_IRQ         ),
    .done           (tr3_done        ),
    .inexact        (tr3_inexact     ),                            
    .invalid        (tr3_invalid     ),
    .divby0         (tr3_divby0      ),
    .overflow       (tr3_overflow    ),
    .underflow      (tr3_underflow   ),
    .IRQ_IE         (tr3_IRQ_IE      ),
    .break_q0       (break_q0        ),          
    .rddataA_integer(rddataA_integer[63:0]),
    .rddataB_integer(rddataB_integer[63:0]),
    .MON_SrcA_data  (mon_write_reg    ),     
    .mon_srcA_data_capture(tr3_mon_rd_reg),
    .C_reg          (tr3_C_reg        ),    
    .exc_codeA      (exc_codeA        ), 
    .exc_codeB      (exc_codeB        ),
    .float_rddataA  (float_rddataA    ),
    .float_rddataB  (float_rddataB    ),
    .invalid_del    (tr3_invalid_del  ),
    .divby0_del     (tr3_divby0_del   ),
    .overflow_del   (tr3_overflow_del ),
    .underflow_del  (tr3_underflow_del),
    .inexact_del    (tr3_inexact_del  ),
    .alt_del_nxact  (tr3_alt_del_nxact),
    .alt_del_unfl   (tr3_alt_del_unfl ),                                                                      
    .alt_del_ovfl   (tr3_alt_del_ovfl ),                                                                      
    .alt_del_div0   (tr3_alt_del_div0 ),                                                                      
    .alt_del_inv    (tr3_alt_del_inv  ),                                                                      
    .RM_q1          (RM_q1            ),                                                                      
    .pc_q1          (pc_q1            ),                                                                      
    .fp_ready_q1    (fp_ready_q1      ),
    .int_in_service (tr3_int_in_service)            
    );
    
ram4kx64 #(.ADDRS_WIDTH(12), .DATA_WIDTH(64))       //dword addressable for program storage
    rom0(      //program memory for threads 0-3
    .CLK       (CLK ),
    .wren      (h_wren && (h_wraddrs[17:15]==3'b111)),
    .wraddrs   (h_wraddrs[14:3]),
    .wrdata    (h_wrdata),
    .rdenA     (rdcycl ),
    .rdaddrsA  (pre_PC[11:0] ),
    .rddataA   (Instruction_q0),
    .rdenB     (h_rom_rdsel ? 1'b1 : (rdcycl && (Dam_q0[1:0]==2'b10))),
    .rdaddrsB  (h_rom_rdsel ? h_rdaddrs[14:3] : SrcA_addrs_q0[11:0]),
    .rddataB   (Table_data[63:0])
    ); 
    
RAM4kx64_byte ram0(    //byte-addressable  this RAM block occupies first 8k bytes of a thread's private memory
    .CLK       (CLK   ),
    .RESET     (RESET ),
    .wren      (wrcycl && (Dest_addrs_q2[17:15]==3'b000)),
    .wrsize    (Size_Dest_q2),
    .wraddrs   ({thread_q2, Dest_addrs_q2[12:0]}),
    .wrdata    (wrsrcAdataSext),
    .rdenA     (SrcA_addrs_q0[17:15]==3'b000),
    .rdAsize   (Size_SrcA_q0),
    .rdaddrsA  ({newthreadq, SrcA_addrs_q0[12:0]}),
    .rddataA   (priv_RAM_rddataA[63:0]),
    .rdenB     (SrcB_addrs_q0[17:15]==3'b000),
    .rdBsize   (Size_SrcB_q0),
    .rdaddrsB  ({newthreadq, SrcB_addrs_q0[12:0]}),
    .rddataB   (priv_RAM_rddataB[63:0])
    );    
                                                                 
RAM4kx64_byte ram1( 
    .CLK       (CLK   ),
    .RESET     (RESET ),
    .wren      (h_ram_wrsel ? 1'b1 : (wrcycl && (Dest_addrs_q2[17:15]==3'b010))),
    .wrsize    (h_ram_wrsel ? h_wrsize : Size_Dest_q2),
    .wraddrs   (h_ram_wrsel ? h_wraddrs[14:0] : Dest_addrs_q2[14:0]),
    .wrdata    (h_ram_wrsel ? h_wrdata : wrsrcAdataSext),
    .rdenA     (SrcA_addrs_q0[17:15]==3'b010),
    .rdAsize   (Size_SrcA_q0),
    .rdaddrsA  (SrcA_addrs_q0[14:0]),
    .rddataA   (glob_RAM_rddataA[63:0]),
    .rdenB     (h_ram_rdsel ? 1'b1 : (SrcB_addrs_q0[17:15]==3'b010)),
    .rdBsize   (h_ram_rdsel ? h_rdsize : Size_SrcB_q0),
    .rdaddrsB  (h_ram_rdsel ? h_rdaddrs[14:0] : SrcB_addrs_q0[14:0]),
    .rddataB   (glob_RAM_rddataB[63:0])
    );    
    
sched_stack sched_stack(
    .CLK       (CLK      ),
    .RESET     (RESET    ),
    .sched_3   (sched_3  ),
    .sched_2   (sched_2  ),
    .sched_1   (sched_1  ),
    .sched_0   (sched_0  ),
    .sched_3q  (sched_3q ),
    .sched_2q  (sched_2q ),
    .sched_1q  (sched_1q ),
    .sched_0q  (sched_0q )
    );  

            
integr_logic integr_logic(
    .CLK        (CLK          ),
    .RESET      (RESET        ),
    .wren       (wrcycl && (Dest_addrs_q2[17:12]==6'b00_1101)),    // A[15:12]==4'b1101 && wrcycl && ~Ind_Dest_q2
    .Size_Dest_q1(Size_Dest_q1),
    .wraddrs    ({thread_q2, Dest_addrs_q2[6:3]} ),    // A[11:7] is operator select, A[6:3] is result buffer select
    .operatr_q2 (Dest_addrs_q2[11:7]),   
    .oprndA     (wrsrcAdataSext[63:0]),
    .oprndB     (wrsrcBdataSext[63:0]),
    .tr0_C      (tr0_C        ),
    .tr0_V      (tr0_V        ),
    .tr0_N      (tr0_N        ),
    .tr0_Z      (tr0_Z        ),
    .tr1_C      (tr1_C        ),
    .tr1_V      (tr1_V        ),
    .tr1_N      (tr1_N        ),
    .tr1_Z      (tr1_Z        ),
    .tr2_C      (tr2_C        ),
    .tr2_V      (tr2_V        ),
    .tr2_N      (tr2_N        ),
    .tr2_Z      (tr2_Z        ),
    .tr3_C      (tr3_C        ),
    .tr3_V      (tr3_V        ),
    .tr3_N      (tr3_N        ),
    .tr3_Z      (tr3_Z        ),
    .rdenA      (~&Dam_q0[1:0] && (SrcA_addrs_q0[17:12]==6'b00_1101)),
    .Size_SrcA_q1(Size_SrcA_q1),
    .rdaddrsA   ({newthreadq, SrcA_addrs_q0[6:3]}),    //A[11:7] is operator select, A[6:3] is result buffer select
    .operatrA_q0(SrcA_addrs_q0[11:7]),
    .rddataA    (rddataA_integer),
    .rdenB      (~&Dam_q0[1:0] && (SrcB_addrs_q0[17:12]==6'b00_1101)),
    .Size_SrcB_q1(Size_SrcB_q1),
    .rdaddrsB   ({newthreadq, SrcB_addrs_q0[6:3]}),    //A[11:7] is operator select, A[6:3] is result buffer select
    .operatrB_q0(SrcB_addrs_q0[11:7]),
    .rddataB    (rddataB_integer),
    .ready_q1   (ready_integer_q1)
    );
    

always @(*) begin
    casex (newthreadq)
        2'b00 : next_PC = tr0_PC + ((tr0_RPT_not_z && ~tr0_int_in_service) ? 1'b0 : 1'b1);
        2'b01 : next_PC = tr1_PC + ((tr1_RPT_not_z && ~tr1_int_in_service) ? 1'b0 : 1'b1);
        2'b10 : next_PC = tr2_PC + ((tr2_RPT_not_z && ~tr2_int_in_service) ? 1'b0 : 1'b1);
        2'b11 : next_PC = tr3_PC + ((tr3_RPT_not_z && ~tr3_int_in_service) ? 1'b0 : 1'b1);
    endcase  
end


always @(*) begin
    casex (thread_q2)
        2'b00 : Dest_addrs_q2 = tr0_Dest_addrs_q2;
        2'b01 : Dest_addrs_q2 = tr1_Dest_addrs_q2;
        2'b10 : Dest_addrs_q2 = tr2_Dest_addrs_q2;
        2'b11 : Dest_addrs_q2 = tr3_Dest_addrs_q2;
    endcase  
end

always @(*) begin
    casex (newthreadq)
        2'b00 : SrcA_addrs_q0 = tr0_SrcA_addrs_q0;
        2'b01 : SrcA_addrs_q0 = tr1_SrcA_addrs_q0;
        2'b10 : SrcA_addrs_q0 = tr2_SrcA_addrs_q0;
        2'b11 : SrcA_addrs_q0 = tr3_SrcA_addrs_q0;
    endcase  
end

always @(*) begin
    casex (newthreadq)
        2'b00 : SrcB_addrs_q0 = tr0_SrcB_addrs_q0;
        2'b01 : SrcB_addrs_q0 = tr1_SrcB_addrs_q0;
        2'b10 : SrcB_addrs_q0 = tr2_SrcB_addrs_q0;
        2'b11 : SrcB_addrs_q0 = tr3_SrcB_addrs_q0;
    endcase  
end


always @(*) begin
    if (RESET || ~STATE[0]) pre_PC = 16'h0100;
    else if (LD_newthread)
       case (newthread) 
           2'b00 : pre_PC = tr0_PC;
           2'b01 : pre_PC = tr1_PC;
           2'b10 : pre_PC = tr2_PC;
           2'b11 : pre_PC = tr3_PC;
       endcase
    else if ((OPdest_q2[15:0]==PC_ADDRS[15:0]) && wrcycl && ~Ind_Dest_q2) pre_PC = wrsrcAdataSext[15:0];  //absolute jump
    else if (((OPdest_q2[15:0]==BTBS_ADDRS[15:0]) || (OPdest_q2[15:0]==BTBC_ADDRS[15:0])) && |(bitsel & wrsrcAdata)  && ~Ind_Dest_q2)  pre_PC = pc_q2 + {{2{OPdest_q2[13]}}, OPdest_q2[13:0]};  //relative branch
    else pre_PC = next_PC;
end    

    
always @(*) begin 
    if (RESET) begin
        newthread = 2'b00;
        LD_newthread = 1'b0;
    end  
    
    else if (sched_0q && |newthreadq) begin   //if already in thread0, don't do anything
        newthread = 2'b00;
        LD_newthread = 1'b1;    
    end  
    else if (sched_1q && ~(newthreadq == 2'b01)) begin //if already in thread1, don't do anything
        newthread = 2'b01;
        LD_newthread = 1'b1;    
    end  
    else if (sched_2q && ~(newthreadq == 2'b10)) begin //if already in thread2, don't do anything
        newthread = 2'b10;
        LD_newthread = 1'b1;    
    end  
    else if (sched_3q && ~(newthreadq == 2'b11)) begin //if already in thread3, don't do anything
        newthread = 2'b11;
        LD_newthread = 1'b1;    
    end  
    else begin
         newthread = 2'b00; 
       LD_newthread = 1'b0;
    end       
end

always @(*) begin
     casex (thread_q1)
         2'b00 : begin
                     rdSrcAdata = tr0_rdSrcAdata;
                     rdSrcBdata = tr0_rdSrcBdata;
                 end
         2'b01 : begin
                     rdSrcAdata = tr1_rdSrcAdata;
                     rdSrcBdata = tr1_rdSrcBdata;
                 end
         2'b10 : begin
                     rdSrcAdata = tr2_rdSrcAdata;
                     rdSrcBdata = tr2_rdSrcBdata;
                 end
         2'b11 : begin
                     rdSrcAdata = tr3_rdSrcAdata;
                     rdSrcBdata = tr3_rdSrcBdata;
                 end
      endcase            
end
                  
always @(*) begin
    if (Sext_Dest_q2 || Sext_SrcA_q2)
        casex (sextA_sel)
            4'b0100,
            4'b1000,
            4'b1100 :  if (wrsrcAdata[7]) wrsrcAdataSext[63:0] = {56'hFFFF_FFFF_FFFF_FF, wrsrcAdata[7:0]};
                       else wrsrcAdataSext[63:0] = wrsrcAdata[63:0];
            4'b1001,
            4'b1101 :  if (wrsrcAdata[15]) wrsrcAdataSext[63:0] = {48'hFFFF_FFFF_FFFF, wrsrcAdata[15:0]};
                       else wrsrcAdataSext[63:0] = wrsrcAdata[63:0];
                       
            4'b1110 :  if (wrsrcAdata[31]) wrsrcAdataSext[63:0] = {32'hFFFF_FFFF, wrsrcAdata[31:0]};
                       else wrsrcAdataSext[63:0] = wrsrcAdata[63:0];
             default: wrsrcAdataSext[63:0] = wrsrcAdata[63:0]; 
        endcase
     else  wrsrcAdataSext[63:0] = wrsrcAdata[63:0];
end                           

always @(*) begin
    if (Sext_Dest_q2 || Sext_SrcB_q2)
        casex (sextB_sel)
            4'b0100,
            4'b1000,
            4'b1100 :  if (wrsrcBdata[7]) wrsrcBdataSext[31:0] = {56'hFFFF_FFFF_FFFF_FF, wrsrcBdata[7:0]};
                       else wrsrcBdataSext[63:0] = wrsrcBdata[63:0];
            4'b1001,
            4'b1101 :  if (wrsrcBdata[15]) wrsrcBdataSext[63:0] = {48'hFFFF_FFFF_FFFF, wrsrcBdata[15:0]};
                       else wrsrcBdataSext[63:0] = wrsrcBdata[63:0];
                       
            4'b1110 :  if (wrsrcBdata[31]) wrsrcBdataSext[63:0] = {32'hFFFF_FFFF, wrsrcBdata[31:0]};
                       else wrsrcBdataSext[63:0] = wrsrcBdata[63:0];
             default: wrsrcBdataSext[63:0] = wrsrcBdata[63:0]; 
        endcase
     else  wrsrcBdataSext[63:0] = wrsrcBdata[63:0];
end                           

always @(posedge CLK) RESET <= RESET_IN;

 
always @(posedge CLK or posedge RESET) begin                                                                     
    if (RESET) begin                                                                                             
        PC[15:0] <= 16'h0100;                                                                                                         
        // state 1 fetch                                                                                         
        thread_q1[1:0]      <= 2'b00; 
        pc_q1[15:0]         <= 15'h0100;                                                                               
        Dam_q1[1:0]         <= 2'b00;                         
        SrcA_addrs_q1[17:0] <= 18'h0000;                                                                                
        SrcB_addrs_q1[17:0] <= 18'h0000;                                                              
        OPdest_q1[15:0]     <= 16'h0000;                                                                        
        OPsrcA_q1[15:0]     <= 16'h0000;                                                                        
        OPsrcB_q1[15:0]     <= 16'h0000;                                                                        
        RM_q1[1:0]          <= 2'b00;  
        Sext_Dest_q1        <= 1'b0;
        Size_Dest_q1[1:0]   <= 2'b00;
        Ind_Dest_q1         <= 1'b0;
        Imod_Dest_q1        <= 1'b0;
        Sext_SrcA_q1        <= 1'b0;
        Size_SrcA_q1[1:0]   <= 2'b00;
        Ind_SrcA_q1         <= 1'b0; 
        Imod_SrcA_q1        <= 1'b0;
        Sext_SrcB_q1        <= 1'b0;
        Size_SrcB_q1[1:0]   <= 2'b00;
        Ind_SrcB_q1         <= 1'b0; 
        Imod_SrcB_q1        <= 1'b0;                                                                                                                 
                                                                                                                  
        // state2 read                                                                                             
        thread_q2[1:0]      <= 2'b00; 
        pc_q2[15:0]         <= 15'h0100;                                                                 
        Dam_q2[1:0]         <= 2'b00;           
        SrcA_addrs_q2[17:0] <= 18'h0000;                                                                         
        SrcB_addrs_q2[17:0] <= 18'h0000;                                                       
        OPdest_q2[15:0]     <= 16'h0000;                                                              
        OPsrcA_q2[15:0]     <= 16'h0000;                                                              
        OPsrcB_q2[15:0]     <= 16'h0000;                                                              
        RM_q2[1:0]          <= 2'b00;  
        Sext_Dest_q2        <= 1'b0;
        Size_Dest_q2[1:0]   <= 2'b00;
        Ind_Dest_q2         <= 1'b0;
        Imod_Dest_q2        <= 1'b0;
        Sext_SrcA_q2        <= 1'b0;
        Size_SrcA_q2[1:0]   <= 2'b00;
        Ind_SrcA_q2         <= 1'b0; 
        Imod_SrcA_q2        <= 1'b0;
        Sext_SrcB_q2        <= 1'b0;
        Size_SrcB_q2[1:0]   <= 2'b00;
        Ind_SrcB_q2         <= 1'b0; 
        Imod_SrcB_q2        <= 1'b0;                                                                                                    
                                                                                                      
        STATE <= 6'b100000;                                                                               
                                                                                                        
        wrsrcAdata[63:0] <= 64'h00000000;
        wrsrcBdata[63:0] <= 64'h00000000;         
                
        newthreadq[1:0] <= 2'b00;

        scheduler[31:0] <= 32'h04040404;     //interleave threads 0-4
        sched_cmp[31:0] <= 32'h04040404;     //interleave threads 0-4

        sched_state[3:0] <= 4'b0001;
                                
        fp_ready_q2 <= 1'b1;
        fp_sel_q2 <= 1'b0;                                                  
        ready_integer_q2 <= 1'b1;                         
        integer_sel_q2 <= 1'b0;
        
                                                                                                                         
        SrcA_addrs_q1[17:0]  <= 18'h0_0000;
        SrcB_addrs_q1[17:0]  <= 18'h0_0000;
                
        C_q2 <= 1'b0;
        V_q2 <= 1'b0;
        N_q2 <= 1'b0;
        Z_q2 <= 1'b0;
    end                                                                                                          
    else begin                                                                                                   
        PC <= pre_PC; 
         
        if (SrcA_addrs_q1[17:12]==6'b001101) begin
            C_q2 <= C_q1;
            V_q2 <= V_q1;
            N_q2 <= N_q1;
            Z_q2 <= Z_q1;
        end
                                                                                                                 
    ///////////////////// fine-grain scheduler /////////////////                                                 
       if (wrcycl && (thread_q2==2'b00) && (Dest_addrs_q2==SCHED_ADDRS)) begin                                                            
          sched_cmp <= wrsrcAdataSext[31:0];                                                                                
          scheduler <= wrsrcAdataSext[31:0];                                                                                
          sched_state <= 5'b00001;                                                                                
       end                                                                                                       
       else  begin      

           if (|sched_cmp[7:0]) begin                                                                            
               if ((scheduler[7:0]==sched_cmp[7:0]) && sched_state[0]) scheduler[7:0] <= 8'h01;
               else if (sched_state[0]) scheduler[7:0] <= scheduler[7:0] + 1'b1;
           end
           if (|sched_cmp[15:8]) begin          
               if ((scheduler[15:8]==sched_cmp[15:8]) && sched_state[1]) scheduler[15:8] <= 8'h01;
               else if (sched_state[1]) scheduler[15:8] <= scheduler[15:8] + 1'b1;
           end    
           if (|sched_cmp[23:16]) begin
               if ((scheduler[23:16]==sched_cmp[23:16]) && sched_state[2]) scheduler[23:16] <= 8'h01;
               else if (sched_state[2]) scheduler[23:16] <= scheduler[23:16] + 1'b1;
           end
           if (|sched_cmp[31:24]) begin
               if ((scheduler[31:24]==sched_cmp[31:24]) && sched_state[3]) scheduler[31:24] <= 8'h01;
               else if (sched_state[3]) scheduler[31:24] <= scheduler[31:24] + 1'b1;
           end
       end
          
       sched_state[3:0] <= {sched_state[2:0], 1'b1};      
                        
       STATE <= {1'b1, STATE[5:1]};    //rotate right 1 into msb  (shift right)
     
           newthreadq[1:0]     <= newthread[1:0]      ;
           RM_q1[1:0]          <= RM_q0[1:0]          ;
           thread_q1[1:0]      <= newthreadq[1:0]     ; 
           pc_q1[15:0]         <= PC[15:0]            ; 
           Dam_q1[1:0]         <= Dam_q0[1:0]         ;                 
           SrcA_addrs_q1       <= SrcA_addrs_q0       ; 
           SrcB_addrs_q1       <= SrcB_addrs_q0       ; 
           OPdest_q1           <= OPdest_q0           ;
           OPsrcA_q1           <= OPsrcA_q0           ;
           OPsrcB_q1           <= OPsrcB_q0           ;
           OPsrc32_q1          <= OPsrc32_q0;
           
           fp_ready_q2         <= fp_ready_q1         ;
           fp_sel_q2           <= fp_sel_q1           ;
           ready_integer_q2    <= ready_integer_q1    ;
           integer_sel_q2      <= integer_sel_q1      ;
           
           thread_q2           <= thread_q1           ; 
           pc_q2               <= pc_q1               ;  
           SrcA_addrs_q2       <= SrcA_addrs_q1       ; 
           SrcB_addrs_q2       <= SrcB_addrs_q1       ; 
           OPdest_q2           <= OPdest_q1           ;
           OPsrcA_q2           <= OPsrcA_q1           ;
           OPsrcB_q2           <= OPsrcB_q1           ;
           
           Sext_Dest_q1        <= Sext_Dest_q0        ;
           Size_Dest_q1[1:0]   <= Size_Dest_q0[1:0]   ;
           Ind_Dest_q1         <= Ind_Dest_q0         ;
           Imod_Dest_q1        <= Imod_Dest_q0        ;
           Sext_SrcA_q1        <= Sext_SrcA_q0        ;
           Size_SrcA_q1[1:0]   <= Size_SrcA_q0[1:0]   ;
           Ind_SrcA_q1         <= Ind_SrcA_q0         ;
           Imod_SrcA_q1        <= Imod_SrcA_q0        ;
           Sext_SrcB_q1        <= Sext_SrcB_q0        ;
           Size_SrcB_q1[1:0]   <= Size_SrcB_q0[1:0]   ;
           Ind_SrcB_q1         <= Ind_SrcB_q0         ;
           Imod_SrcB_q1        <= Imod_SrcB_q0        ;
                                                      
           Sext_Dest_q2        <= Sext_Dest_q1        ;
           Size_Dest_q2[1:0]   <= Size_Dest_q1[1:0]   ;
           Ind_Dest_q2         <= Ind_Dest_q1         ;
           Imod_Dest_q2        <= Imod_Dest_q1        ;
           Sext_SrcA_q2        <= Sext_SrcA_q1        ;
           Size_SrcA_q2[1:0]   <= Size_SrcA_q1[1:0]   ;
           Ind_SrcA_q2         <= Ind_SrcA_q1         ;
           Imod_SrcA_q2        <= Imod_SrcA_q1        ;
           Sext_SrcB_q2        <= Sext_SrcB_q1        ;
           Size_SrcB_q2[1:0]   <= Size_SrcB_q1[1:0]   ;
           Ind_SrcB_q2         <= Ind_SrcB_q1         ;
           Imod_SrcB_q2        <= Imod_SrcB_q1        ;

           case(Dam_q1)     //MOV
               2'b00 : begin    // both srcA and srcB are either direct or indirect
                          wrsrcAdata <= rdSrcAdata;  //rdSrcA expects data here to be zero-extended to 64 bits           
                          wrsrcBdata <= rdSrcBdata;  //rdSrcB expects data here to be zero-extended to 64 bits
                       end
               2'b01 : begin   //srcA is direct or indirect and srcB is 8 or 16-bit immediate
                          if (~Ind_SrcA_q1 && ~|OPsrcA_q1) wrsrcAdata <= {48'h0000_0000_0000, OPsrcB_q1}; //rdSrcA expects data here to be zero-extended to 64 bits
                          else  wrsrcAdata <= rdSrcAdata;
                          wrsrcBdata <= {48'h0000_0000_0000, OPsrcB_q1};    //rdSrcB expects data here to be zero-extended to 64 bits
                       end
               2'b10 : begin  //srcA is table-read and srcB is direct or indirect 
                          wrsrcAdata <= rdSrcAdata;     //rdSrcA expects data here to be zero-extended to 64 bits        
                          wrsrcBdata <= rdSrcBdata;     //rdSrcB expects data here to be zero-extended to 64 bits
                       end
               2'b11 : begin //32-bit immediate       
                          wrsrcAdata <= {32'h0000_0000, OPsrc32_q1[31:0]};   //rdSrcA expects data here to be zero-extended to 64 bits
                       end
           endcase           
          
   end             
end

endmodule
