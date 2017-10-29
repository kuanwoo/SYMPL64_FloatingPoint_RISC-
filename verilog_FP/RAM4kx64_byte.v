 // tri-port 1 write-side and 2 read-side (byte-addressable) 
 `timescale 1ns/1ns
 // Author:  Jerry D. Harthcock
 // Version:  1.204  January 18, 2016
 // Copyright (C) 2014-2016.  All rights reserved.
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

module RAM4kx64_byte #(parameter ADDRS_WIDTH = 12) (
    CLK,
    RESET,
    wren,
    wrsize,
    wraddrs,
    wrdata,
    rdenA,
    rdAsize,
    rdaddrsA,
    rddataA,
    rdenB,
    rdBsize,
    rdaddrsB,
    rddataB);    

input  CLK;
input  RESET;
input  wren;
input [1:0] wrsize;
input  [14:0] wraddrs; 
input  [63:0] wrdata;                                                    
input  rdenA;                                                                      
input [1:0] rdAsize;
input  [14:0] rdaddrsA;
output [63:0] rddataA;
input  rdenB;    
input [1:0] rdBsize;
input  [14:0] rdaddrsB;
output [63:0] rddataB;


reg [7:0] RAMA111[4095:0];
reg [7:0] RAMA110[4095:0];
reg [7:0] RAMA101[4095:0];
reg [7:0] RAMA100[4095:0];
reg [7:0] RAMA011[4095:0];
reg [7:0] RAMA010[4095:0];
reg [7:0] RAMA001[4095:0];
reg [7:0] RAMA000[4095:0];

reg [7:0] RAMB111[4095:0];
reg [7:0] RAMB110[4095:0];
reg [7:0] RAMB101[4095:0];
reg [7:0] RAMB100[4095:0];
reg [7:0] RAMB011[4095:0];
reg [7:0] RAMB010[4095:0];
reg [7:0] RAMB001[4095:0];
reg [7:0] RAMB000[4095:0];

integer i;

initial begin
   i = 4095;
   while(i) 
 
    begin
 
        RAMA111[i] = 0;
        RAMA110[i] = 0;
        RAMA101[i] = 0;
        RAMA100[i] = 0;
        RAMA011[i] = 0;
        RAMA010[i] = 0;
        RAMA001[i] = 0;
        RAMA000[i] = 0;

        RAMB111[i] = 0;
        RAMB110[i] = 0;
        RAMB101[i] = 0;
        RAMB100[i] = 0;
        RAMB011[i] = 0;
        RAMB010[i] = 0;
        RAMB001[i] = 0;
        RAMB000[i] = 0;
        i = i - 1;
    end
 
        RAMA111[i] = 0;
        RAMA110[i] = 0;
        RAMA101[i] = 0;
        RAMA100[i] = 0;
        RAMA011[i] = 0;
        RAMA010[i] = 0;
        RAMA001[i] = 0;
        RAMA000[i] = 0;

        RAMB111[i] = 0;
        RAMB110[i] = 0;
        RAMB101[i] = 0;
        RAMB100[i] = 0;
        RAMB011[i] = 0;
        RAMB010[i] = 0;
        RAMB001[i] = 0;
        RAMB000[i] = 0;         
end

reg [63:0] rddataA;
reg [63:0] rddataB;

reg [63:0] rddataA0q;                                                                                                            
reg [63:0] rddataB0q;                                                                                                            
reg [7:0] byte_sel;
reg [4:0] word_rdA_sel;                                                                              
reg [4:0] word_rdB_sel;                                                                              
reg [63:0] wrdata_aligned;      
                                                                                                     
wire [4:0] word_wr_sel;                                                                              
assign word_wr_sel = {wrsize[1:0],  wraddrs[2:0]};

wire [11:0] wraddrs_aligned;
assign wraddrs_aligned = wraddrs[14:3];
 
wire [11:0] rdaddrsA_aligned;
assign rdaddrsA_aligned = rdaddrsA[14:3];

wire [11:0] rdaddrsB_aligned;
assign rdaddrsB_aligned = rdaddrsB[14:3];


always@(*)                                                                                           
    case(word_rdA_sel)                                                                                
        5'b00_000 : rddataA = {56'h0000_0000_0000_00, rddataA0q[7:0]};       //bytes                    
        5'b00_001 : rddataA = {56'h0000_0000_0000_00, rddataA0q[15:8]};                           
        5'b00_010 : rddataA = {56'h0000_0000_0000_00, rddataA0q[23:16]};  
        5'b00_011 : rddataA = {56'h0000_0000_0000_00, rddataA0q[31:24]};   
        5'b00_100 : rddataA = {56'h0000_0000_0000_00, rddataA0q[39:32]}; 
        5'b00_101 : rddataA = {56'h0000_0000_0000_00, rddataA0q[47:40]};
        5'b00_110 : rddataA = {56'h0000_0000_0000_00, rddataA0q[55:48]};
        5'b00_111 : rddataA = {56'h0000_0000_0000_00, rddataA0q[63:56]};
        
        5'b01_000, 
        5'b01_001 : rddataA = {48'h0000_0000_0000, rddataA0q[15:0]};         //half-words
        5'b01_010,   
        5'b01_011 : rddataA = {48'h0000_0000_0000, rddataA0q[31:16]};       
        5'b01_100,  
        5'b01_101 : rddataA = {48'h0000_0000_0000, rddataA0q[47:32]};
        5'b01_110,
        5'b01_111 : rddataA = {48'h0000_0000_0000, rddataA0q[63:48]};
        
        5'b10_000,       
        5'b10_001,
        5'b10_010,       
        5'b10_011 : rddataA = {32'h000_0000, rddataA0q[31:0]};               //words
        5'b10_100,       
        5'b10_101,       
        5'b10_110,
        5'b10_111 : rddataA = {32'h000_0000, rddataA0q[63:32]}; 
        
        5'b11_000,
        5'b11_001,
        5'b11_010,       
        5'b11_011,                 
        5'b11_100,
        5'b11_101,
        5'b11_110,        
        5'b11_111 : rddataA = rddataA0q[63:0];                                 //double-words
    endcase
    
    
always@(*)                                                                                           
    case(word_rdB_sel)                                                                                
        5'b00_000 : rddataB = {56'h0000_0000_0000_00, rddataB0q[7:0]};       //bytes                    
        5'b00_001 : rddataB = {56'h0000_0000_0000_00, rddataB0q[15:8]};                           
        5'b00_010 : rddataB = {56'h0000_0000_0000_00, rddataB0q[23:16]};  
        5'b00_011 : rddataB = {56'h0000_0000_0000_00, rddataB0q[31:24]};   
        5'b00_100 : rddataB = {56'h0000_0000_0000_00, rddataB0q[39:32]}; 
        5'b00_101 : rddataB = {56'h0000_0000_0000_00, rddataB0q[47:40]};
        5'b00_110 : rddataB = {56'h0000_0000_0000_00, rddataB0q[55:48]};
        5'b00_111 : rddataB = {56'h0000_0000_0000_00, rddataB0q[63:56]};
        
        5'b01_000, 
        5'b01_001 : rddataB = {48'h0000_0000_0000, rddataB0q[15:0]};         //half-words
        5'b01_010,   
        5'b01_011 : rddataB = {48'h0000_0000_0000, rddataB0q[31:16]};       
        5'b01_100,  
        5'b01_101 : rddataB = {48'h0000_0000_0000, rddataB0q[47:32]};
        5'b01_110,
        5'b01_111 : rddataB = {48'h0000_0000_0000, rddataB0q[63:48]};
        
        5'b10_000,       
        5'b10_001,
        5'b10_010,       
        5'b10_011 : rddataB = {32'h000_0000, rddataB0q[31:0]};               //words
        5'b10_100,       
        5'b10_101,       
        5'b10_110,
        5'b10_111 : rddataB = {32'h000_0000, rddataB0q[63:32]}; 
        
        5'b11_000,
        5'b11_001,
        5'b11_010,       
        5'b11_011,                 
        5'b11_100,
        5'b11_101,
        5'b11_110,        
        5'b11_111 : rddataB = rddataB0q[63:0];                                 //double-words
    endcase
                                                                                                     
always@(*)                                                                                           
    case(word_wr_sel)                                                                                
        5'b00_000 : wrdata_aligned = {56'h0000_0000_0000_00, wrdata[7:0]};      //bytes                    
        5'b00_001 : wrdata_aligned = {48'h0000_0000_0000, wrdata[7:0], 8'h00};                          
        5'b00_010 : wrdata_aligned = {40'h0000_0000_00, wrdata[7:0], 16'h0000}; 
        5'b00_011 : wrdata_aligned = {32'h0000_0000, wrdata[7:0], 24'h00_0000};  
        5'b00_100 : wrdata_aligned = {24'h0000_00, wrdata[7:0], 32'h0000_0000};
        5'b00_101 : wrdata_aligned = {16'h0000, wrdata[7:0], 40'h00_0000_0000};
        5'b00_110 : wrdata_aligned = {8'h00, wrdata[7:0], 48'h0000_0000_0000};
        5'b00_111 : wrdata_aligned = {wrdata[7:0], 56'h00_0000_0000_0000};         
        
        5'b01_000, 
        5'b01_001 : wrdata_aligned = {48'h0000_0000_0000, wrdata[15:0]};       //half-words
        5'b01_010, 
        5'b01_011 : wrdata_aligned = {32'h0000_0000, wrdata[15:0], 16'h0000};      
        5'b01_100, 
        5'b01_101 : wrdata_aligned = {16'h0000, wrdata[15:0], 32'h0000_0000};
        5'b01_110,
        5'b01_111 : wrdata_aligned = {wrdata[15:0], 48'h0000_0000_0000};
        
        5'b10_000,       
        5'b10_001,
        5'b10_010,       
        5'b10_011 : wrdata_aligned = {32'h000_0000_0000, wrdata[31:0]};             //words
        5'b10_100,  
        5'b10_101,  
        5'b10_110,
        5'b10_111 : wrdata_aligned = {wrdata[31:0], 32'h000_0000_0000};   
        
        5'b11_000,
        5'b11_001,
        5'b11_010,       
        5'b11_011,                 
        5'b11_100,
        5'b11_101,
        5'b11_110,        
        5'b11_111 : wrdata_aligned = wrdata[63:0];                                 //double-words
    endcase

always@(*)          
        case(word_wr_sel)
            5'b00_000 : byte_sel = 8'b00000001;        //bytes
            5'b00_001 : byte_sel = 8'b00000010;
            5'b00_010 : byte_sel = 8'b00000100;
            5'b00_011 : byte_sel = 8'b00001000;
            5'b00_100 : byte_sel = 8'b00010000;
            5'b00_101 : byte_sel = 8'b00100000;
            5'b00_110 : byte_sel = 8'b01000000;
            5'b00_111 : byte_sel = 8'b10000000;
            
            5'b01_000, 
            5'b01_001 : byte_sel = 8'b00000011;               //half-words
            5'b01_010,  
            5'b01_011 : byte_sel = 8'b00001100;
            5'b01_100,  
            5'b01_101 : byte_sel = 8'b00110000;
            5'b01_110,
            5'b01_111 : byte_sel = 8'b11000000;
            
            5'b10_000,  
            5'b10_001,
            5'b10_010,  
            5'b10_011 : byte_sel = 8'b00001111;       //words
            5'b10_100,  
            5'b10_101,  
            5'b10_110,
            5'b10_111 : byte_sel = 8'b11110000;
            
            5'b11_000,
            5'b11_001,
            5'b11_010,  
            5'b11_011,   
            5'b11_100,
            5'b11_101,
            5'b11_110,  
            5'b11_111 : byte_sel = 8'b11111111;    //double words
        endcase

always @(posedge CLK) begin
     word_rdA_sel <= {rdAsize[1:0],  rdaddrsA[2:0]};
     word_rdB_sel <= {rdBsize[1:0],  rdaddrsB[2:0]};
end

                                                                                                                                 
always @(posedge CLK) begin   //side-A even                            
    if (RESET) rddataA0q <= 64'h0000_0000_0000_0000;                   
    else if (rdenA) rddataA0q <= {RAMA111[rdaddrsA_aligned],
                                  RAMA110[rdaddrsA_aligned],
                                  RAMA101[rdaddrsA_aligned],
                                  RAMA100[rdaddrsA_aligned],
                                  RAMA011[rdaddrsA_aligned],
                                  RAMA010[rdaddrsA_aligned],
                                  RAMA001[rdaddrsA_aligned],
                                  RAMA000[rdaddrsA_aligned]};
end

always @(posedge CLK) begin   //side-B even                            
    if (RESET) rddataB0q <= 64'h0000_0000_0000_0000;                   
    else if (rdenB) rddataB0q <= {RAMB111[rdaddrsB_aligned],
                                  RAMB110[rdaddrsB_aligned],
                                  RAMB101[rdaddrsB_aligned],
                                  RAMB100[rdaddrsB_aligned],
                                  RAMB011[rdaddrsB_aligned],
                                  RAMB010[rdaddrsB_aligned],
                                  RAMB001[rdaddrsB_aligned],
                                  RAMB000[rdaddrsB_aligned]};
end

always @(posedge CLK) begin   //side-A
    if (wren) begin
        if (byte_sel[7]) RAMA111[wraddrs_aligned] <= wrdata_aligned[63:56];
        if (byte_sel[6]) RAMA110[wraddrs_aligned] <= wrdata_aligned[55:48];
        if (byte_sel[5]) RAMA101[wraddrs_aligned] <= wrdata_aligned[47:40];
        if (byte_sel[4]) RAMA100[wraddrs_aligned] <= wrdata_aligned[39:32];
        if (byte_sel[3]) RAMA011[wraddrs_aligned] <= wrdata_aligned[31:24];
        if (byte_sel[2]) RAMA010[wraddrs_aligned] <= wrdata_aligned[23:16];
        if (byte_sel[1]) RAMA001[wraddrs_aligned] <= wrdata_aligned[15:8];
        if (byte_sel[0]) RAMA000[wraddrs_aligned] <= wrdata_aligned[7:0];
    end
end

always @(posedge CLK) begin   //side-B 
    if (wren) begin
        if (byte_sel[7]) RAMB111[wraddrs_aligned] <= wrdata_aligned[63:56];
        if (byte_sel[6]) RAMB110[wraddrs_aligned] <= wrdata_aligned[55:48];
        if (byte_sel[5]) RAMB101[wraddrs_aligned] <= wrdata_aligned[47:40];
        if (byte_sel[4]) RAMB100[wraddrs_aligned] <= wrdata_aligned[39:32];
        if (byte_sel[3]) RAMB011[wraddrs_aligned] <= wrdata_aligned[31:24];
        if (byte_sel[2]) RAMB010[wraddrs_aligned] <= wrdata_aligned[23:16];
        if (byte_sel[1]) RAMB001[wraddrs_aligned] <= wrdata_aligned[15:8];
        if (byte_sel[0]) RAMB000[wraddrs_aligned] <= wrdata_aligned[7:0];
    end
end

endmodule
