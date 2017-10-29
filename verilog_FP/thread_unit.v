 // THREAD_UNIT.v
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

module thread_unit(
    CLK,           
    RESET,  
    newthreadq_sel,
    thread_q1_sel,
    thread_q2_sel,
    thread_q1,
    wrsrcAdataSext,   
    wrsrcAdata,
    rdSrcAdataT,    
    rdSrcBdata,
    priv_RAM_rddataA,                      
    priv_RAM_rddataB,                      
    glob_RAM_rddataA,                      
    glob_RAM_rddataB,                      
    Table_data,
    ld_vector,     
    rewind_PC,
    wrcycl,        
    discont_out,    
    OPsrcA_q0,        
    OPsrcA_q2,
    OPsrcB_q0,        
    OPsrcB_q2,     
    OPdest_q0,      
    OPdest_q2, 
    RPT_not_z, 
    next_PC,       
    Dam_q0, 
    Dam_q1,        
    Dam_q2,      
    Ind_Dest_q2, 
    Ind_SrcA_q0,
    Ind_SrcA_q2,    
    Ind_SrcB_q0, 
    Imod_Dest_q0,   
    Imod_Dest_q2,
    Imod_SrcA_q0,   
    Imod_SrcB_q0,   
    Ind_SrcB_q2,
    Size_SrcB_q2,    
    Sext_SrcB_q2,    
    OPsrc32_q0, 
    Ind_Dest_q0,
    Dest_addrs_q2,
    SrcA_addrs_q0,
    SrcB_addrs_q0,
    SrcA_addrs_q1,
    SrcB_addrs_q1,
    SrcA_addrs_q2,
    PC,            
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
    inexact,        
    invalid,       
    divby0,        
    overflow,      
    underflow,     
    IRQ_IE,
    break_q0,
    rddataA_integer,             
    rddataB_integer,
    MON_SrcA_data, // data to be written by monitor R/W instruction
    mon_srcA_data_capture, //data captured by monitor R/W instruction
    C_reg,
    exc_codeA, 
    exc_codeB,
    float_rddataA, 
    float_rddataB,
    invalid_del,  
    divby0_del,   
    overflow_del, 
    underflow_del,
    inexact_del,
    alt_del_nxact,
    alt_del_unfl,
    alt_del_ovfl,
    alt_del_div0,
    alt_del_inv,
    RM_q1,
    pc_q1,
    fp_ready_q1,
    int_in_service       
    );

input  CLK;           
input  RESET; 
input  newthreadq_sel;
input  thread_q1_sel; 
input  thread_q2_sel; 
input  [63:0] wrsrcAdataSext;    
input  [63:0] wrsrcAdata;      
output  ld_vector;     
input  rewind_PC;
input  wrcycl; 
output discont_out;
input  [15:0] OPsrcA_q0;        
input  [15:0] OPsrcA_q2;
input  [15:0] OPsrcB_q0;        
input  [15:0] OPsrcB_q2;     
input  [15:0] OPdest_q0;      
input  [15:0] OPdest_q2;   
output RPT_not_z; 
input  [15:0] next_PC;       
input  [1:0]  Dam_q0;
input  [1:0]  Dam_q1;         
input  [1:0]  Dam_q2;      
input  Ind_Dest_q2; 
input  Ind_SrcA_q0;    
input  Ind_SrcA_q2;
input  Ind_SrcB_q0; 
input  Imod_Dest_q0;   
input  Imod_Dest_q2;
input  Imod_SrcA_q0;   
input  Imod_SrcB_q0;   
input  Ind_SrcB_q2;
input [1:0] Size_SrcB_q2;
input  Sext_SrcB_q2;
input  [31:0] OPsrc32_q0; 
input  Ind_Dest_q0;   
output [17:0] Dest_addrs_q2;        
output [17:0] SrcA_addrs_q0;        
output [17:0] SrcB_addrs_q0; 
input  [17:0] SrcA_addrs_q1;
input  [17:0] SrcB_addrs_q1;
input  [17:0] SrcA_addrs_q2;
output [15:0] PC;                                                                                                         
input  V_q2;                                                            
input  N_q2;                                                            
input  C_q2;          
input  Z_q2;
output V;
output N;
output C;
output Z;
input  IRQ;                                                                 
output done;                                                           
input  inexact;                                                        
input  invalid;                                                         
input  divby0;        
input  overflow;      
input  underflow;     
output IRQ_IE;          
output [63:0] rdSrcAdataT;
output [63:0] rdSrcBdata;
input  [63:0] priv_RAM_rddataA;
input  [63:0] priv_RAM_rddataB;
input  [63:0] glob_RAM_rddataA;
input  [63:0] glob_RAM_rddataB;
input  [63:0] Table_data;
input  break_q0;  
input  [63:0] rddataA_integer;                   
input  [63:0] rddataB_integer;
input  [63:0] MON_SrcA_data;         //from monitor/break/debug block 
output [63:0] mon_srcA_data_capture;
output [63:0] C_reg;
input  [3:0] exc_codeA;
input  [3:0] exc_codeB;
input [31:0] float_rddataA;
input [31:0] float_rddataB;
output invalid_del;  
output divby0_del;   
output overflow_del; 
output underflow_del;
output inexact_del; 
output alt_del_nxact;
output alt_del_unfl; 
output alt_del_ovfl; 
output alt_del_div0; 
output alt_del_inv;  
input [1:0] thread_q1;
input [1:0] RM_q1; 
input [15:0] pc_q1;
input fp_ready_q1;
output int_in_service;

