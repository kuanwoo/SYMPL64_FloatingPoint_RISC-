![](https://github.com/jerry-D/SYMPL-FP324-AXI4-GP-GPU/blob/master/web_logo.jpg)

## SYMPL “Opcode-less” Instruction Set Architecture (ISA) for a 64-Bit Interleaving, Multi-threading GP-GPU Compute Unit 
### Featuring: FloPoCo--Generated Floating-Point Operators

At this repository you will find all the Verilog RTL source code needed to simulate and synthesize the opcode-less, 64-bit GP-GPU Compute Unit shown in the block diagram below. The purpose of the instant design is to demonstrate the SYMPL 64-bit ISA and to provide an easy-to-modify template that can be used to evaluate and test various operators, especially FloPoCo-generated operators. 

This implementation attempts to be IEEE754-2008-compliant, featuring the ability to employ double, single, and half precision floating-point operators.  All operators are memory-mapped and include directed rounding, alternate and alternate delayed exception handling, per the IEEE754-2008 spec.  The directed rounding feature is part of the instruction and is done in hardware.  For invalid exceptions, non-signaling NANs with diagnostic payloads are substituted and delivered.

The following FP operators are (or will be) included (presently in single precision): FADD, FSUB, FMA, DOT, FMUL, FDIV, SQRT, LOG, EXP, PWR, ITOF, FTOI, DTOS, STOD, DTOH, HTOD, STOH, HTOS, SIN, COS, ATAN.  

### Real-Time Debug On-Chip

Additionally, this design comes with on-chip debug capability. Each thread has independent h/w breakpoints with programmable pass-counters, single-steps, 4-level deep PC discontinuity trace buffer, and real-time data exchange/monitoring. Thread registers can be read and modified in real-time without affecting ongoing processes. Threads can be independently or simultaneously breakpointed, single-stepped or released. Presently all this is done through a generic port which can be matted with a JTAG TAP, CPU I/O port, AXI4, etc. The test bench provided at this repository has examples of breakpoints, single-steps, etc.

This design was developed using the “free” version of Xilinx Vivado, version 2015.1, targeted to a Kintex7, -3 speed grade. To obtain a copy of the latest version of Vivado, visit Xilinx' website at www.Xilinx.com 

After place and route, it was determined that this 64-bit design will clock at roughly 120MHz in a Kintex7 without constraints of any kind except for specifying what pin to use as the clock and at what clock rate. About 80% of the delays are attributed to routing and not logic propagation delays. 

The instant design incorporates FloPoCo single-precision operators because this is what I have on hand at the moment. If you would like to evaluate this ISA using double or half-precision floating-point operators, visit FloPoCo's website at:

http://flopoco.gforge.inria.fr

There you will find everything you need to generate virtually any kind of floating-point operator and many others.

The simplest way to convert the design to half or double-precision, is to use the existing operator wrappers as templates.  Care should be taken to properly adjust the number of “delay” registers to correspond to the latency of the substituted operator.  For instance, half-precision will generally require fewer stages than single-precision, and double-precision will generally require more.

Also at this repository you will find the SYMPL “opcode-less” ISA instruction table that can be used with “CROSS-32” Universal Cross-Assembler to compile the example 3D-transform thread used in the example simulation. To obtain a copy of CROSS-32, visit Data-Sync Engineering's website: 

http://www.cdadapter.com/cross32.htm
sales@datasynceng.com

A copy of the Cross-32 manual can be viewed online here: 

http://www.cdadapter.com/download/cross32.pdf

Continue reading below the block diagram to find out more about this design, the instruction set, how to set up the simulation, etc.  If you have any questions, you can direct them to me at: sympl.gpu@gmail.com

[Click here to see a larger view of the block diagram (116kB)](https://github.com/jerry-D/SYMPL64_FloatingPoint_RISC-/tree/master/Doc/images/Block_diagram_96dpi.png)

![](https://github.com/jerry-D/SYMPL64_FloatingPoint_RISC-/blob/master/Doc/images/Block_diagram_small_96dpi.jpg)

## SYMPL64 ISA General Description

The SYMPL64 Compute Instruction Set Architecture contains no "op-codes".  All operators, including PC, Stack, Status, Auxiliary Registers, logical, shift, integer and floating-point operators are memory-mapped.  Each logic, shift, integer and floating-point operator occupies 16 locations in each thread-unit's memory map, each accepting up to two, 8, 16, 32, or 64-bit operands simultaneously, in any combination.

The SYMPL64 ISA employs strict typing.  Meaning that the destination, sourceA and sourceB have their own sign-extension and data size/length fields.  The actual memory-mapped operator location from/to where the data is read or written determines what type of data it is, i.e., float or integer. 

SYMPL64 Compute Unit employs a modified Harvard architecture, meaning that it has separate program and data memory address and data buses. It has immediate, direct and indirect addressing modes, as well as table read from program memory using either direct or indirect addressing modes.  The private memory, including private result buffers for each operator, employ three-port memory (i.e., one write-side and two read-side ports).  The three-port memory enables reading sourceA and sourceB operands simultaneously and then immediately pushing them back into the same or different operator.  The present implementation incorporates three-port program and global data memory, but the use of three-port for these memories are optional if your application does not use or need the @table-read addressing mode or if your application will never need two operands from global memory simultaneously.

Included in this SYMPL64 ISA repository is an instruction table that can be used with “CROSS-32” Universal Cross-assembler to assemble/compile executables written in either SYMPL64 Intermediate Language (IL), SYMPL64 assembly language or in-line mix of both.

If you plan to write in pure assembly language, the only mnemonic you need to remember is “.”, which means: “MOV”. Of course, if you like to type, you can also use “MOV” or “m”. This example shows what a shift instruction looks like in SYMPL64 assembly language:
```
.   uw:shft.0, uw:triangles, RIGHT, 1           ;divide total triangles x2 to determine number of triangles per thread
.   uw:triDivXn, uw:shft.0                      ;move result out of shift operator result buffer 0 into memory 
```
In the example above, “uw” means destination is unsigned 32-bit word that is pushed into shift operator input 0.  The value being shifted is unsigned (32-bit) word “triangles”.  The operation to be done is shift “triangles” right by one bit position.  Note that a thread's STATUS register is not updated until a result is read out of a given operator's result buffer.  Simply moving data around from one non-operator memory location to another has no affect on a thread's STATUS register.

Here is the same instruction sequence written in SYMPL64 IL:
```
uw   shft.0 = SHFT:(uw:triangles, RIGHT, 1)
uw   triDivXn = uw:shft.0
```
Instruction bit field definitions common to both direct and indirect addressing modes:
```
RM[1:0] Directed Rounding Mode specifier for float results
  00 = round nearest
  01 = round to positive infinity
  10 = round to negative infinity
  11 = round to zero 

IM[1:0] Specifies from which memory the operand read is to take place
  00 = both operand A and operand B are read from data memory using either direct or indirect addressing modes
  01 = operand A is either direct or indirect and operand B is 8 or 16-bit immediate
  10 = operand A is read from program memory using direct table read from program memory addressing mode operand B is 
       either direct or indirect and NEVER immediate
  11 = 32-bit immediate

SEXT 1 = signed (sign-extended); 0 = unsigned (zero-extended)

LEN[1:0] Length/size, in bytes, of source/destination
  00 = 1 byte
  01 = 2 bytes (half-word)
  10 = 4 bytes (word)
  11 = 8 bytes (double-word)
  
IND 1 = indirect addressing mode for that field
  0 = direct addressing mode for that field

IMOD is used with IND = 1, meaning it is only used with indirect addressing mode for a given field

IMOD = 1 means: use signed AMOUNT field + ARn contents for effective address; ARn is not modified

for example:

    uw   shft.0 = SHFT:(uw:*AR2[45], RIGHT, 3)
    uw   shft.1 = SHFT:(uw:*AR1[-20], RIGHT, 3)

IMOD = 0 means: use ARn contents as pointer for read or write. Then automatically post-modify 
         the contents of ARn by adding or subtracting UNsigned AMOUNT field to/from it.

for example:

   uw   shft.0 = SHFT:(uw:*AR2++[8], RIGHT, 3)
   uw   shft.1 = SHFT:(uw:*AR1--[5], LEFT, 6)
```
-------------------------------------------------------------------------------------
## *Indirect Addressing Mode Instruction Format

note: indirect addressing mode can be mixed and matched with:
- indirect addressing mode (any combination)
- immediate addressing mode for srcB when using dual operands
- immediate addressing mode for srcA when using it as a single operand
- table-read from program memory as srcA for dual operands
- table-read from program memory as srcA when using it as a single operand
- immediate data and table-read address modes must not appear on the same line

![](https://github.com/jerry-D/SYMPL64_FloatingPoint_RISC-/blob/master/Doc/images/indirect.png)

SYMPL64 ISA presently provides eight memory-mapped registers for use as indirect address pointers:
AR0, AR1, AR2, AR3, AR4, AR5, AR6 and SP.  Refer to the SYMPL64 ISA instruction table in the ASM folder for their respective addresses.

SP operates as a Stack Pointer, in that it behaves a bit differently than AR0-AR6. Specifically, it supplies a per-decremented value when used as a read pointer. When used as a write pointer, it behaves the same as the auxiliary registers AR0 through AR6.  On RESET, SP is pointing to location 0x00FF8 in each thread's memory space.

The SYMPL64 provides two indirect addressing modes: Indirect with relative +/- (i.e., signed) offset and indirect with no offset but with automatic +/- post-modification by the amount specified.  The amount of either offset or post-modification is always in bytes to accommodate byte, half-word, word and double-word data sizes.  For instance, if you are moving a block of double-word
 (64-bit) data with automatic post-modification, use “8” as the increment or decrement amount.  If you are moving bytes, use “1”.  If moving words (32-bits), use “4” and so on. The amount of offset for relative indirect is in the range +/- 2047 (bytes).  The amount of automatic post-modification is in the range of 0-4095 (bytes).

Indirect Address Mode Syntax

Immediately preceding any of the above ARn or SP with “*” signals the assembler that the specified ARn or SP is to be used as an indirect pointer. Post-fixing the specified auxiliary register or SP with either “++” or “--” signals post-modification mode. If the post-modification signal is absent, then it's relative indirect mode. For indirect addressing, both indirect with post-modification and relative indirect must have an amount specified in the immediately following square brackets. 

Indirect Relative (example):
```
uw   AR0 = uw:#X_start                         ;load AR0 with pointer to X_start
uw   AR1 = uw:#Y_start                         ;load AR1 with pointer to Y_start
uw   fmul.0 = FMUL:(uw:*AR0[0], uw:*AR1[0])    ;push operandA and operandB into input 0 of FMUL operator 
```
Indirect with Post-Modification (example):

(Note that this example employs the REPEAT instruction to perform 16 floating-point divides by feeding all 16 FDIV operator inputs, such that, by the time the final operand pair is pushed in, at least the first result corresponding to the first push is available to be read out without any stalls) 
```
uw   AR0 = uw:#X_start           ;immediate load of pointer to X_start
uw   AR1 = uw:#Y_start           ;immediate load of pointer to Y_start
uw   AR2 = uw:#fdiv.0            ;immediate load of pointer to first FDIV operator input
uw   AR3 = uw:#return_buffer

     REPEAT  uw:#15              ;execute and then repeat the following instruction 15 more times for a total of 16 times.     
uw   *AR2++[4] = FDIV:(uw:*AR0++[4], uw:*AR1++[4])   ;push new operandA and operandB into input n of FDIV operator 

uw   AR2 = uw:#fdiv.0                                ;point to first FDIV result buffer

     REPEAT uw:#15     
uw   *AR3++[4] = uw:*AR2++[4]                        ;pull all 16 FDIV results out
```
-------------------------------------------------------------------------------------
# Direct Addressing Mode Instruction Format
note: direct addressing mode can be mixed and matched with:
- indirect addressing mode (any combination)
- immediate addressing mode for srcB when using dual operands
- immediate addressing mode for srcA using a single operand
- table-read from program memory for srcA for dual operands
- table-read from program memory for srcA for single operand
- immediate data and table-read address modes must not appear on the same line

![](https://github.com/jerry-D/SYMPL64_FloatingPoint_RISC-/blob/master/Doc/images/direct.png)

Direct Address Mode Syntax

Only the first 64k bytes of the SYMPL64 address space can be accessed using the direct addressing mode. All thread registers and operators reside within this space so they can be accessed using the direct addressing mode. Here are just a few examples:
```
uh   LPCNT0 = uh:triangles                       ;load loop counter 0 with number of triangles to process
uw   bclr.0 = BCLR:(uw:STATUS, ub:#Done_bit)     ;clear the status register Done bit
uw   STATUS = bclr.0 
uw   cos.0 = COS:(uh:rotateX_amount)
```
----------------------------------------------------------------------------------
# #Immediate Addressing Mode Instruction Format
Note: immediate addressing mode must not be used with table-read
addressing mode on the same assembly line

![](https://github.com/jerry-D/SYMPL64_FloatingPoint_RISC-/blob/master/Doc/images/immediate.png)

Immediate Address Mode Syntax

Preceding a source value with the “#” character signals the assembler to source the immediately available 8, 16 or 32-bit value provided in the fetched instruction as the source data.

Immediate operands may appear on the assembly line only in the srcB position if there is also a direct or indirect operand in the the srcA position. An immediate operand may appear on the assembly line as a sole operand. Immediate operands may not appear on the same assembly line as a @table-read operand.

--------------------------------------------------------------------------------------
# @Table-Read from Program Memory Addressing Mode Instruction Format
Note: @table-read can be used as a 16-bit srcA operand for retrieving constants, etc., 
directly from program memory, either alone or in combination with a direct or 
indirect srcB data memory operand. The @table-read addressing mode must not be 
used with immediate addressing mode operands on the same assembly line. 

![](https://github.com/jerry-D/SYMPL64_FloatingPoint_RISC-/blob/master/Doc/images/table_read.png)

@Table-Read Address Mode Syntax

Preceding a srcA value with the “@” character signals the assembler that srcA is to be directly sourced from program memory within the address range from 0x0000 to 0xFFFF. Presently, granularity for each @table-read is double-word. In other words, @0x0000 means the first 64 bits, @0x0001 means the second 64 bits and so on.

@srcA operands must not appear on the same assembly line as #srcB (#immediate) operands. @table-read is useful for directly retrieving parameters sourced in program memory. 

Example:
```
uw   AR0 = ud:@pbuf_start           ;load AR0 with parameter buffer start location specified in program memory
                                    ;in this example, the upper 32 bits are truncated/ignored (assuming AR0 is 32 bits wide).
```
--------------------------------------------------------------------------------
# Bit Test and Branch (if Set) Operator Format 
note: test bit# of contents of srcA
if set, then load PC with relative +/- displacement 
srcA can be direct or indirect address mode
range is -8192 to +8191 from thread's PC

![](https://github.com/jerry-D/SYMPL64_FloatingPoint_RISC-/blob/master/Doc/images/BTBS.png)


--------------------------------------------------------------------------------
# Bit Test and Branch (if Clear) Operator Format 
note: test bit# of contents of srcA
if clear, then load PC with relative +/- displacement 
srcA can be direct or indirect address mode
range is -8192 to +8191 from thread's PC

![](https://github.com/jerry-D/SYMPL64_FloatingPoint_RISC-/blob/master/Doc/images/BTBC.png)

-----------------------------------------------------------------------------------
# (Long) Unconditional Branch Operator Format
note: unconditional branch relative
load PC with relative +/- displacement 
srcB can be direct or indirect address mode 
range is -2147483648 to +2147483647 from thread's PC 

![](https://github.com/jerry-D/SYMPL64_FloatingPoint_RISC-/blob/master/Doc/images/bral.png)

--------------------------------------------------------------------------------
# Shift Operator Format
note: shifts the specified data the specified number of times
using the specified shift mode. It affects C, Z and N 
when the result is read out of the specified (1 of 16)
SHFT result buffers. 

![](https://github.com/jerry-D/SYMPL64_FloatingPoint_RISC-/blob/master/Doc/images/shift.png)

# No Opcodes

One of the unique features of the SYMPL64 ISA is that there are no opcode fields in the instruction, as the primary instruction pipeline only knows how to do one thing and one thing only—-MOVE—-but it does it very, very well, due to its powerful addressing modes.

By freeing up bits in the 64-bit instruction word that would ordinarily be used for opcodes, not only is direct addressing reach increased for destination, sourceA and sourceB operands, but more powerful indirect addressing modes, stricter typing, sign-extension and directed rounding modes for floating-point operators can be implemented in a more practical and more efficient and orthogonal way. 

Furthermore, by eliminating the chore of fetching, decoding and executing opcodes from the core's primary instruction pipeline, the inherent bottle neck associated with such process is also eliminated, thereby streamlining and simplifying it. Meaning that all instructions execute in just one clock. 

Instead of opcodes, the SYMPL64 ISA employs a repertoire of stand-alone, memory-mapped “operators”, each with its own pipeline and each having 16 randomly addressable result buffers that results automatically spill into on completion of that operator's execution cycle.  This combined with the SYMPL64's four interleaving threads, long latentcies for such operations as FDIV, LOG, EXP can be more easily hid, if not eliminated altogether. The operators can accept a new set of operands every clock cycle. All four threads share the same operators, but each thread has its own private set of result buffers that results automatically spill into.

Additionally, each operator result buffer has its own automatic semaphore, such that, when operands are pushed into a given operator's one-of-sixteen inputs (as seen by a given thread), the semaphore for the corresponding result buffer is automatically cleared to indicate “not-ready” and held in that state until the result is automatically written to such result buffer, at which time, the semaphore is automatically set to indicate results are available for reading.  If the instruction stream attempts to read a result buffer location corresponding to an operator push that hasn't spilled out yet, such access attempt will result in a stall for that thread's time slot each time it comes around and will continue until results are automatically written to that specific result buffer location.

When large amounts of data are being computed using longer execution cycle operators such as FDIV, LOG, EXP, etc., the foregoing stall scenario should rarely, if ever, occur. The reason is, with 16 result buffer locations, each operator can accept bursts of up to 16 operand pushes in rapid succession. By the time the 16th set of operands have been pushed, the first result has already completed long ago, especially if all four thread-units are doing the same thing. Using four threads to compute 64 floating-point divide operations simultaneously, requires just 64 clocks, not counting the clocks needed to pull results out of all 64 result buffers. By the time the 16th set of operands for each thread-unit's operator input have been pushed, 64 operand sets have been pushed and results for the first four or five pushes of each thread-unit are already available for reading. Using burst-mode computing as just described, with results being read out  in the same order they were written, a stall is impossible.

# Operators

Currently implemented operators are listed here. You should note that the following are just labels most folks are familiar with and are only used here to describe what that specific operator does. Each operator resides at a specific location or block of locations in the SYMPL64 Compute Unit memory map.  Refer to the SYMPL64 ISA instruction table in the ASM folder of this repository for the locations where each operator resides.
```
Logical:

 AND
 OR
 XOR
 BSET
 BCLR
 SHFT (seven types, including LEFT, LSL, ASL, ROL, RIGHT, LSR, ASR, ROR)
 MIN
 MAX
 ENDI (handles/changes endian-”ness” and can also be used to concatenate fragments from adjacent addresses)

Branching:

 BTBS (bit-test and branch if set)
 BTBC (bit-test and branch if clear)
 BRAL (unconditional long relative branch)
 JUMP (unconditional long absolute jump)
 DBNZ (decrement-branch-not-zero uses one of two h/w loop counters)

Integer arithmetic:

 ADD
 SUB 
 MUL (single-clock) 32x32
 DIV (place-holder, but not yet implemented)
 SIN (integer input in degrees, single-precision float result out)
 COS 
 TAN 
 COT 

 RPT N (execute and then repeat the immediately following instruction N times)

Floating-point: (presently single-precision, but half and double-precision are on the way)

 FADD
 FSUB
 FMUL
 FMA (C-Reg should be written to first before pushing operandA and operandB into FMA)
 DOT (note that in this implementation, DOT uses the same physical operator as FMA) 
 FDIV
 SQRT
 LOG
 EXP 
 PWR (place-holder for now)
 FTOI
 ITOF
 STOH (place-holder for now)
 STOD (place-holder for now)
 HTOS (place-holder for now)
 HTOD (place-holder for now)
 DTOS (place-holder for now)
 DTOH (place-holder for now)
```
------------------------------------------------------------------------------------------

# SYMPL Intermediate Language (IL) Aliases of “MOVE”

Below are just a few examples of “MOVE” aliases. Study the SYMPL64 instruction table to get the gist on how to create your own aliases.
```
FOR (LPCNT0 = uw:triangles) (        ;the text in blue is an alias for simply loading the hardware loop counter “LPCNT0” with an integer

    loop:                            ;entry point to the code comprising the loop
          .
          .
          .
          

NEXT LPCNT0 GOTO: loop )             ;the text in blue is an alias for a bit-test-and-branch-if-clear of bit16 of LPCNT0
                                     ;the LPCNT0 hardware have logic that automatically decrements when read
                                     ;bit16 of LPCNT0 is a h/w zero flag built into the counter

FOR (LPCNT1 = ) (                    ;same as above except uses h/w LPCNT1 

NEXT LPCNT1 GOTO:       )

GOTO                                 ;same as Branch Always or BRA
BRA                                  ;branch always is an alias of bit-test-and-branch-if-set of STATUS register bit31,  is always 1
NOP                                  ;NOP in an alias of bit-test-and-branch-if-set of STATUS register bit30, which is always 0

IF (Z==1) GOTO: label                ;all of these “IF” statements are aliases of bit-test-and-branch of the STATUS register
IF (Z==0) GOTO:
IF (A==B) GOTO:
IF (A!=B) GOTO:
IF (C==1) GOTO:
IF (C==0) GOTO:
IF (N==1) GOTO:
IF (N==0) GOTO:
IF (V==1) GOTO:
IF (V==0) GOTO:
IF (A<B) GOTO:
IF (A>=B) GOTO:
IF (A<=B) GOTO:
IF (A>B) GOTO:

IF (uw:some_address:[bit_number]==0) GOTO: label    ;another alias for bit-test-and-branch-if-clear, an alias for a move instruction

IF (uw:some_address:[bit_number]==1) GOTO: label    ;another alias for bit-test-and-branch-if-set,  an alias for a move instruction

REPEAT                                              ;an alias of a move to repeat counter some value
```
------------------------------------------------------------------------------------------
# Simulating this Design

This repository contains all the files you need to simulate the transformation of the “olive” shown at the center of the “before and after” .gif animation below and actually write a transformed .stl file that you can view using any .stl file viewer.  The parameters used in the simulation are listed in the animation. The transformation involves rotate, translate and scale on all three axis. The granularity of the 3D model is coarse to keep simulation time down.

![](https://github.com/jerry-D/SYMPL64_FloatingPoint_RISC-/blob/master/Doc/images/olive_trans_both.gif)

If you don't like the “olive”, there are a couple other .stl files in this repository you can transform using the same test bench. One is “ring.stl” and the other is “small_diamond.stl”.  The image below is a before and after shot of the ring using the same parameters as the “olive”. 

![](https://github.com/jerry-D/SYMPL64_FloatingPoint_RISC-/blob/master/Doc/images/Ring_b_a.jpg)

In the ASM folder is the original SYMPL IL source code used to perform this transformation. In the same folder is a “.v” hex formatted file that is loaded into the SYMPL Compute Unit's program RAM block using the Verilog $readmemh statement as shown below and which is found the “rom4kx64.v” file.  Thus you will need to make sure you place the “.v” formatted hex file in your working simulation directory so that it can be loaded into program memory. Alternatively, if you would prefer to load the “.v” hex file manually, you can use the host port, as both program and global data memory can be accessed by it.
```
$readmemh("threeD_xform.v",triportRAMA);
$readmemh("threeD_xform.v",triportRAMB);
```
The raw “olive.stl” file also needs to be placed in the same directory because the simulator test.

Finally, you need to make sure you import the test bench “sympl64_test1_tb.v” into your project, as well as all the other design files, before running a simulation. Note that the FloPoCo operators are in the FloPoCo folder because they are in VHDL.  Consequently, when you configure your project, be sure to configure it for “mixed-mode”.

The top Verilog design file is “compute_unit.v”



