// breakpoints.v
 `timescale 1ns/100ps
 // Author:  Jerry D. Harthcock
 // Version:  1.0  October 1, 2017
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

module breakpoints (
    CLK,
    RESET,
    Instruction_q0,
    Instruction_q0_del,
    pre_PC,
    newthread,
    
    tr0_PC_EQ_BRKA_en, 
    tr0_PC_EQ_BRKB_en, 
    tr0_PC_GT_BRKA_en,
    tr0_PC_LT_BRKB_en,
    tr0_PC_AND_en,
    
    tr1_PC_EQ_BRKA_en, 
    tr1_PC_EQ_BRKB_en, 
    tr1_PC_GT_BRKA_en,
    tr1_PC_LT_BRKB_en,
    tr1_PC_AND_en,
    
    tr2_PC_EQ_BRKA_en, 
    tr2_PC_EQ_BRKB_en, 
    tr2_PC_GT_BRKA_en,
    tr2_PC_LT_BRKB_en,
    tr2_PC_AND_en,
      
    tr3_PC_EQ_BRKA_en, 
    tr3_PC_EQ_BRKB_en, 
    tr3_PC_GT_BRKA_en,
    tr3_PC_LT_BRKB_en,
    tr3_PC_AND_en,
    
    tr0_event_det,
    tr1_event_det,
    tr2_event_det,
    tr3_event_det,
    
    tr0_evnt_cntr,
    tr1_evnt_cntr,
    tr2_evnt_cntr,
    tr3_evnt_cntr,

    tr0_trigger_A,
    tr0_trigger_B,
    tr1_trigger_A,
    tr1_trigger_B,
    tr2_trigger_A,
    tr2_trigger_B,
    tr3_trigger_A,
    tr3_trigger_B,

    
    tr0_sstep,
    tr1_sstep,
    tr2_sstep,
    tr3_sstep,
    tr0_frc_brk,
    tr1_frc_brk,
    tr2_frc_brk,
    tr3_frc_brk,
    tr0_broke,
    tr1_broke,
    tr2_broke,
    tr3_broke,
    tr0_skip_cmplt,
    tr1_skip_cmplt,
    tr2_skip_cmplt,
    tr3_skip_cmplt,
    break_q0,
    mon_read_addrs,
    mon_write_addrs,
    tr0_mon_req,
    tr1_mon_req,
    tr2_mon_req,
    tr3_mon_req,
    wrdata
    );

input CLK;
input RESET;
input [63:0] wrdata;
input  [63:0] Instruction_q0;
input  [15:0] pre_PC;
input   [1:0] newthread;
output [63:0] Instruction_q0_del;


input tr0_PC_EQ_BRKA_en; 
input tr0_PC_EQ_BRKB_en; 
input tr0_PC_GT_BRKA_en;
input tr0_PC_LT_BRKB_en;
input tr0_PC_AND_en;

input tr1_PC_EQ_BRKA_en; 
input tr1_PC_EQ_BRKB_en; 
input tr1_PC_GT_BRKA_en;
input tr1_PC_LT_BRKB_en;
input tr1_PC_AND_en;

input tr2_PC_EQ_BRKA_en; 
input tr2_PC_EQ_BRKB_en; 
input tr2_PC_GT_BRKA_en;
input tr2_PC_LT_BRKB_en;
input tr2_PC_AND_en;
        
input tr3_PC_EQ_BRKA_en; 
input tr3_PC_EQ_BRKB_en; 
input tr3_PC_GT_BRKA_en;
input tr3_PC_LT_BRKB_en;
input tr3_PC_AND_en;

output tr0_event_det;
output tr1_event_det;
output tr2_event_det;
output tr3_event_det;

input  [15:0] tr0_evnt_cntr;
input  [15:0] tr1_evnt_cntr;
input  [15:0] tr2_evnt_cntr;
input  [15:0] tr3_evnt_cntr;

input  [15:0] tr0_trigger_A;
input  [15:0] tr0_trigger_B;
input  [15:0] tr1_trigger_A;
input  [15:0] tr1_trigger_B;
input  [15:0] tr2_trigger_A;
input  [15:0] tr2_trigger_B;
input  [15:0] tr3_trigger_A;
input  [15:0] tr3_trigger_B;    
    
input tr0_sstep;
input tr1_sstep;
input tr2_sstep;
input tr3_sstep;

input tr0_frc_brk;
input tr1_frc_brk;
input tr2_frc_brk;
input tr3_frc_brk;

output tr0_broke;
output tr1_broke;
output tr2_broke;
output tr3_broke;

output tr0_skip_cmplt;
output tr1_skip_cmplt;
output tr2_skip_cmplt;
output tr3_skip_cmplt;

output break_q0;
input  [15:0] mon_read_addrs;
input  [15:0] mon_write_addrs;

input  tr0_mon_req;
input  tr1_mon_req;
input  tr2_mon_req;
input  tr3_mon_req;

reg break_q0;

reg [1:0] tr0_break_state;
reg [1:0] tr1_break_state;
reg [1:0] tr2_break_state;
reg [1:0] tr3_break_state;

reg tr0_broke;
reg tr1_broke;
reg tr2_broke;
reg tr3_broke;

reg tr0_skip;
reg tr1_skip;
reg tr2_skip;
reg tr3_skip;

reg tr0_skip_cmplt;
reg tr1_skip_cmplt;
reg tr2_skip_cmplt;
reg tr3_skip_cmplt;


reg [1:0]mon_state;

reg tr0_mon_req_q0;
reg tr1_mon_req_q0;
reg tr2_mon_req_q0;
reg tr3_mon_req_q0;

reg [63:0] monitor_instructionq;


wire mon_cycl_det;
wire any_break_det;

wire [63:0] Instruction_q0_del;
wire [63:0] monitor_instruction;

wire tr0_PC_EQ_BRKA;
wire tr0_PC_GTE_BRKA;
wire tr0_PC_EQ_BRKB;
wire tr0_PC_LTE_BRKB;
wire tr0_PC_GTE_BRKA_AND_LTE_BRKB;

wire tr1_PC_EQ_BRKA;
wire tr1_PC_GTE_BRKA;
wire tr1_PC_EQ_BRKB;
wire tr1_PC_LT_BRKB;
wire tr1_PC_GT_BRKA_AND_LT_BRKB;

wire tr2_PC_EQ_BRKA;
wire tr2_PC_GT_BRKA;
wire tr2_PC_EQ_BRKB;
wire tr2_PC_LT_BRKB;
wire tr2_PC_GT_BRKA_AND_LT_BRKB;

wire tr3_PC_EQ_BRKA;
wire tr3_PC_GT_BRKA;
wire tr3_PC_EQ_BRKB;
wire tr3_PC_LT_BRKB;
wire tr3_PC_GT_BRKA_AND_LT_BRKB;
                                                                                                         
wire tr0_event_det;                                                                                        
wire tr1_event_det;                                                                                        
wire tr2_event_det;                                                                                        
wire tr3_event_det;                                                                                        

assign tr0_PC_EQ_BRKA = (newthread==2'b00) && (pre_PC == tr0_trigger_A) && tr0_PC_EQ_BRKA_en;  
assign tr0_PC_EQ_BRKB = (newthread==2'b00) && (pre_PC == tr0_trigger_B) && tr0_PC_EQ_BRKB_en;  
assign tr0_PC_GT_BRKA = (newthread==2'b00) && (pre_PC > tr0_trigger_A)  && tr0_PC_GT_BRKA_en;
assign tr0_PC_LT_BRKB = (newthread==2'b00) && (pre_PC < tr0_trigger_B)  && tr0_PC_LT_BRKB_en;
assign tr0_PC_GT_BRKA_AND_LT_BRKB = (newthread==2'b00)       && 
                                    (pre_PC > tr0_trigger_A) && 
                                    (pre_PC < tr0_trigger_B) &&
                                     tr0_PC_AND_en;

assign tr1_PC_EQ_BRKA = (newthread==2'b01) && (pre_PC == tr1_trigger_A) && tr1_PC_EQ_BRKA_en;  
assign tr1_PC_EQ_BRKB = (newthread==2'b01) && (pre_PC == tr1_trigger_B) && tr1_PC_EQ_BRKB_en;  
assign tr1_PC_GT_BRKA = (newthread==2'b01) && (pre_PC > tr1_trigger_A)  && tr1_PC_GT_BRKA_en;
assign tr1_PC_LT_BRKB = (newthread==2'b01) && (pre_PC < tr1_trigger_B)  && tr1_PC_LT_BRKB_en;
assign tr1_PC_GT_BRKA_AND_LT_BRKB = (newthread==2'b01)       && 
                                    (pre_PC > tr1_trigger_A) && 
                                    (pre_PC < tr1_trigger_B) &&
                                     tr1_PC_AND_en;

assign tr2_PC_EQ_BRKA = (newthread==2'b10) && (pre_PC == tr2_trigger_A) && tr2_PC_EQ_BRKA_en;  
assign tr2_PC_EQ_BRKB = (newthread==2'b10) && (pre_PC == tr2_trigger_B) && tr2_PC_EQ_BRKB_en;  
assign tr2_PC_GT_BRKA = (newthread==2'b10) && (pre_PC > tr2_trigger_A)  && tr2_PC_GT_BRKA_en;
assign tr2_PC_LT_BRKB = (newthread==2'b10) && (pre_PC < tr2_trigger_B)  && tr2_PC_LT_BRKB_en;
assign tr2_PC_GT_BRKA_AND_LT_BRKB = (newthread==2'b10)       && 
                                    (pre_PC > tr2_trigger_A) && 
                                    (pre_PC < tr2_trigger_B) &&
                                     tr2_PC_AND_en;

assign tr3_PC_EQ_BRKA = (newthread==2'b11) && (pre_PC == tr3_trigger_A) && tr3_PC_EQ_BRKA_en;  
assign tr3_PC_EQ_BRKB = (newthread==2'b11) && (pre_PC == tr3_trigger_B) && tr3_PC_EQ_BRKB_en;  
assign tr3_PC_GT_BRKA = (newthread==2'b11) && (pre_PC > tr3_trigger_A)  && tr3_PC_GT_BRKA_en;
assign tr3_PC_LT_BRKB = (newthread==2'b11) && (pre_PC < tr3_trigger_B)  && tr3_PC_LT_BRKB_en;
assign tr3_PC_GT_BRKA_AND_LT_BRKB = (newthread==2'b11)       && 
                                    (pre_PC > tr3_trigger_A) && 
                                    (pre_PC < tr3_trigger_B) &&
                                     tr3_PC_AND_en;

assign tr0_event_det = tr0_PC_EQ_BRKA ||
                       tr0_PC_EQ_BRKB ||
                       tr0_PC_GT_BRKA || 
                       tr0_PC_LT_BRKB ||
                       tr0_PC_GT_BRKA_AND_LT_BRKB;

assign tr1_event_det = tr1_PC_EQ_BRKA ||
                       tr1_PC_EQ_BRKB ||
                       tr1_PC_GT_BRKA || 
                       tr1_PC_LT_BRKB ||
                       tr1_PC_GT_BRKA_AND_LT_BRKB;

assign tr2_event_det = tr2_PC_EQ_BRKA ||
                       tr2_PC_EQ_BRKB ||
                       tr2_PC_GT_BRKA || 
                       tr2_PC_LT_BRKB ||
                       tr2_PC_GT_BRKA_AND_LT_BRKB;

assign tr3_event_det = tr3_PC_EQ_BRKA ||
                       tr3_PC_EQ_BRKB ||
                       tr3_PC_GT_BRKA || 
                       tr3_PC_LT_BRKB ||
                       tr3_PC_GT_BRKA_AND_LT_BRKB;
                     

assign any_break_det = (tr0_event_det && (tr0_evnt_cntr == 16'h0001)) ||
                       (tr1_event_det && (tr1_evnt_cntr == 16'h0001)) ||
                       (tr2_event_det && (tr2_evnt_cntr == 16'h0001)) ||
                       (tr3_event_det && (tr3_evnt_cntr == 16'h0001)) ||
                       (tr0_frc_brk   && (newthread==2'b00))          ||
                       (tr0_broke     && (newthread==2'b00))          ||
                       (tr1_frc_brk   && (newthread==2'b01))          ||
                       (tr1_broke     && (newthread==2'b01))          ||
                       (tr2_frc_brk   && (newthread==2'b10))          ||
                       (tr2_broke     && (newthread==2'b10))          ||
                       (tr3_frc_brk   && (newthread==2'b11))          ||
                       (tr3_broke     && (newthread==2'b11))          ;
                       
                       
assign monitor_instruction = {8'b0000_0110, mon_write_addrs, 4'b0110, mon_read_addrs, 4'b0110, 16'h0000};    //monitor reads/writes are always double-word (64-bits)                     
assign Instruction_q0_del = break_q0 ?  monitor_instructionq : Instruction_q0;  

assign mon_cycl_det = (((tr0_mon_req && (newthread==2'b00))  ||
                        (tr1_mon_req && (newthread==2'b01))  ||
                        (tr2_mon_req && (newthread==2'b10))  ||
                        (tr3_mon_req && (newthread==2'b11))) && (mon_state[1:0]==2'b00));


always @(posedge CLK or posedge RESET) begin
    if (RESET) begin
        tr0_mon_req_q0 <= 1'b0;
        tr1_mon_req_q0 <= 1'b0; 
        tr2_mon_req_q0 <= 1'b0; 
        tr3_mon_req_q0 <= 1'b0; 
        mon_state <= 2'b00;
        monitor_instructionq <= 64'h0600006000060000;
    end
    else case(mon_state)
             2'b00 : if (mon_cycl_det) begin
                         monitor_instructionq <= monitor_instruction; 
                         tr0_mon_req_q0 <= ((newthread==2'b00) && tr0_mon_req);
                         tr1_mon_req_q0 <= ((newthread==2'b01) && tr1_mon_req);
                         tr2_mon_req_q0 <= ((newthread==2'b10) && tr2_mon_req);
                         tr3_mon_req_q0 <= ((newthread==2'b11) && tr3_mon_req);
                         mon_state <= 2'b01;
                     end    
             2'b01 : begin
                        monitor_instructionq <= 64'h0600006000060000;
                        tr0_mon_req_q0 <= 1'b0;           
                        tr1_mon_req_q0 <= 1'b0;           
                        tr2_mon_req_q0 <= 1'b0;           
                        tr3_mon_req_q0 <= 1'b0;           
                        mon_state <= 2'b10;
                     end    
             2'b10 : if (~tr0_mon_req && ~tr1_mon_req && ~tr2_mon_req && ~tr3_mon_req) mon_state <= 2'b00; 
           default : begin
                        tr0_mon_req_q0 <= 1'b0;   
                        tr1_mon_req_q0 <= 1'b0;   
                        tr2_mon_req_q0 <= 1'b0;   
                        tr3_mon_req_q0 <= 1'b0;   
                        mon_state <= 2'b00;
                        monitor_instructionq <= 64'h0600006000060000;
                     end
         endcase          
end

                                                                                                                  
always @(posedge CLK or posedge RESET) begin
    if (RESET) begin                                                                                               
        break_q0 <= 1'b0;                                                                                          
    end
    else begin                                                                                                     
        break_q0 <= (any_break_det && 
                   ~((tr0_skip && (newthread==2'b00))   || 
                     (tr1_skip && (newthread==2'b01))   || 
                     (tr2_skip && (newthread==2'b10))   || 
                     (tr3_skip && (newthread==2'b11)))) || mon_cycl_det;                          
    end                 
end   

// tr0 sstep
always @(posedge CLK or posedge RESET) begin
    if (RESET) begin
        tr0_broke <= 1'b0;
        tr0_break_state <=2'b00;
        tr0_skip <= 1'b0;
        tr0_skip_cmplt <= 1'b0;
    end
    else begin
        casex(tr0_break_state) 
            2'b00 : if (tr0_event_det && (tr0_evnt_cntr == 16'h0001)) begin 
                        tr0_broke <= 1'b1;
                        tr0_break_state <= 2'b01;
                    end
            2'b01 : if (tr0_sstep && (newthread==2'b00)) begin
                        tr0_skip <= 1'b1;
                        tr0_skip_cmplt <= 1'b0;
                        tr0_break_state <= 2'b10;
                    end
            2'b10 : begin 
                        if (newthread==2'b00) begin
                            tr0_skip <= 1'b0;
                            tr0_skip_cmplt <= 1'b1;
                            if (~tr0_sstep) begin
                               tr0_break_state <= 2'b11;
                               tr0_skip_cmplt <= 1'b0;
                            end    
                        end    
                    end
            2'b11 : if (~tr0_frc_brk) begin
                        tr0_broke <= 1'b0;
                        tr0_break_state <= 2'b00;
                    end
                    else tr0_break_state <= 2'b01;            
        endcase
    end
end   

// tr1 sstep
always @(posedge CLK or posedge RESET) begin
    if (RESET) begin
        tr1_broke <= 1'b0;
        tr1_break_state <=2'b00;
        tr1_skip <= 1'b0;
        tr1_skip_cmplt <= 1'b0;
    end
    else begin
        casex(tr1_break_state) 
            2'b00 : if (tr1_event_det && (tr1_evnt_cntr == 16'h0001)) begin
                        tr1_broke <= 1'b1;
                        tr1_break_state <= 2'b01;
                    end
            2'b01 : if (tr1_sstep && (newthread==2'b01)) begin
                        tr1_skip <= 1'b1;
                        tr1_skip_cmplt <= 1'b0;
                        tr1_break_state <= 2'b10;
                    end
            2'b10 : begin 
                        if (newthread==2'b01) begin
                            tr1_skip <= 1'b0;
                            tr1_skip_cmplt <= 1'b1;
                            if (~tr1_sstep) begin
                               tr1_break_state <= 2'b11;
                               tr1_skip_cmplt <= 1'b0;
                            end    
                        end    
                    end
            2'b11 : if (~tr1_frc_brk) begin
                        tr1_broke <= 1'b0;
                        tr1_break_state <= 2'b00;
                    end
                    else tr1_break_state <= 2'b01;            
        endcase
    end
end   

// tr2 sstep
always @(posedge CLK or posedge RESET) begin
    if (RESET) begin
        tr2_broke <= 1'b0;
        tr2_break_state <=2'b00;
        tr2_skip <= 1'b0;
        tr2_skip_cmplt <= 1'b0;
    end
    else begin
        casex(tr2_break_state) 
            2'b00 : if (tr2_event_det && (tr2_evnt_cntr == 16'h0001)) begin
                        tr2_broke <= 1'b1;
                        tr2_break_state <= 2'b01;
                    end
            2'b01 : if (tr2_sstep && (newthread==2'b10)) begin
                        tr2_skip <= 1'b1;
                        tr2_skip_cmplt <= 1'b0;
                        tr2_break_state <= 2'b10;
                    end
            2'b10 : begin 
                        if (newthread==2'b10) begin
                            tr2_skip <= 1'b0;
                            tr2_skip_cmplt <= 1'b1;
                            if (~tr2_sstep) begin
                               tr2_break_state <= 2'b11;
                               tr2_skip_cmplt <= 1'b0;
                            end    
                        end    
                    end
            2'b11 : if (~tr2_frc_brk) begin
                        tr2_broke <= 1'b0;
                        tr2_break_state <= 2'b00;
                    end
                    else tr2_break_state <= 2'b01;            
        endcase
    end
end   

// tr3 sstep
always @(posedge CLK or posedge RESET) begin
    if (RESET) begin
        tr3_broke <= 1'b0;
        tr3_break_state <=2'b00;
        tr3_skip <= 1'b0;
        tr3_skip_cmplt <= 1'b0;
    end
    else begin
        casex(tr3_break_state) 
            2'b00 :if (tr3_event_det && (tr3_evnt_cntr == 16'h0001)) begin
                        tr3_broke <= 1'b1;
                        tr3_break_state <= 2'b01;
                    end
            2'b01 : if (tr3_sstep && (newthread==2'b11)) begin
                        tr3_skip <= 1'b1;
                        tr3_skip_cmplt <= 1'b0;
                        tr3_break_state <= 2'b10;
                    end
            2'b10 : begin 
                        if (newthread==2'b11) begin
                            tr3_skip <= 1'b0;
                            tr3_skip_cmplt <= 1'b1;
                            if (~tr3_sstep) begin
                               tr3_break_state <= 2'b11;
                               tr3_skip_cmplt <= 1'b0;
                            end    
                        end    
                    end
            2'b11 : if (~tr3_frc_brk) begin
                        tr3_broke <= 1'b0;
                        tr3_break_state <= 2'b00;
                    end
                    else tr3_break_state <= 2'b01;            
        endcase
    end
end     

endmodule