parameter           BTBS_ = 16'hFFA0;   // bit test and branch if set
parameter           BTBC_ = 16'hFF98;   // bit test and branch if clear
parameter           BRAL_ = 16'hFFF8;   // branch relative long
parameter           JMPA_ = 16'hFFA8;   // jump absolute long

parameter      BRAL_ADDRS = 18'h0FFF8;   // branch relative long
parameter      JMPA_ADDRS = 18'h0FFA8;   // jump absolute long
parameter      BTBS_ADDRS = 18'h0FFA0;   // bit test and branch if set
parameter      BTBC_ADDRS = 18'h0FF98;   // bit test and branch if clear

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

parameter  NMI_VECTOR_ADDRS        =  16'hFEF8;
parameter  IRQ_VECTOR_ADDRS        =  16'hFEF0;
parameter  invalid_VECTOR_ADDRS    =  16'hFEE8;
parameter  divby0_VECTOR_ADDRS     =  16'hFEE0;
parameter  overflow_VECTOR_ADDRS   =  16'hFED8;
parameter  underflow_VECTOR_ADDRS  =  16'hFED0;
parameter  inexact_VECTOR_ADDRS    =  16'hFEC8;

reg [63:0] rdSrcAdata;
reg [63:0] rdSrcBdata;

reg [63:0] C_reg;
reg [19:0] timer;
reg [19:0] timercmpr;

reg [11:0] LPCNT1;
reg [11:0] LPCNT0;

reg [15:0] NMI_VECTOR;      
reg [15:0] IRQ_VECTOR;      
reg [15:0] invalid_VECTOR;  
reg [15:0] divby0_VECTOR;   
reg [15:0] overflow_VECTOR; 
reg [15:0] underflow_VECTOR;
reg [15:0] inexact_VECTOR;  

reg [7:0] underflow_QOS; 
reg [7:0] overflow_QOS; 
reg [7:0] divby0_QOS; 
reg [7:0] invalid_QOS;  

reg [63:0] mon_srcA_data_capture;    //write-only and not qualified with wrcycl

wire [63:0] rdSrcAdataT;

wire [11:0] LPCNT1_dec;
wire [11:0] LPCNT0_dec;

wire LPCNT1_nz; 
wire LPCNT0_nz;

wire [10:0] REPEAT; 

wire [63:0] capt_dataA;
wire [63:0] capt_dataB;
wire RPT_not_z;
wire discont_out;

