// Example testbench for SYMPLYON64 floating-point compute unit
// Author:  Jerry D. Harthcock  
// version 1.04  October, 28, 2017
//
// this testbench reads a .stl binary file and pushes the triangles into compute-unit global memory starting at location 0x10000
// the .stl 3D model is transformed according to the parameters in program memory 
// the compute-unit has four threads, so the testbench divides the number of triangles by 4 and that is roughly how many triangles each thread gets
// once the triangles are pushed, reset is released
// while the threads are crunching away, a breakpoint is set and enabled on thread 0, it is then single-stepped a few times and a monitor read/write is performed
// thread 0 is then released from breakpoint and while running real-time another monitor read/write is performed
// "threeD_xform.v" needs to be in the working simulation directory.  It is the hex file containing the 3D transform program the threads execute
// Alternatively, you could push the program into program memory thru the host port during initialization.
// 
// the results of the 3D transform is written to the file "result_trans.stl".  You can view the resulting model using virtually any online .STL file viewer
// the original .stl file must not be greater than 32k bytes, otherwise you will need to modify this testbench to process in more than one chunk at a time.


`timescale 1ns/100ps

module symplyon64_tb();

   reg clk;
   reg reset;


   reg [7:0]  STL_mem8[131071:0];       //8-bit memory initially loaded with .stl file

   reg [63:0] debug_wrdata; 
   reg debug_wren;
   reg [4:0] debug_wraddrs;
   reg debug_rden;
   reg [4:0] debug_rdaddrs;
   
   reg h_wren;
   reg [1:0] h_wrsize;
   reg [17:0] h_wraddrs;
   reg [63:0] h_wrdata;
   reg h_rden;
   reg [1:0] h_rdsize;
   reg [17:0] h_rdaddrs;
   
   reg tr0_IRQ;
   reg tr1_IRQ;
   reg tr2_IRQ;
   reg tr3_IRQ;
   
   wire [63:0] h_rddata; 
   wire [63:0] debug_rddata;
    
   wire all_done;
   
   wire tr0_done;
   wire tr1_done;
   wire tr2_done;
   wire tr3_done;
            
   integer triangle_count;
   integer tri_remaining;
   integer stl_addrs;
   integer tadrs;
   integer r, file;
         
compute_unit t(
    .CLK          (clk    ),
    .RESET_IN     (reset  ),
    
    .debug_wrdata (debug_wrdata ),
    .debug_wren   (debug_wren   ),
    .debug_wraddrs(debug_wraddrs),
    .debug_rden   (debug_rden   ),
    .debug_rdaddrs(debug_rdaddrs),
    .debug_rddata (debug_rddata ),
    
    .h_wren       (h_wren       ),
    .h_wrsize     (h_wrsize     ),
    .h_wraddrs    (h_wraddrs    ),
    .h_wrdata     (h_wrdata     ),
    .h_rden       (h_rden       ),
    .h_rdsize     (h_rdsize     ),
    .h_rdaddrs    (h_rdaddrs    ),
    .h_rddata     (h_rddata     ),
    
    .tr0_done     (tr0_done     ),
    .tr1_done     (tr1_done     ),
    .tr2_done     (tr2_done     ),
    .tr3_done     (tr3_done     ),
    
    .tr0_IRQ      (tr0_IRQ      ),
    .tr1_IRQ      (tr1_IRQ      ),
    .tr2_IRQ      (tr2_IRQ      ),
    .tr3_IRQ      (tr3_IRQ      )
    
    );

//debugger register addresses for access via debug port    
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

//brk_cntrl_reg bit identifiers
parameter tr3_sstep           = 6'h01F;
parameter tr3_frc_brk         = 6'h01E;
parameter tr3_mon_req         = 6'h01D;
parameter tr3_PC_EQ_BRKA_en   = 6'h01C;
parameter tr3_PC_EQ_BRKB_en   = 6'h01B;
parameter tr3_PC_GTE_BRKA_en  = 6'h01A;
parameter tr3_PC_LTE_BRKB_en  = 6'h019;
parameter tr3_PC_AND_en       = 6'h018;
parameter tr2_sstep           = 6'h017;
parameter tr2_frc_brk         = 6'h016;
parameter tr2_mon_req         = 6'h015;
parameter tr2_PC_EQ_BRKA_en   = 6'h014;
parameter tr2_PC_EQ_BRKB_en   = 6'h013;
parameter tr2_PC_GTE_BRKA_en  = 6'h012;
parameter tr2_PC_LTE_BRKB_en  = 6'h011;
parameter tr2_PC_AND_en       = 6'h010;
parameter tr1_sstep           = 6'h00F;
parameter tr1_frc_brk         = 6'h00E;
parameter tr1_mon_req         = 6'h00D;
parameter tr1_PC_EQ_BRKA_en   = 6'h00C;
parameter tr1_PC_EQ_BRKB_en   = 6'h00B;
parameter tr1_PC_GTE_BRKA_en  = 6'h00A;
parameter tr1_PC_LTE_BRKB_en  = 6'h009;
parameter tr1_PC_AND_en       = 6'h008;
parameter tr0_sstep           = 6'h007;
parameter tr0_frc_brk         = 6'h006;
parameter tr0_mon_req         = 6'h005;
parameter tr0_PC_EQ_BRKA_en   = 6'h004;
parameter tr0_PC_EQ_BRKB_en   = 6'h003;
parameter tr0_PC_GTE_BRKA_en  = 6'h002;
parameter tr0_PC_LTE_BRKB_en  = 6'h001;
parameter tr0_PC_AND_en       = 6'h000;
    
    
  assign all_done = tr0_done && tr1_done && tr2_done && tr3_done;
  
   initial begin
      clk = 0;
      reset = 1;
   end

   always #5 clk = !clk;

integer thread0_triangles;
integer thread1_triangles;
integer thread2_triangles;
integer thread3_triangles;

reg [31:0] thread0_tri;
reg [31:0] thread1_tri;
reg [31:0] thread2_tri;
reg [31:0] thread3_tri;

reg [31:0] thread0_first_tri;
reg [31:0] thread1_first_tri;
reg [31:0] thread2_first_tri;
reg [31:0] thread3_first_tri;

reg [63:0] debug_rd_data;

reg [63:0] brk_cntrl_reg;

reg [15:0] tr3_triggerA, tr2_triggerA, tr1_triggerA, tr0_triggerA;
reg [15:0] tr3_triggerB, tr2_triggerB, tr1_triggerB, tr0_triggerB;

reg [63:0] tr3_monitor_rd_data;
reg [63:0] tr2_monitor_rd_data;
reg [63:0] tr1_monitor_rd_data;
reg [63:0] tr0_monitor_rd_data;

integer remainder;

   initial begin
        debug_wrdata   = 64'h0000_0000_0000_0000;
        debug_wren     = 1'b0;
        debug_wraddrs  = 5'b00000;
        debug_rden     = 1'b0;
        debug_rdaddrs  = 5'b00000;
        
        h_wren         = 1'b0;
        h_wrsize       = 2'b00;
        h_wraddrs      = 18'h0_0000;
        h_wrdata       = 64'h0000_0000_0000_0000;
        h_rden         = 1'b0;
        h_rdsize       = 2'b00;
        h_rdaddrs      = 18'h0_0000;
        
        tr0_IRQ        = 1'b0;
        tr1_IRQ        = 1'b0;
        tr2_IRQ        = 1'b0;
        tr3_IRQ        = 1'b0;
        
        brk_cntrl_reg  = 64'h0000_0000_0000_0000;
        debug_rd_data  = 64'h0000_0000_0000_0000;
        tr0_triggerA   = 16'h0000;
        tr1_triggerA   = 16'h0000;
        tr2_triggerA   = 16'h0000;
        tr3_triggerA   = 16'h0000;
        tr0_triggerB   = 16'h0000;
        tr1_triggerB   = 16'h0000;
        tr2_triggerB   = 16'h0000;
        tr3_triggerB   = 16'h0000;

//        file = $fopen("olive.stl", "rb");   
//        file = $fopen("small_diamond.stl", "rb"); 
         file = $fopen("ring.stl", "rb");  
 
        r = $fread(STL_mem8[0], file);       // "olive.stl" loaded into 8-bit test bench memory
        $fclose(file);  

        triangle_count = {STL_mem8[83],  STL_mem8[82],  STL_mem8[81],  STL_mem8[80]};
        thread0_triangles = triangle_count / 4;  //number of triangles (plus any remainder) this thread gets
        thread1_triangles = thread0_triangles;
        thread2_triangles = thread0_triangles;
        thread3_triangles = thread0_triangles;
        remainder = triangle_count % 4;  //determine any remainder
        #1 if (remainder) begin
            thread0_triangles = thread0_triangles + 1;
            remainder = remainder - 1;
        end    
        #1 if (remainder) begin
            thread1_triangles = thread1_triangles + 1;
            remainder = remainder - 1;
        end    
        #1 if (remainder) begin
            thread2_triangles = thread2_triangles + 1;
            remainder = remainder - 1;
        end    
        #1 if (remainder) begin
            thread3_triangles = thread3_triangles + 1;
            remainder = remainder - 1;
        end    
     #1 thread0_tri = {thread0_triangles};
     #1 thread1_tri = {thread1_triangles};
     #1 thread2_tri = {thread2_triangles};
     #1 thread3_tri = {thread3_triangles};
        
     #1 thread0_first_tri = 32'h0001_0000;
     #1 thread1_first_tri = thread0_first_tri + (36 * thread0_tri);   // for byte-addressed RAM1
     #1 thread2_first_tri = thread1_first_tri + (36 * thread1_tri);   // for byte-addressed RAM1
     #1 thread3_first_tri = thread2_first_tri + (36 * thread2_tri);   // for byte-addressed RAM1
        stl_addrs = 96;  //first byte of first x1 of first triangle location (byte address) in STL_mem8
        tadrs = 18'h10000;  //first x1 of first triangle location (32-bit aligned) in risc memory
       tri_remaining = triangle_count;
      //triangle counts and start locations for each thread are poked into their respective private memory  
      #1 {t.ram0.RAMA011[12'b000_0000_0100_0], t.ram0.RAMA010[12'b000_0000_0100_0], t.ram0.RAMA001[12'b000_0000_0100_0], t.ram0.RAMA000[12'b000_0000_0100_0]} = thread0_first_tri[31:0];    //location in that thread's private memory where the 1st triangle can be found
      #1 {t.ram0.RAMB011[12'b000_0000_0100_0], t.ram0.RAMB010[12'b000_0000_0100_0], t.ram0.RAMB001[12'b000_0000_0100_0], t.ram0.RAMB000[12'b000_0000_0100_0]} = thread0_first_tri[31:0];    //location in that thread's private memory where the 1st triangle can be found
      #1 {t.ram0.RAMA011[12'b000_0000_0100_1], t.ram0.RAMA010[12'b000_0000_0100_1], t.ram0.RAMA001[12'b000_0000_0100_1], t.ram0.RAMA000[12'b000_0000_0100_1]} = thread0_tri[31:0];          //number of triangles this thread is to process
      #1 {t.ram0.RAMB011[12'b000_0000_0100_1], t.ram0.RAMB010[12'b000_0000_0100_1], t.ram0.RAMB001[12'b000_0000_0100_1], t.ram0.RAMB000[12'b000_0000_0100_1]} = thread0_tri[31:0];          //number of triangles this thread is to process
      
      #1 {t.ram0.RAMA011[12'b010_0000_0100_0], t.ram0.RAMA010[12'b010_0000_0100_0], t.ram0.RAMA001[12'b010_0000_0100_0], t.ram0.RAMA000[12'b010_0000_0100_0]} = thread1_first_tri[31:0];    //location in that thread's private memory where the 1st triangle can be found
      #1 {t.ram0.RAMB011[12'b010_0000_0100_0], t.ram0.RAMB010[12'b010_0000_0100_0], t.ram0.RAMB001[12'b010_0000_0100_0], t.ram0.RAMB000[12'b010_0000_0100_0]} = thread1_first_tri[31:0];    //location in that thread's private memory where the 1st triangle can be found
      #1 {t.ram0.RAMA011[12'b010_0000_0100_1], t.ram0.RAMA010[12'b010_0000_0100_1], t.ram0.RAMA001[12'b010_0000_0100_1], t.ram0.RAMA000[12'b010_0000_0100_1]} = thread1_tri[31:0];          //number of triangles this thread is to process
      #1 {t.ram0.RAMB011[12'b010_0000_0100_1], t.ram0.RAMB010[12'b010_0000_0100_1], t.ram0.RAMB001[12'b010_0000_0100_1], t.ram0.RAMB000[12'b010_0000_0100_1]} = thread1_tri[31:0];          //number of triangles this thread is to process
   
      #1 {t.ram0.RAMA011[12'b100_0000_0100_0], t.ram0.RAMA010[12'b100_0000_0100_0], t.ram0.RAMA001[12'b100_0000_0100_0], t.ram0.RAMA000[12'b100_0000_0100_0]} = thread2_first_tri[31:0];    //location in that thread's private memory where the 1st triangle can be found
      #1 {t.ram0.RAMB011[12'b100_0000_0100_0], t.ram0.RAMB010[12'b100_0000_0100_0], t.ram0.RAMB001[12'b100_0000_0100_0], t.ram0.RAMB000[12'b100_0000_0100_0]} = thread2_first_tri[31:0];    //location in that thread's private memory where the 1st triangle can be found
      #1 {t.ram0.RAMA011[12'b100_0000_0100_1], t.ram0.RAMA010[12'b100_0000_0100_1], t.ram0.RAMA001[12'b100_0000_0100_1], t.ram0.RAMA000[12'b100_0000_0100_1]} = thread2_tri[31:0];          //number of triangles this thread is to process
      #1 {t.ram0.RAMB011[12'b100_0000_0100_1], t.ram0.RAMB010[12'b100_0000_0100_1], t.ram0.RAMB001[12'b100_0000_0100_1], t.ram0.RAMB000[12'b100_0000_0100_1]} = thread2_tri[31:0];          //number of triangles this thread is to process
   
      #1 {t.ram0.RAMA011[12'b110_0000_0100_0], t.ram0.RAMA010[12'b110_0000_0100_0], t.ram0.RAMA001[12'b110_0000_0100_0], t.ram0.RAMA000[12'b110_0000_0100_0]} = thread3_first_tri[31:0];    //location in that thread's private memory where the 1st triangle can be found
      #1 {t.ram0.RAMB011[12'b110_0000_0100_0], t.ram0.RAMB010[12'b110_0000_0100_0], t.ram0.RAMB001[12'b110_0000_0100_0], t.ram0.RAMB000[12'b110_0000_0100_0]} = thread3_first_tri[31:0];    //location in that thread's private memory where the 1st triangle can be found
      #1 {t.ram0.RAMA011[12'b110_0000_0100_1], t.ram0.RAMA010[12'b110_0000_0100_1], t.ram0.RAMA001[12'b110_0000_0100_1], t.ram0.RAMA000[12'b110_0000_0100_1]} = thread3_tri[31:0];          //number of triangles this thread is to process
      #1 {t.ram0.RAMB011[12'b110_0000_0100_1], t.ram0.RAMB010[12'b110_0000_0100_1], t.ram0.RAMB001[12'b110_0000_0100_1], t.ram0.RAMB000[12'b110_0000_0100_1]} = thread3_tri[31:0];          //number of triangles this thread is to process

          @(posedge clk);
          
          while (tri_remaining) begin
          
            HOST_WRITE(2'b10, tadrs,   {STL_mem8[stl_addrs+3],  STL_mem8[stl_addrs+2],  STL_mem8[stl_addrs+1],  STL_mem8[stl_addrs  ]});   //x1
            HOST_WRITE(2'b10, tadrs+4, {STL_mem8[stl_addrs+7],  STL_mem8[stl_addrs+6],  STL_mem8[stl_addrs+5],  STL_mem8[stl_addrs+4]});   //y1
            HOST_WRITE(2'b10, tadrs+8, {STL_mem8[stl_addrs+11], STL_mem8[stl_addrs+10], STL_mem8[stl_addrs+9],  STL_mem8[stl_addrs+8]});   //z1

            HOST_WRITE(2'b10, tadrs+12, {STL_mem8[stl_addrs+15], STL_mem8[stl_addrs+14], STL_mem8[stl_addrs+13], STL_mem8[stl_addrs+12]});  //x2
            HOST_WRITE(2'b10, tadrs+16, {STL_mem8[stl_addrs+19], STL_mem8[stl_addrs+18], STL_mem8[stl_addrs+17], STL_mem8[stl_addrs+16]});  //y2
            HOST_WRITE(2'b10, tadrs+20, {STL_mem8[stl_addrs+23], STL_mem8[stl_addrs+22], STL_mem8[stl_addrs+21], STL_mem8[stl_addrs+20]});  //z2

            HOST_WRITE(2'b10, tadrs+24, {STL_mem8[stl_addrs+27], STL_mem8[stl_addrs+26], STL_mem8[stl_addrs+25], STL_mem8[stl_addrs+24]});  //x3
            HOST_WRITE(2'b10, tadrs+28, {STL_mem8[stl_addrs+31], STL_mem8[stl_addrs+30], STL_mem8[stl_addrs+29], STL_mem8[stl_addrs+28]});  //y3
            HOST_WRITE(2'b10, tadrs+32, {STL_mem8[stl_addrs+35], STL_mem8[stl_addrs+34], STL_mem8[stl_addrs+33], STL_mem8[stl_addrs+32]});  //z3
        
            tri_remaining = tri_remaining - 1;
            stl_addrs = stl_addrs + 50;      //skip over 16-bit attribute and norm part of vector
            tadrs = tadrs + 36;
         end 
 
            @(posedge clk);
         #1 h_wren         = 1'b0;
            h_wrsize       = 2'b00;
            h_wraddrs      = 18'h0_0000;
            h_wrdata       = 64'h0000_0000_0000_0000;
 
         
         #100 reset = 0;
         #100
         
         tr0_triggerA   = 16'h0117;
         SET_TRIGGER_A;
         
         brk_cntrl_reg[tr0_PC_EQ_BRKA_en] = 1'b1;
         ENABLE_TRIGGERS;
         
         READ_DEBUG_PORT(brk_status_addrs);
         while(~|debug_rd_data[4]) READ_DEBUG_PORT(brk_status_addrs);  // wait for break on tr0 to occur
         
         SSTEP(1'b0, 1'b0, 1'b0, 1'b1);
         SSTEP(1'b0, 1'b0, 1'b0, 1'b1);
         SSTEP(1'b0, 1'b0, 1'b0, 1'b1); 
     
         MONITOR_WRITE(16'h00100, 64'hA5A5_5A5A_A5A5_5A5A, 1'b0, 1'b0, 1'b0, 1'b1);      
         MONITOR_READ(16'h0100,1'b0, 1'b0, 1'b0, 1'b1);      
     
         RUN_THREADS( 1'b0, 1'b0, 1'b0, 1'b1);  //a "1" for the specified thread(s) means "run" ie, clear the force break for such thread(s) and do a sstep to step out of the break
         @(posedge clk);   //allow time to do something
         @(posedge clk);
         @(posedge clk);                                                                              
         @(posedge clk);
         MONITOR_WRITE(16'h0100, 64'h600D_C001_FEED_C001, 1'b0, 1'b0, 1'b0, 1'b1);   
         MONITOR_READ(16'h0100,1'b0, 1'b0, 1'b0, 1'b1);    


          
         #1 wait (~all_done);
         #1 wait (all_done);

         
         #1
         stl_addrs = 96;  //first byte of first x1 of first triangle location (byte address) in STL_mem8
         tadrs = 18'h10000;  //first x1 of first triangle location (32-bit aligned) in risc memory
         tri_remaining = triangle_count;
         #1  @(posedge clk); 
                                                              
         while (tri_remaining) begin
         
             HOST_READ(2'b10, tadrs);
             {STL_mem8[stl_addrs+3],  STL_mem8[stl_addrs+2],  STL_mem8[stl_addrs+1],  STL_mem8[stl_addrs]}   = h_rddata[31:0];  //x1
             HOST_READ(2'b10, tadrs+4);
             {STL_mem8[stl_addrs+7],  STL_mem8[stl_addrs+6],  STL_mem8[stl_addrs+5],  STL_mem8[stl_addrs+4]} = h_rddata[31:0];  //y1
             HOST_READ(2'b10, tadrs+8);
             {STL_mem8[stl_addrs+11], STL_mem8[stl_addrs+10], STL_mem8[stl_addrs+9],  STL_mem8[stl_addrs+8]} = h_rddata[31:0];  //z1
             
             HOST_READ(2'b10, tadrs+12);
             {STL_mem8[stl_addrs+15], STL_mem8[stl_addrs+14], STL_mem8[stl_addrs+13], STL_mem8[stl_addrs+12]} = h_rddata[31:0]; //x2
             HOST_READ(2'b10, tadrs+16);
             {STL_mem8[stl_addrs+19], STL_mem8[stl_addrs+18], STL_mem8[stl_addrs+17], STL_mem8[stl_addrs+16]} = h_rddata[31:0]; //y2
             HOST_READ(2'b10, tadrs+20);
             {STL_mem8[stl_addrs+23], STL_mem8[stl_addrs+22], STL_mem8[stl_addrs+21], STL_mem8[stl_addrs+20]} = h_rddata[31:0]; //z2
             
             HOST_READ(2'b10, tadrs+24);
             {STL_mem8[stl_addrs+27], STL_mem8[stl_addrs+26], STL_mem8[stl_addrs+25], STL_mem8[stl_addrs+24]} = h_rddata[31:0]; //x3
             HOST_READ(2'b10, tadrs+28);
             {STL_mem8[stl_addrs+31], STL_mem8[stl_addrs+30], STL_mem8[stl_addrs+29], STL_mem8[stl_addrs+28]} = h_rddata[31:0]; //y3
             HOST_READ(2'b10, tadrs+32);
             {STL_mem8[stl_addrs+35], STL_mem8[stl_addrs+34], STL_mem8[stl_addrs+33], STL_mem8[stl_addrs+32]} = h_rddata[31:0]; //z3


             
            tri_remaining = tri_remaining - 1;
            stl_addrs = stl_addrs + 50;      //skip over 16-bit attribute and norm part of vector
            tadrs = tadrs + 36;
         end 
         
         #1  h_rden = 1'b0;

         stl_addrs = 0;        
         file = $fopen("result_trans.stl", "wb");            
         while(r) begin
             $fwrite(file, "%c", STL_mem8[stl_addrs]);
             #1 stl_addrs = stl_addrs + 1;
             r = r - 1;
         end 
         #1
         $fclose(file);
         
         $finish;                  
   end 



task HOST_WRITE;
    input [1:0]  wr_size;
    input [17:0] wr_addrs;
    input [63:0] wr_data;
    begin
        h_wren = 1'b1;
        h_wrsize = wr_size;
        h_wraddrs = wr_addrs;
        h_wrdata = wr_data;
     #1 @(posedge clk);
    end
endtask 

task HOST_READ;
    input [1:0]  rd_size;
    input [17:0] rd_addrs;
    begin
        h_rden = 1'b1;
        h_rdsize = rd_size;
        h_rdaddrs = rd_addrs;
     #1 @(posedge clk);
    end
endtask        

   
task SET_TRIGGER_A;
    begin
      WRITE_DEBUG_PORT(trigger_A_addrs, {tr3_triggerA, tr2_triggerA, tr1_triggerA, tr0_triggerA});
    end
endtask

task SET_TRIGGER_B;
    begin
      WRITE_DEBUG_PORT(trigger_B_addrs, {tr3_triggerB, tr2_triggerB, tr1_triggerB, tr0_triggerB});    
    end
endtask
    
task ENABLE_TRIGGERS;
    begin
        WRITE_DEBUG_PORT(brk_cntrl_addrs, brk_cntrl_reg);
    end
endtask    

task SSTEP;     // a "1" for the respective thread(s) means step such thread(s)--assuming such is/are already in break state
    input tr3_step, tr2_step, tr1_step, tr0_step;
    begin
      if (tr3_step) {brk_cntrl_reg[tr3_sstep], brk_cntrl_reg[tr3_frc_brk]} = 2'b11; 
      if (tr2_step) {brk_cntrl_reg[tr2_sstep], brk_cntrl_reg[tr2_frc_brk]} = 2'b11; 
      if (tr1_step) {brk_cntrl_reg[tr1_sstep], brk_cntrl_reg[tr1_frc_brk]} = 2'b11; 
      if (tr0_step) {brk_cntrl_reg[tr0_sstep], brk_cntrl_reg[tr0_frc_brk]} = 2'b11;
      WRITE_DEBUG_PORT(brk_cntrl_addrs, brk_cntrl_reg);
      while (~((tr3_step ? debug_rd_data[3] : 1'b1 ) && 
               (tr2_step ? debug_rd_data[2] : 1'b1 ) && 
               (tr1_step ? debug_rd_data[1] : 1'b1 ) && 
               (tr0_step ? debug_rd_data[0] : 1'b1 ))) READ_DEBUG_PORT(brk_status_addrs);   //wait for everyone specified to step
 
      if (tr3_step) {brk_cntrl_reg[tr3_sstep], brk_cntrl_reg[tr3_frc_brk]} = 2'b01; 
      if (tr2_step) {brk_cntrl_reg[tr2_sstep], brk_cntrl_reg[tr2_frc_brk]} = 2'b01; 
      if (tr1_step) {brk_cntrl_reg[tr1_sstep], brk_cntrl_reg[tr1_frc_brk]} = 2'b01; 
      if (tr0_step) {brk_cntrl_reg[tr0_sstep], brk_cntrl_reg[tr0_frc_brk]} = 2'b01;
      WRITE_DEBUG_PORT(brk_cntrl_addrs, brk_cntrl_reg);
      debug_rd_data[3:0] = 4'b0000;
    end   
endtask

    
task RUN_THREADS;  //a "1" for the specified thread(s) means "run" ie, clear the force break for such thread(s)
    input tr3_run, tr2_run, tr1_run, tr0_run;     
    begin
      if (tr3_run) {brk_cntrl_reg[tr3_sstep], brk_cntrl_reg[tr3_frc_brk]} = 2'b10; 
      if (tr2_run) {brk_cntrl_reg[tr2_sstep], brk_cntrl_reg[tr2_frc_brk]} = 2'b10; 
      if (tr1_run) {brk_cntrl_reg[tr1_sstep], brk_cntrl_reg[tr1_frc_brk]} = 2'b10; 
      if (tr0_run) {brk_cntrl_reg[tr0_sstep], brk_cntrl_reg[tr0_frc_brk]} = 2'b10;
      WRITE_DEBUG_PORT(brk_cntrl_addrs, brk_cntrl_reg);
      @(posedge clk);   //allow time to complete
      @(posedge clk);
      @(posedge clk);
      @(posedge clk);
      if (tr3_run) {brk_cntrl_reg[tr3_sstep], brk_cntrl_reg[tr3_frc_brk]} = 2'b00; 
      if (tr2_run) {brk_cntrl_reg[tr2_sstep], brk_cntrl_reg[tr2_frc_brk]} = 2'b00; 
      if (tr1_run) {brk_cntrl_reg[tr1_sstep], brk_cntrl_reg[tr1_frc_brk]} = 2'b00; 
      if (tr0_run) {brk_cntrl_reg[tr0_sstep], brk_cntrl_reg[tr0_frc_brk]} = 2'b00;
      WRITE_DEBUG_PORT(brk_cntrl_addrs, brk_cntrl_reg);
    end
endtask

task FORCE_BREAK;   // a "1" for the specified thread(s) means "force break" for such thread(s)
    input tr3_force_brk, tr2_force_brk, tr1_force_brk, tr0_force_brk;         
    begin
      if (tr3_force_brk) {brk_cntrl_reg[tr3_sstep], brk_cntrl_reg[tr3_frc_brk]} = 2'b01; 
      if (tr2_force_brk) {brk_cntrl_reg[tr2_sstep], brk_cntrl_reg[tr2_frc_brk]} = 2'b01; 
      if (tr1_force_brk) {brk_cntrl_reg[tr1_sstep], brk_cntrl_reg[tr1_frc_brk]} = 2'b01; 
      if (tr0_force_brk) {brk_cntrl_reg[tr0_sstep], brk_cntrl_reg[tr0_frc_brk]} = 2'b01;
      WRITE_DEBUG_PORT(brk_cntrl_addrs, brk_cntrl_reg);
    end
endtask    
    
task MONITOR_READ;
    input [15:0] monitor_rd_addrs;
    input tr3_monitor_rd, tr2_monitor_rd, tr1_monitor_rd, tr0_monitor_rd;  // a "1" for the specified thread(s) means the specified thread(s) perform a monitor read
    begin                                             //read-from and   write-to
      WRITE_DEBUG_PORT(mon_addrs_addrs,{32'h0000_0000, monitor_rd_addrs, 16'hFF00});  //location 16'hFF00 is a monitor read register visible to the debugger h/w
      @(posedge clk);   //allow time to complete
      @(posedge clk);
      @(posedge clk);
      @(posedge clk);
      if (tr3_monitor_rd) brk_cntrl_reg[tr3_mon_req] = 1'b1; 
      if (tr2_monitor_rd) brk_cntrl_reg[tr2_mon_req] = 1'b1; 
      if (tr1_monitor_rd) brk_cntrl_reg[tr1_mon_req] = 1'b1; 
      if (tr0_monitor_rd) brk_cntrl_reg[tr0_mon_req] = 1'b1;
      WRITE_DEBUG_PORT(brk_cntrl_addrs, brk_cntrl_reg);
      @(posedge clk);   //allow time to complete
      @(posedge clk);
      @(posedge clk);                                                                              
      @(posedge clk);
      brk_cntrl_reg[tr3_mon_req] = 1'b0;
      brk_cntrl_reg[tr2_mon_req] = 1'b0;
      brk_cntrl_reg[tr1_mon_req] = 1'b0;
      brk_cntrl_reg[tr0_mon_req] = 1'b0;
      WRITE_DEBUG_PORT(brk_cntrl_addrs, brk_cntrl_reg);
      @(posedge clk);
      READ_DEBUG_PORT(tr0_monrd_reg_addrs);
      tr0_monitor_rd_data = debug_rd_data;
      @(posedge clk);
      READ_DEBUG_PORT(tr1_monrd_reg_addrs);
      tr1_monitor_rd_data = debug_rd_data;
      @(posedge clk);
      READ_DEBUG_PORT(tr2_monrd_reg_addrs);
      tr2_monitor_rd_data = debug_rd_data;
      @(posedge clk);
      READ_DEBUG_PORT(tr3_monrd_reg_addrs);
      tr3_monitor_rd_data = debug_rd_data;
      @(posedge clk);
    end
endtask
      
task MONITOR_WRITE;
    input [15:0] monitor_wr_addrs;
    input [63:0] monitor_wr_data;    
    input tr3_monitor_wr, tr2_monitor_wr, tr1_monitor_wr, tr0_monitor_wr;  // a "1" for the specified thread(s) means the specified thread(s) perform a monitor write
    begin                                           //read-from and   write-to
      WRITE_DEBUG_PORT(mon_addrs_addrs,{32'h0000_0000, 16'hFF00, monitor_wr_addrs});  //the specified thread(s) will read from its private location 16'hFF00 and write it to the location specified
      WRITE_DEBUG_PORT(mon_write_reg_addrs, monitor_wr_data);
      @(posedge clk);   //allow time to complete
      @(posedge clk);
      if (tr3_monitor_wr) brk_cntrl_reg[tr3_mon_req] = 1'b1; 
      if (tr2_monitor_wr) brk_cntrl_reg[tr2_mon_req] = 1'b1; 
      if (tr1_monitor_wr) brk_cntrl_reg[tr1_mon_req] = 1'b1; 
      if (tr0_monitor_wr) brk_cntrl_reg[tr0_mon_req] = 1'b1;
      WRITE_DEBUG_PORT(brk_cntrl_addrs, brk_cntrl_reg);
      @(posedge clk);   //allow time to complete
      @(posedge clk);
      @(posedge clk);                                                                              
      @(posedge clk);
      brk_cntrl_reg[tr3_mon_req] = 1'b0;
      brk_cntrl_reg[tr2_mon_req] = 1'b0;
      brk_cntrl_reg[tr1_mon_req] = 1'b0;
      brk_cntrl_reg[tr0_mon_req] = 1'b0;
      WRITE_DEBUG_PORT(brk_cntrl_addrs, brk_cntrl_reg);
      @(posedge clk);
    
    end
endtask

task WRITE_DEBUG_PORT;
    input [4:0] wraddrs;
    input [63:0] wrdata;
    begin
       @(posedge clk);
    #1 debug_wren = 1'b1;
       debug_wraddrs = wraddrs;   
       debug_wrdata = wrdata;
       @(posedge clk);
    #1 debug_wren = 1'b0;
       debug_wraddrs = 16'h0000;   
       debug_wrdata = 64'h0000_0000_0000_0000;
    end
endtask

task READ_DEBUG_PORT;
    input [4:0] rdaddrs;
    begin
       @(posedge clk);
    #1 debug_rden = 1'b1;
       debug_rdaddrs = rdaddrs;   
       @(posedge clk);
       if (debug_rden) debug_rd_data = debug_rddata;
    #1 debug_rden = 1'b0;   
       debug_rdaddrs = 16'h0000;
    end
endtask        
        
    
endmodule 

