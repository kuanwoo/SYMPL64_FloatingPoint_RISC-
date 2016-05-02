# SYMPL64_FloatingPoint_RISC-
(May 2, 2016) SYMPL64 is in development.  It is a 64-bit, IEEE754-2008-compliant RISC featuring double, single, and half precision floating-point operators.  All operators are memory-mapped and include directed rounding, alternate and alternate delayed exception handling, per the IEEE754-2008 spec.  For invalid exceptions, non-signaling NANs with diagnostic payloads are substituted and delivered.

The following FP operators are included in double, single, and half precision: FADD, FSUB, FMA, DOT, FMUL, FDIV, SQRT, LOG, EXP, PWR, ITOF, FTOI, DTOS, STOD, DTOH, HTOD, STOH, HTOS, SIN, COS, ATAN.  

The example RTL will include JTAG debug interface.