wire [15:0] PC;    
wire [15:0] PC_COPY;
wire        done;  
wire        IRQ_IE;  
wire [31:0] STATUS;
wire [31:0] STATUSq2;
wire [15:0] vector;    

wire [17:0] SP;
wire [17:0] AR6;
wire [17:0] AR5;
wire [17:0] AR4;
wire [17:0] AR3;
wire [17:0] AR2;
wire [17:0] AR1;
wire [17:0] AR0;

wire alt_inv_handl;
wire alt_div0_handl;
wire alt_ovfl_handl;
wire alt_unfl_handl;
wire alt_nxact_handl;

wire alt_del_nxact;
wire alt_del_unfl ;
wire alt_del_ovfl ;
wire alt_del_div0 ;
wire alt_del_inv  ;

wire NMI_ack;
wire EXC_ack;
wire IRQ_ack;
wire EXC_in_service;   
wire invalid_in_service;   
wire divby0_in_service;   
wire overflow_in_service;   
wire underflow_in_service;   
wire inexact_in_service;  

wire invalid_del;  
wire divby0_del;   
wire overflow_del; 
wire underflow_del;
wire inexact_del;  

wire V;
wire N;
wire C;
wire Z;

wire [63:0] rddataA_integer;             
wire [63:0] rddataB_integer; 
wire ready_integer; 

assign LPCNT1_dec = LPCNT1 - 1'b1;
assign LPCNT0_dec = LPCNT0 - 1'b1;

assign LPCNT1_nz = |LPCNT1_dec;
assign LPCNT0_nz = |LPCNT0_dec;

