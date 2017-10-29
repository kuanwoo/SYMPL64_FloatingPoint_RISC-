 `timescale 1ns/100ps
 // Author:  Jerry D. Harthcock
 // Version:  1.06  January 18, 2016
 // Copyright (C) 2015-2016.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                                //
//             SYMPL 32-BIT RISC, COARSE-GRAINED SCHEDULER (CGS) and GP-GPU SHADER IP CORES                       //
//                              Evaluation and Product Development License                                        //
//                                                                                                                //
// Provided that you comply with all the terms and conditions set forth herein, Jerry D. Harthcock ("licensor"),  //
// the original author and exclusive copyright owner of these SYMPL 32-BIT RISC, COARSE-GRAINED SCHEDULER (CGS)   //
// and GP-GPU SHADER Verilog RTL IP cores and related development software ("this IP")  hereby grants             //
// to recipient of this IP ("licensee"), a world-wide, paid-up, non-exclusive license to implement this IP in     //
// Xilinx, Altera, MicroSemi or Lattice Semiconductor brand FPGAs only and used for the purposes of evaluation,   //
// education, and development of end products and related development tools only.  Furthermore, limited to the    //
// the purposes of prototyping, evaluation, characterization and testing of their implementation in a hard,       //
// custom or semi-custom ASIC, any university or institution of higher education may have their implementation of //
// this IP produced for said limited purposes at any foundary of their choosing provided that such prototypes do  //
// not ever wind up in commercial circulation with such license extending to said foundary and is in connection   //
// with said academic pursuit and under the supervision of said university or institution of higher education.    //
//                                                                                                                //
// Any customization, modification, or derivative work of this IP must include an exact copy of this license      //
// and original copyright notice at the very top of each source file and derived netlist, and, in the case of     //
// binaries, a printed copy of this license and/or a text format copy in a separate file distributed with said    //
// netlists or binary files having the file name, "LICENSE.txt".  You, the licensee, also agree not to remove     //
// any copyright notices from any source file covered under this Evaluation and Product Development License.      //
//                                                                                                                //
// LICENSOR DOES NOT WARRANT OR GUARANTEE THAT YOUR USE OF THIS IP WILL NOT INFRINGE THE RIGHTS OF OTHERS OR      //
// THAT IT IS SUITABLE OR FIT FOR ANY PURPOSE AND THAT YOU, THE LICENSEE, AGREE TO HOLD LICENSOR HARMLESS FROM    //
// ANY CLAIM BROUGHT BY YOU OR ANY THIRD PARTY FOR YOUR SUCH USE.                                                 //
//                                                                                                                //
// Licensor reserves all his rights without prejudice, including, but in no way limited to, the right to change   //
// or modify the terms and conditions of this Evaluation and Product Development License anytime without notice   //
// of any kind to anyone. By using this IP for any purpose, you agree to all the terms and conditions set forth   //
// in this Evaluation and Product Development License.                                                            //
//                                                                                                                //
// This Evaluation and Product Development License does not include the right to sell products that incorporate   //
// this IP, any IP derived from this IP.  If you would like to obtain such a license, please contact Licensor.    //
//                                                                                                                //
// Licensor can be contacted at:  SYMPL.gpu@gmail.com                                                             //
//                                                                                                                //
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module int_cntrl(
    CLK,
    RESET,
    PC,
    thread_q0_sel,
    thread_q1_sel,
    thread_q2_sel,
    OPsrcA_q2,
    OPdest_q2,
    Ind_Dest_q2,
    Ind_SrcA_q2,
    RPT_not_z,
    NMI,
    inexact_exc,  
    underflow_exc,
    overflow_exc, 
    divby0_exc,   
    invalid_exc,  
    IRQ,
    IRQ_IE,
    vector,
    ld_vector,
    NMI_ack,
    EXC_ack,
    IRQ_ack,
    EXC_in_service,
    invalid_in_service,
    divby0_in_service, 
    overflow_in_service, 
    underflow_in_service,
    inexact_in_service,
    wrcycl,
    int_in_service,
     NMI_VECTOR,
     IRQ_VECTOR,
     invalid_VECTOR,
     divby0_VECTOR,
     overflow_VECTOR,
     underflow_VECTOR,
     inexact_VECTOR
    );
    
input CLK; 
input RESET; 
input NMI; 
input inexact_exc;  
input underflow_exc;
input overflow_exc; 
input divby0_exc;   
input invalid_exc;  
input IRQ; 
input IRQ_IE;
input [15:0] PC;
input thread_q0_sel; 
input thread_q1_sel; 
input thread_q2_sel; 
input RPT_not_z;         
input [15:0] OPsrcA_q2;
input [15:0] OPdest_q2;
input Ind_Dest_q2;
input Ind_SrcA_q2;
output [15:0] vector;
output ld_vector;
output NMI_ack;
output EXC_ack;
output IRQ_ack;
output EXC_in_service;
output invalid_in_service;
output divby0_in_service; 
output overflow_in_service; 
output underflow_in_service;
output inexact_in_service;
output int_in_service;
input wrcycl;
input [15:0] NMI_VECTOR;
input [15:0] IRQ_VECTOR;
input [15:0] invalid_VECTOR;
input [15:0] divby0_VECTOR;
input [15:0] overflow_VECTOR;
input [15:0] underflow_VECTOR;
input [15:0] inexact_VECTOR;

parameter     ROM_ADDRS   = 18'b1111111xxxxxxxxxxx; //rom in this implementation is only 32k bytes (4k x 64), shared by all threads
parameter      SP_ADDRS   = 18'h0FFE8;
parameter     AR6_ADDRS   = 18'h0FFE0;
parameter     AR5_ADDRS   = 18'h0FFD8;
parameter     AR4_ADDRS   = 18'h0FFD0;
parameter     AR3_ADDRS   = 18'h0FFC8;
parameter     AR2_ADDRS   = 18'h0FFC0;
parameter     AR1_ADDRS   = 18'h0FFB8;
parameter     AR0_ADDRS   = 18'h0FFB0;
parameter      PC_ADDRS   = 18'h0FFA8;
parameter PC_COPY_ADDRS   = 18'h0FF90;
parameter      ST_ADDRS   = 18'h0FF88;
parameter  LPCNT1_ADDRS   = 18'h0FF78;
parameter  LPCNT0_ADDRS   = 18'h0FF70;
parameter   TIMER_ADDRS   = 18'h0FF68;
parameter    CREG_ADDRS   = 18'h0FF60;
parameter   CAPT3_ADDRS   = 18'h0FF58;
parameter   CAPT2_ADDRS   = 18'h0FF50;
parameter   CAPT1_ADDRS   = 18'h0FF48;
parameter   CAPT0_ADDRS   = 18'h0FF40;
parameter  SCHED_ADDRS    = 18'h0FF38;
parameter  SCHEDCMP_ADDRS = 18'h0FF30;
parameter     QOS_ADDRS   = 18'h0FF20;
parameter     RAM_ADDRS   = 18'b0000xxxxxxxxxxxxxx; //first 32k bytes (since data memory is byte-addressable and smallest RAM for this in Kintex 7 is 2k x 64 bits using two blocks next to each other

reg [15:0] vector;
reg ld_vector;

reg NMI_ackq;
reg NMI_in_service;

reg EXC_ackq;
reg EXC_in_service;

reg IRQ_ackq;
reg IRQ_in_service;

reg inexactq; 
reg underflowq;
reg overflowq;
reg divby0q;  
reg invalidq; 
 
reg [2:0] int_state;


reg [4:0] RESET_STATE;
          
wire EXC;

wire NMIg;
wire NMI_ack;
wire NMI_RETI;
wire saving_NMI_PC_COPY;

wire EXCg;
wire EXC_ack;
wire EXC_RETI;
wire saving_EXC_PC_COPY;
wire [4:0] EXC_sel;

wire IRQg;
wire IRQ_ack;
wire IRQ_RETI;
wire saving_IRQ_PC_COPY;

wire invalid_RETI; 
wire divby0_RETI;  
wire overflow_RETI; 
wire underflow_RETI;
wire inexact_RETI; 

wire invalid_in_service;
wire divby0_in_service;
wire overflow_in_service;
wire underflow_in_service;
wire inexact_in_service;

wire int_in_service;

assign int_in_service = NMI_in_service || IRQ_in_service || EXC_in_service;
assign EXC_sel = {invalidq, divby0q, overflowq, underflowq, inexactq};  

assign NMI_ack = NMI_ackq && (PC==NMI_VECTOR) && thread_q0_sel;
assign EXC_ack = EXC_ackq && ((PC==invalid_VECTOR) || (PC==divby0_VECTOR) || (PC==overflow_VECTOR) || (PC==underflow_VECTOR) || (PC==inexact_VECTOR)) && thread_q0_sel;
assign IRQ_ack = IRQ_ackq && (PC==IRQ_VECTOR) && thread_q0_sel;


assign invalid_in_service = EXC_in_service && invalidq;
assign divby0_in_service = EXC_in_service && divby0q;
assign overflow_in_service = EXC_in_service && overflowq;
assign underflow_in_service = EXC_in_service && underflowq;
assign inexact_in_service = EXC_in_service && inexactq;

assign invalid_RETI = invalid_in_service &&     (OPsrcA_q2[2:0]==3'b111) && (OPdest_q2==PC_ADDRS[15:0]) && Ind_SrcA_q2 && thread_q2_sel && wrcycl;
assign divby0_RETI = divby0_in_service &&       (OPsrcA_q2[2:0]==3'b111) && (OPdest_q2==PC_ADDRS[15:0]) && Ind_SrcA_q2 && thread_q2_sel && wrcycl;
assign overflow_RETI = overflow_in_service &&   (OPsrcA_q2[2:0]==3'b111) && (OPdest_q2==PC_ADDRS[15:0]) && Ind_SrcA_q2 && thread_q2_sel && wrcycl;
assign underflow_RETI = underflow_in_service && (OPsrcA_q2[2:0]==3'b111) && (OPdest_q2==PC_ADDRS[15:0]) && Ind_SrcA_q2 && thread_q2_sel && wrcycl;
assign inexact_RETI = inexact_in_service &&     (OPsrcA_q2[2:0]==3'b111) && (OPdest_q2==PC_ADDRS[15:0]) && Ind_SrcA_q2 && thread_q2_sel && wrcycl;
assign NMI_RETI = NMI_in_service &&             (OPsrcA_q2[2:0]==3'b111) && (OPdest_q2==PC_ADDRS[15:0]) && Ind_SrcA_q2 && thread_q2_sel && wrcycl;     //POP stack into PC
assign IRQ_RETI = IRQ_in_service &&             (OPsrcA_q2[2:0]==3'b111) && (OPdest_q2==PC_ADDRS[15:0]) && Ind_SrcA_q2 && thread_q2_sel && wrcycl;
assign EXC_RETI = invalid_RETI || divby0_RETI || overflow_RETI || underflow_RETI || inexact_RETI;

assign saving_NMI_PC_COPY = NMI_in_service && (OPdest_q2[2:0]==3'b111) && (OPsrcA_q2==PC_COPY_ADDRS[15:0]) && Ind_Dest_q2 & thread_q2_sel && wrcycl;  // PUSH PC_COPY onto stack
assign saving_EXC_PC_COPY = EXC_in_service && (OPdest_q2[2:0]==3'b111) && (OPsrcA_q2==PC_COPY_ADDRS[15:0]) && Ind_Dest_q2 & thread_q2_sel && wrcycl;
assign saving_IRQ_PC_COPY = IRQ_in_service && (OPdest_q2[2:0]==3'b111) && (OPsrcA_q2==PC_COPY_ADDRS[15:0]) && Ind_Dest_q2 & thread_q2_sel && wrcycl;

assign NMIg = NMI && ~NMI_ack && ~NMI_in_service && thread_q0_sel;                                                                                                                                              
assign EXCg = (inexactq || underflowq || overflowq || divby0q || invalidq) && ~EXC_ack && ~EXC_in_service && thread_q0_sel && IRQ_IE;                                                                                                                                              
assign IRQg = IRQ && IRQ_IE && ~IRQ_ack && ~IRQ_in_service && ~NMIg && ~EXCg  && thread_q0_sel;                                                                                                                                               

always @(posedge CLK or posedge RESET) begin
    if (RESET) begin
        inexactq   <= 1'b0; 
        underflowq <= 1'b0;
        overflowq  <= 1'b0;
        divby0q    <= 1'b0; 
        invalidq   <= 1'b0;
    end
    else begin
        if (invalid_RETI) invalidq <= 1'b0;
        else if (~invalidq) invalidq <= invalid_exc;

        if (divby0_RETI) divby0q <= 1'b0;
        else if (~divby0q) divby0q <= divby0_exc;
        
        if (overflow_RETI) overflowq <= 1'b0;
        else if (~overflowq) overflowq <= overflow_exc;
        
        if (underflow_RETI) underflowq <= 1'b0;
        else if (~underflowq) underflowq <= underflow_exc;

        if (inexact_RETI) inexactq <= 1'b0;
        else if (~inexactq) inexactq <= inexact_exc;
    end
end        
        
//interrupt prioritizer with corresponding IACK and IN_SERVICE generator
// NMI can interrupt EXC and IRQ while they are in service
// EXC has priority over IRQ but cannot interrupt IRQ or NMI while they are in service
// all interrupt sources must be held active until acknowledged, at which time they may be released
always @(posedge CLK or posedge RESET) begin
    if (RESET) begin
        vector <= 16'h0000;
        ld_vector <= 1'b0;
        int_state <= 3'b000;
        
        NMI_ackq <= 1'b0;                                                                                           
        NMI_in_service <= 1'b0;                                                                                     
                                                                                                                    
        EXC_ackq <= 1'b0;                                                                                           
        EXC_in_service <= 1'b0;                                                                                     
                                                                                                                    
        IRQ_ackq <= 1'b0;                                                                                           
        IRQ_in_service <= 1'b0;                                                                                     
        
        RESET_STATE <= 5'b10000;
    end
//NMI    
    else begin
        RESET_STATE <= {1'b1, RESET_STATE[4:1]};    //rotate right 1 into msb  (shift right)
       if (&RESET_STATE) //block all interrupts until reset vector fetched and entered
            case(int_state)
                3'b000 : if (NMIg) begin
                            NMI_ackq <= 1'b1;
                            ld_vector <= 1'b1;
                            vector <= NMI_VECTOR;
                            int_state <= 3'b001;
                         end
                         else if (EXCg) begin
                            EXC_ackq <= 1'b1;
                            ld_vector <= 1'b1;
                            casex (EXC_sel)
                                5'b1xxxx : vector <= invalid_VECTOR;
                                5'b01xxx : vector <= divby0_VECTOR;
                                5'b001xx : vector <= overflow_VECTOR;
                                5'b0001x : vector <= underflow_VECTOR;
                                5'b00001 : vector <= inexact_VECTOR;
                                default  : vector <= invalid_VECTOR;
                            endcase    
                            int_state <= 3'b001;
                         end
                         else if (IRQg) begin
                            IRQ_ackq <= 1'b1;
                            ld_vector <= 1'b1;
                            vector <= IRQ_VECTOR;
                            int_state <= 3'b001;
                         end                                
                3'b001 : begin                                                                                         
                            ld_vector <= 1'b0;                                                                         
                            if (NMI_ackq) begin
                              NMI_ackq <= 1'b0;
                              NMI_in_service <= 1'b1;
                              int_state <= 3'b010;                
                            end
                            else if (EXC_ackq) begin          
                                EXC_ackq <= 1'b0;        
                                EXC_in_service <= 1'b1;  
                                int_state <= 3'b010;           
                            end                          
                            else if (IRQ_ackq) begin     
                                IRQ_ackq <= 1'b0;        
                                IRQ_in_service <= 1'b1;  
                                int_state <= 3'b010;           
                            end                          
                         end
                3'b010 : begin
                            if (NMI_in_service && saving_NMI_PC_COPY) begin
                                int_state <= 3'b011;
                            end
                            else if ((EXC_in_service && saving_EXC_PC_COPY) || (IRQ_in_service && saving_IRQ_PC_COPY)) begin
                                int_state <= 3'b011;
                            end
                         end   
                3'b011 : begin
                            if (NMI_RETI) begin
                                NMI_in_service <= 1'b0;
                                int_state <= 3'b100;
                            end
                            else if (EXC_RETI) begin
                                EXC_in_service <= 1'b0;
                                int_state <= 3'b100;
                            end
                            else if (IRQ_RETI) begin
                                IRQ_in_service <= 1'b0;
                                int_state <= 3'b100;
                            end
                         end
                3'b100 : if (thread_q0_sel) int_state <= 3'b000;   //allow one fetch before allowing another interrupt
               default : int_state <= 3'b000;
             endcase        
    end                
end                     
                        
endmodule        
               
                