assign rdSrcAdataT = (Dam_q1[1:0]==2'b10) ? Table_data : rdSrcAdata;

exc_capture exc_capt(     // quasi-trace buffer for capturing floating-point exceptions
    .CLK            (CLK        ),
    .RESET          (done   ),
    .srcA_q1        (SrcA_addrs_q1[17:0]    ),
    .srcB_q1        (SrcB_addrs_q1[17:0]    ),
    .addrsMode_q1   (Dam_q1[1:0]  ),
    .dest_q2        (Dest_addrs_q2[17:0] ),
    .pc_q1          (pc_q1      ),
    .rdSrcAdata     (float_rddataA[31:0]),
    .rdSrcBdata     (float_rddataB[31:0]),
    .exc_codeA      (exc_codeA  ),
    .exc_codeB      (exc_codeB  ),
    .rdenA          (~Dam_q0[1] && (SrcA_addrs_q0[17:2]==CREG_ADDRS[17:2])),
    .rdenB          (~Dam_q0[0] && (SrcB_addrs_q0[17:2]==CREG_ADDRS[17:2])),
    .round_mode_q1  (RM_q1           ),
    .ready_in       (fp_ready_q1     ),
    .alt_nxact_handl(alt_nxact_handl ),
    .alt_unfl_handl (alt_unfl_handl  ),
    .alt_ovfl_handl (alt_ovfl_handl  ),
    .alt_div0_handl (alt_div0_handl  ),
    .alt_inv_handl  (alt_inv_handl   ),
    .invalid        (invalid_del     ),
    .divby0         (divby0_del      ),
    .overflow       (overflow_del    ),
    .underflow      (underflow_del   ),
    .inexact        (inexact_del     ),
    .capt_dataA     (capt_dataA      ),
    .capt_dataB     (capt_dataB      ),
    .thread_q1_sel  (thread_q1_sel   ),
    .thread_q1      (thread_q1       )
    );                                      

PROG_ADDRS prog_addrs (
    .CLK           (CLK         ),
    .RESET         (RESET       ),
    .newthreadq_sel(newthreadq_sel),
    .thread_q2_sel (thread_q2_sel ),
    .Ind_Dest_q2   (Ind_Dest_q2 ),
    .Ind_SrcB_q2   (Ind_SrcB_q2 ),
    .Size_SrcB_q2  (Size_SrcB_q2),
    .Sext_SrcB_q2  (Sext_SrcB_q2),
    .OPdest_q2     (OPdest_q2   ),
    .wrsrcAdata    (wrsrcAdata[63:0]),
    .wrsrcAdataSext(wrsrcAdataSext[15:0]),
    .ld_vector     (ld_vector   ),
    .vector        (vector      ),
    .rewind_PC     (rewind_PC   ),
    .wrcycl        (wrcycl      ),
    .discont_out   (discont_out ),
    .OPsrcB_q2     (OPsrcB_q2[15:0]),
    .RPT_not_z     (RPT_not_z   ),
    .next_PC       (next_PC     ),
    .PC            (PC          ),
    .PC_COPY       (PC_COPY     ),
    .break_q0      (break_q0    ),
    .int_in_service(int_in_service)
    );

DATA_ADDRS data_addrs(
    .CLK           (CLK             ),          
    .RESET         (RESET           ),          
    .newthreadq_sel(newthreadq_sel  ),          
    .thread_q2_sel (thread_q2_sel   ),          
    .wrcycl        (wrcycl          ),          
    .wrsrcAdataSext(wrsrcAdataSext[17:0]),
    .Dam_q0        (Dam_q0[1:0]     ),          
    .Dam_q2        (Dam_q2[1:0]     ),          
    .Ind_Dest_q0   (Ind_Dest_q0     ),          
    .Ind_SrcA_q0   (Ind_SrcA_q0     ),                                                  
    .Ind_SrcB_q0   (Ind_SrcB_q0     ),                                                  
    .Imod_Dest_q2  (Imod_Dest_q2    ),                                                  
    .Imod_SrcA_q0  (Imod_SrcA_q0    ),                                                   
    .Imod_SrcB_q0  (Imod_SrcB_q0    ),                                                   
    .OPdest_q0     (OPdest_q0       ),                                                   
    .OPdest_q2     (OPdest_q2       ),          
    .OPsrcA_q0     (OPsrcA_q0       ),          
    .OPsrcB_q0     (OPsrcB_q0       ),          
    .OPsrc32_q0    (OPsrc32_q0      ),  
    .Ind_Dest_q2   (Ind_Dest_q2     ),        
    .Dest_addrs_q2 (Dest_addrs_q2   ),          
    .SrcA_addrs_q0 (SrcA_addrs_q0   ),          
    .SrcB_addrs_q0 (SrcB_addrs_q0   ),           
    . AR0          ( AR0            ),
    . AR1          ( AR1            ),
    . AR2          ( AR2            ),
    . AR3          ( AR3            ),
    . AR4          ( AR4            ),
    . AR5          ( AR5            ),
    . AR6          ( AR6            ),
    . SP           ( SP             )     
    );                            
                                  
STATUS_REG status(
    .CLK           (CLK             ),
    .RESET         (RESET           ),
    .wrcycl        (wrcycl          ),
    .wren          (OPdest_q2[15:0]==ST_ADDRS[15:0] && ~Ind_Dest_q2),
    .thread_q2_sel (thread_q2_sel),
    .wrsrcAdataSext(wrsrcAdataSext[31:0] ),     
    .V_q2          (V_q2            ),
    .N_q2          (N_q2            ),
    .C_q2          (C_q2            ),
    .Z_q2          (Z_q2            ),
    .V             (V               ),
    .N             (N               ),
    .C             (C               ),
    .Z             (Z               ),
    .IRQ           (IRQ             ),
    .done          (done            ),
    .invalid       (invalid         ),
    .alt_inv_handl (alt_inv_handl   ),
    .divby0        (divby0          ),
    .alt_div0_handl(alt_div0_handl  ),
    .overflow      (overflow        ),
    .alt_ovfl_handl(alt_ovfl_handl  ),
    .underflow     (underflow       ),
    .alt_unfl_handl(alt_unfl_handl  ),
    .inexact       (inexact         ),
    .alt_nxact_handl(alt_nxact_handl),
    .alt_del_nxact (alt_del_nxact   ),
    .alt_del_unfl  (alt_del_unfl    ), 
    .alt_del_ovfl  (alt_del_ovfl    ),
    .alt_del_div0  (alt_del_div0    ),
    .alt_del_inv   (alt_del_inv     ),
    .IRQ_IE        (IRQ_IE          ),
    .STATUS        (STATUS          ),
    .STATUSq2      (STATUSq2        ),
    .rd_float_q2_sel ((SrcA_addrs_q2[17:12]==6'b001110) && ~Dam_q2[1]),
    .rd_integr_q2_sel((SrcA_addrs_q2[17:12]==6'b001101) && ~Dam_q2[1])
    );
    
int_cntrl int_cntrl(
    .CLK                  (CLK          ),
    .RESET                (RESET        ),
    .PC                   (PC[15:0]     ),
    .thread_q0_sel        (newthreadq_sel),
    .thread_q1_sel        (thread_q1_sel),
    .thread_q2_sel        (thread_q2_sel),
    .OPsrcA_q2            (OPsrcA_q2    ),
    .OPdest_q2            (OPdest_q2    ),
    .Ind_Dest_q2          (Ind_Dest_q2  ),
    .Ind_SrcA_q2          (Ind_SrcA_q2  ),
    .RPT_not_z            (RPT_not_z    ),
    .NMI                  ((timer==timercmpr) && ~done),
    .inexact_exc          (inexact   && alt_nxact_handl),
    .underflow_exc        (underflow && alt_unfl_handl ),
    .overflow_exc         (overflow  && alt_ovfl_handl ),
    .divby0_exc           (divby0    && alt_div0_handl ),
    .invalid_exc          (invalid   && alt_inv_handl  ),
    .IRQ                  (IRQ          ),
    .IRQ_IE               (IRQ_IE       ),
    .vector               (vector       ),
    .ld_vector            (ld_vector    ),
    .NMI_ack              (NMI_ack      ),
    .EXC_ack              (EXC_ack      ),
    .IRQ_ack              (IRQ_ack      ),
    .EXC_in_service       (EXC_in_service      ),
    .invalid_in_service   (invalid_in_service  ),
    .divby0_in_service    (divby0_in_service   ),
    .overflow_in_service  (overflow_in_service ),
    .underflow_in_service (underflow_in_service),
    .inexact_in_service   (inexact_in_service  ),
    .wrcycl               (wrcycl              ),
    .int_in_service       (int_in_service      ),
    .NMI_VECTOR           (NMI_VECTOR          ),
    .IRQ_VECTOR           (IRQ_VECTOR          ),
    .invalid_VECTOR       (invalid_VECTOR      ),
    .divby0_VECTOR        (divby0_VECTOR       ),
    .overflow_VECTOR      (overflow_VECTOR     ),
    .underflow_VECTOR     (underflow_VECTOR    ),
    .inexact_VECTOR       (inexact_VECTOR      )
    );   
    
REPEAT_reg repeat_reg(
    .CLK           (CLK          ),
    .RESET         (RESET        ),
    .thread_q0_sel (newthreadq_sel),
    .Ind_Dest_q0   (Ind_Dest_q0  ),
    .Ind_SrcA_q0   (Ind_SrcA_q0  ),
    .Ind_SrcB_q0   (Ind_SrcB_q0  ),
    .Imod_Dest_q0  (Imod_Dest_q0 ),
    .Imod_SrcA_q0  (Imod_SrcA_q0 ),
    .Imod_SrcB_q0  (Imod_SrcB_q0 ),
    .OPdest_q0     (OPdest_q0    ),
    .OPsrcB_q0     (OPsrcB_q0    ),
    .RPT_not_z     (RPT_not_z    ),
    .int_in_service(int_in_service),
    .Dam_q0        (Dam_q0[1:0]  ),
    .AR0           (AR0[10:0]    ),
    .AR1           (AR1[10:0]    ),
    .AR2           (AR2[10:0]    ),
    .AR3           (AR3[10:0]    ),
    .AR4           (AR4[10:0]    ),
    .AR5           (AR5[10:0]    ),
    .AR6           (AR6[10:0]    ),
    .REPEAT        (REPEAT       )
);

//A-side reads
always @(*) begin    
    if (thread_q1_sel) begin
           casex (SrcA_addrs_q1)
         GLOB_RAM_ADDRS : rdSrcAdata = glob_RAM_rddataA[63:0]; //addresses are in bytes
               SP_ADDRS : rdSrcAdata = {46'h0000_0000_0000, SP[17:0]};                      
              AR6_ADDRS : rdSrcAdata = {46'h0000_0000_0000, AR6[17:0]};                      
              AR5_ADDRS : rdSrcAdata = {46'h0000_0000_0000, AR5[17:0]};
              AR4_ADDRS : rdSrcAdata = {46'h0000_0000_0000, AR4[17:0]};
              AR3_ADDRS : rdSrcAdata = {46'h0000_0000_0000, AR3[17:0]};                      
              AR2_ADDRS : rdSrcAdata = {46'h0000_0000_0000, AR2[17:0]};                      
              AR1_ADDRS : rdSrcAdata = {46'h0000_0000_0000, AR1[17:0]};
              AR0_ADDRS : rdSrcAdata = {46'h0000_0000_0000, AR0[17:0]};
               PC_ADDRS : rdSrcAdata = {48'h0000_0000_0000, PC[15:0]};
          PC_COPY_ADDRS : rdSrcAdata = {48'h0000_0000_0000, PC_COPY[15:0]};
               ST_ADDRS : rdSrcAdata = {32'h0000_0000, STATUS[31:0]};
           REPEAT_ADDRS : rdSrcAdata = {53'h0000_0000_0000_00, REPEAT[10:0]};  //this is so REPEAT is visible to debugger
           LPCNT1_ADDRS : rdSrcAdata = {47'h0000_0000_0000, LPCNT1_nz, 4'b0000, LPCNT1[11:0]};
           LPCNT0_ADDRS : rdSrcAdata = {47'h0000_0000_0000, LPCNT0_nz, 4'b0000, LPCNT0[11:0]};
            TIMER_ADDRS : rdSrcAdata = {44'h0000_000, timer[19:0]};           //20-bit timer                    
             CREG_ADDRS : rdSrcAdata = C_reg[63:0];     //C_reg is 64-bits  
             
              MON_ADDRS : rdSrcAdata = MON_SrcA_data[63:0];  //this data comes from the monitor/debugger/break block 
                                              
            CAPT3_ADDRS,
            CAPT2_ADDRS,
            CAPT1_ADDRS,
            CAPT0_ADDRS : rdSrcAdata = capt_dataA;           //capture registers are 64-bits
            
              QOS_ADDRS : rdSrcAdata = {32'h0000_0000, underflow_QOS[7:0], overflow_QOS[7:0], divby0_QOS[7:0], invalid_QOS[7:0]}; //quality of service registers are 32-bits                              
            FLOAT_ADDRS : rdSrcAdata = {32'h0000_0000, float_rddataA[31:0]};
           INTEGR_ADDRS : rdSrcAdata = rddataA_integer[63:0];
         PRIV_RAM_ADDRS : rdSrcAdata =  priv_RAM_rddataA[63:0];        //lowest 8k bytes of memory is RAM space               
               default  : rdSrcAdata = 64'h0000_0000_0000_0000;  
           endcase
    end                                                                              
    else rdSrcAdata = 64'h0000_0000_0000_0000;
end                                                                          

//B-side reads
always @(*) begin    //addresses are in bytes
    if (thread_q1_sel) begin
           casex (SrcB_addrs_q1)
         GLOB_RAM_ADDRS : rdSrcBdata = glob_RAM_rddataB[63:0];
               SP_ADDRS : rdSrcBdata =  {46'h0000_0000_0000, SP[17:0]};                      
              AR6_ADDRS : rdSrcBdata =  {46'h0000_0000_0000, AR6[17:0]};                      
              AR5_ADDRS : rdSrcBdata =  {46'h0000_0000_0000, AR5[17:0]};
              AR4_ADDRS : rdSrcBdata =  {46'h0000_0000_0000, AR4[17:0]};
              AR3_ADDRS : rdSrcBdata =  {46'h0000_0000_0000, AR3[17:0]};                      
              AR2_ADDRS : rdSrcBdata =  {46'h0000_0000_0000, AR2[17:0]};                      
              AR1_ADDRS : rdSrcBdata =  {46'h0000_0000_0000, AR1[17:0]};
              AR0_ADDRS : rdSrcBdata =  {46'h0000_0000_0000, AR0[17:0]};
               PC_ADDRS : rdSrcBdata =  {48'h0000_0000_0000, PC[15:0]};
          PC_COPY_ADDRS : rdSrcBdata =  {48'h0000_0000_0000, PC_COPY};
               ST_ADDRS : rdSrcBdata =  {32'h0000_0000, STATUS[31:0]};
           LPCNT1_ADDRS : rdSrcBdata =  {47'h0000_0000_0000, LPCNT1_nz, 4'b0000, LPCNT1[11:0]};
           LPCNT0_ADDRS : rdSrcBdata =  {47'h0000_0000_0000, LPCNT0_nz, 4'b0000, LPCNT0[11:0]};
            TIMER_ADDRS : rdSrcBdata =  {44'h0000_000, timer[19:0]};           //20-bit timer                    
             CREG_ADDRS : rdSrcBdata =  C_reg[63:0];     //C_reg is 64-bits                          
                                              
            CAPT3_ADDRS,
            CAPT2_ADDRS,
            CAPT1_ADDRS,
            CAPT0_ADDRS : rdSrcBdata = capt_dataB[63:0];           //capture registers are 64-bits
            
              QOS_ADDRS : rdSrcBdata = {32'h0000_0000, underflow_QOS[7:0], overflow_QOS[7:0], divby0_QOS[7:0], invalid_QOS[7:0]}; //quality of service registers are 32-bits                              
            FLOAT_ADDRS : rdSrcBdata = {32'h0000_0000, float_rddataB[31:0]};
           INTEGR_ADDRS : rdSrcBdata = rddataB_integer[63:0];
         PRIV_RAM_ADDRS : rdSrcBdata = priv_RAM_rddataB[63:0];        //lowest 8k bytes of memory is private RAM space               
               default  : rdSrcBdata = 64'h0000_0000_0000_0000;            
           endcase
    end
    else rdSrcBdata = 64'h0000_0000_0000_0000;
end

always @(posedge CLK or posedge RESET) begin
    if (RESET) mon_srcA_data_capture <= 64'h0000_0000_0000_0000;
    else if (Dest_addrs_q2=={2'b00, MON_ADDRS[15:0]} && ~|Dam_q2[1:0] && ~Ind_Dest_q2 && thread_q2_sel) mon_srcA_data_capture <= wrsrcAdataSext;
end    
    

// C_register
always @(posedge CLK or posedge RESET) begin
    if (RESET) C_reg <= 64'h0000_0000_0000_0000;
    else if ((OPdest_q2==CREG_ADDRS) && wrcycl && ~Ind_Dest_q2 && thread_q2_sel) C_reg <= wrsrcAdataSext;
end

// timer--counts number of instructions this thread executes and not clocks
always @(posedge CLK or posedge RESET) begin
    if (RESET) begin
        timer <= 20'h0_0000;
        timercmpr <= 20'h0_1000;     //default time-out value
    end    
    else if ((OPdest_q2==TIMER_ADDRS) && wrcycl && ~Ind_Dest_q2 && thread_q2_sel) begin
        timer <= 20'h0_0000;
        timercmpr <= wrsrcAdataSext[19:0];
    end    
    else if (~done && ~(timer==timercmpr) && newthreadq_sel) timer <= timer + 1'b1;                   
end

//loop counters
always @(posedge CLK or posedge RESET) begin
    if (RESET) begin
        LPCNT1 <= 12'h000;
        LPCNT0 <= 12'h000;
    end
    else begin
        if ((OPdest_q2==LPCNT0_ADDRS[15:0]) && wrcycl && ~Ind_Dest_q2 && thread_q2_sel) LPCNT0 <= wrsrcAdataSext[11:0];
        else if ((OPdest_q2==BTBS_) && ~Ind_Dest_q2 && (OPsrcA_q2==LPCNT0_ADDRS[15:0]) && thread_q2_sel && LPCNT0_nz) LPCNT0 <= LPCNT0_dec;
        
        if ((OPdest_q2==LPCNT1_ADDRS[15:0]) && wrcycl && ~Ind_Dest_q2 && thread_q2_sel) LPCNT1 <= wrsrcAdataSext[11:0];
        else if ((OPdest_q2==BTBS_) && ~Ind_Dest_q2 && (OPsrcA_q2==LPCNT1_ADDRS[15:0]) && thread_q2_sel && LPCNT1_nz) LPCNT1 <= LPCNT1_dec;
   end     
end
    
always @(posedge CLK or posedge RESET) begin
    if (RESET) begin
        NMI_VECTOR       <= 16'h0000;
        IRQ_VECTOR       <= 16'h0000; 
        invalid_VECTOR   <= 16'h0000; 
        divby0_VECTOR    <= 16'h0000; 
        overflow_VECTOR  <= 16'h0000; 
        underflow_VECTOR <= 16'h0000;
        inexact_VECTOR   <= 16'h0000; 
    end
    else begin
        if ((OPdest_q2==NMI_VECTOR_ADDRS) && wrcycl && ~Ind_Dest_q2 && thread_q2_sel) NMI_VECTOR <= wrsrcAdataSext[15:0];
        if ((OPdest_q2==IRQ_VECTOR_ADDRS) && wrcycl && ~Ind_Dest_q2 && thread_q2_sel) IRQ_VECTOR <= wrsrcAdataSext[15:0];
        if ((OPdest_q2==invalid_VECTOR_ADDRS) && wrcycl && ~Ind_Dest_q2 && thread_q2_sel) invalid_VECTOR <= wrsrcAdataSext[15:0];
        if ((OPdest_q2==divby0_VECTOR_ADDRS) && wrcycl && ~Ind_Dest_q2 && thread_q2_sel) divby0_VECTOR <= wrsrcAdataSext[15:0];
        if ((OPdest_q2==overflow_VECTOR_ADDRS) && wrcycl && ~Ind_Dest_q2 && thread_q2_sel) overflow_VECTOR <= wrsrcAdataSext[15:0];
        if ((OPdest_q2==underflow_VECTOR_ADDRS) && wrcycl && ~Ind_Dest_q2 && thread_q2_sel) underflow_VECTOR <= wrsrcAdataSext[15:0];
        if ((OPdest_q2==inexact_VECTOR_ADDRS) && wrcycl && ~Ind_Dest_q2 && thread_q2_sel) inexact_VECTOR <= wrsrcAdataSext[15:0];
   end 
end

// FP Quality Of Service meters 
always @(posedge CLK or posedge done) begin
    if (done) begin
        {underflow_QOS, overflow_QOS, divby0_QOS, invalid_QOS} <= 32'h0000_0000;
    end
    else begin
        if ((OPdest_q2==QOS_ADDRS) && thread_q2_sel && wrcycl && ~Ind_Dest_q2) {underflow_QOS, overflow_QOS, divby0_QOS, invalid_QOS} <=  wrsrcAdataSext[31:0];
        else begin
            if (invalid && ~&invalid_QOS)     invalid_QOS   <= invalid_QOS + 1'b1;
            if (divby0 && ~&divby0_QOS)       divby0_QOS    <= divby0_QOS + 1'b1;
            if (overflow && ~&overflow_QOS)   overflow_QOS  <= overflow_QOS + 1'b1;
            if (underflow && ~&underflow_QOS) underflow_QOS <= underflow_QOS + 1'b1;
        end
    end
end    
   
endmodule
