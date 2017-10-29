           CPU  "SYMPL64_IL.TBL"
           HOF  "MOT32"
           WDLN 8
; SYMPL GP-GPU Shader Demo 3D Transform Micro-Kernel
; version 1.05   October 19, 2017
; Author:  Jerry D. Harthcock
; Copyright (C) 2017.  All rights reserved.
           
;private dword storage
bitbucket:  EQU     0x0000                   ;this dword location is reserved.  Don't use it for anything because a lot of garbage can wind up here
work_1:     EQU     0x0008                    
work_2:     EQU     0x0010
work_3:     EQU     0x0018
capt0_save: EQU     0x0020                  ;alternate delayed exception capture register 0 save location
capt1_save: EQU     0x0028                  ;alternate delayed exception capture register 1 save location
capt2_save: EQU     0x0030                  ;alternate delayed exception capture register 2 save location
capt3_save: EQU     0x0038                  ;alternate delayed exception capture register 3 save location

;for private storage of parameters for 3D transform                                                                                       
vect_start: EQU     0x0040                  ;start location of this thread's first triangle vector                                
triangles:  EQU     0x0048                  ;number of triangles in this thread's list to process                                 

;dword storage locations for parameters so it will be easy to change to/from double precision
scaleX:     EQU     0x0050                  ;scale factor X axis
scaleY:     EQU     0x0058                  ;scale factor Y axis
scaleZ:     EQU     0x0060                  ;scale factor Z axis
transX:     EQU     0x0068                  ;translate amount X axis
transY:     EQU     0x0070                  ;translate amount Y axis
transZ:     EQU     0x0078                  ;translate amount Z axis

sin_thetaX: EQU     sin.0                   ;sine of theta X for rotate X                                                         
cos_thetaX: EQU     cos.0                   ;cosine of theta X for rotate X                                                      
sin_thetaY: EQU     sin.1                   ;sine of theta Y for rotate Y                                                        
cos_thetaY: EQU     cos.1                   ;cosine of theta Y for rotate Y                                                      
sin_thetaZ: EQU     sin.2                   ;sine of theta X for rotate Z                                                        
cos_thetaZ: EQU     cos.2                   ;cosine of theta X for rotate Z                                                      


            org     0x0FE              

Constants:  DFL     start                   ;program memory locations 0x000 - 0x0FF reserved for look-up table
        
prog_len:   DFL     progend - Constants
              
;           type    dest = OP:(type:srcA, type:srcB) 

            org     0x00000100                               ;default interrupt vector locations
load_vects: 
            uh      NMI_VECT = uh:#NMI_                      ;load of interrupt vectors for faster interrupt response
            uh      IRQ_VECT = uh:#IRQ_                      ;these registers are presently not visible to app s/w
            uh      INV_VECT = uh:#INV_
            uh      DIVx0_VECT = uh:#DIVx0_
            uh      OVFL_VECT = uh:#OVFL_
            uh      UNFL_VECT = uh:#UNFL_
            uh      INEXT_VECT = uh:#INEXT_
done:                   
            uw      set.0 = set:(uw:STATUS, ub:#DONE_bit)    ;signal external CPU/host (load-balancer/coarse-grain scheduler) process is done
            uw      STATUS = uw:set.0                        ;note that the DONE_BIT is already set upon initial entry but is cleared at "start"
                                                             ;to signal host thread has started (ie, not done)                
any_triangles?:
            uw      or.1 = or:(uw:triangles, uw:#0x0)        ;see if there are any triangles to transform
            uw      work_1 = uw:or.1                         ;result has to be read out before the Z flag can be tested
                    IF (Z==1) GOTO: any_triangles?
                    
            uw      TIMER = uw:#0x60000                      ;load time-out timer with sufficient time to process before timeout
            uw      AR3 = uw:vect_start 
start:  
            uw      bclr.0 = bclr:(uw:STATUS, uw:#DONE_bit)  ;clear the DONE bit to signal we are now busy
            uw      STATUS = uw:bclr.0

            fs      sin_thetaX = sin:(uw:@rotx)       ;calculate sine of theta X and save
            fs      cos_thetaX = cos:(uw:@rotx)       ;calculate cosine of theta X and save                               
            fs      sin_thetaY = sin:(uw:@roty)       ;calculate sine of theta Y and save                                   
            fs      cos_thetaY = cos:(uw:@roty)       ;calculate cosine of theta Y and save                                   
            fs      sin_thetaZ = sin:(uw:@rotz)       ;calculate sine of theta Z and save                                   
            fs      cos_thetaZ = cos:(uw:@rotz)       ;calculate cosine of theta Z and save                                   
                                                                                                                            
            fs      scaleX = fs:@scal_x               ;save scale X factor
            fs      scaleY = fs:@scal_y               ;save scale Y factor
            fs      scaleZ = fs:@scal_z               ;save scale Z factor
            fs      transX = fs:@trans_x              ;save translate X axis amount
            fs      transY = fs:@trans_y              ;save translate Y axis amount
            fs      transZ = fs:@trans_z              ;save translate Z axis amount

                  ; AR3 is now pointing to first X of first triangle
            uw      AR2 = uw:AR3                       ;copy AR3 contents to AR2 so AR2 can be used as write pointer back to PDB for saving results
            
                    for (LPCNT0 = uw:triangles) (      ;load loop counter 0 with number of triangles 
            
                    ;the following routine performs scaling on all three axis first, 
                    ;rotate on all three axis second, then translate on all three axis last 
                              
loop:   ;scale on X, Y, Z axis
            ;vertex 1
            fs        FMUL.0 = fmul:(fs:*AR3++[4], fs:scaleX)
            fs        FMUL.1 = fmul:(fs:*AR3++[4], fs:scaleY)
            fs        FMUL.2 = fmul:(fs:*AR3++[4], fs:scaleZ)
            ;vertex 2
            fs        FMUL.3 = fmul:(fs:*AR3++[4], fs:scaleX)
            fs        FMUL.4 = fmul:(fs:*AR3++[4], fs:scaleY)
            fs        FMUL.5 = fmul:(fs:*AR3++[4], fs:scaleZ)
            ;vertex 3
            fs        FMUL.6 = fmul:(fs:*AR3++[4], fs:scaleX)
            fs        FMUL.7 = fmul:(fs:*AR3++[4], fs:scaleY)
            fs        FMUL.8 = fmul:(fs:*AR3++[4], fs:scaleZ)
            
;                     X1 is now in FMUL_0         
;                     Y1 is now in FMUL_1         
;                     Z1 is now in FMUL_2         
;                     X2 is now in FMUL_3         
;                     Y2 is now in FMUL_4         
;                     Z2 is now in FMUL_5         
;                     X3 is now in FMUL_6         
;                     Y3 is now in FMUL_7         
;                     Z3 is now in FMUL_8         
            
  ;rotate around X axis
       ;vertex 1
            ; (cos(xrot) * Y1) - (sin(xrot) * Z1) 
            fs        FMUL.9 = fmul:(fs:FMUL.1, fs:cos_thetaX)      ; FMUL.9 = (cos(xrot) * Y1)
            fs        FMUL.10 = fmul:(fs:FMUL.2, fs:sin_thetaX)     ; FMUL.10 = (sin(xrot) * Z1)
            ; (sin(xrot) * Y1) + (cos(xrot) * Z1) 
            fs        FMUL.11 = fmul:(fs:FMUL.1, fs:sin_thetaX)     ; FMUL.11 = (sin(xrot) * Y1)
            fs        FMUL.12 = fmul:(fs:FMUL.2, fs:cos_thetaX)     ; FMUL.12 = (cos(xrot) * Z1)
            
            fs        FSUB.0 = fsub:(fs:FMUL.9, fs:FMUL.10)         ; FSUB.0 = (cos(xrot) * Y1) - (sin(xrot) * Z1)
            fs        FADD.0 = fadd:(fs:FMUL.11, fs:FMUL.12)        ; FADD.0 = (sin(xrot) * Y1) + (cos(xrot) * Z1)

       ;vertex 2
            ; (cos(xrot) * Y2) - (sin(xrot) * Z2) 
            fs        FMUL.1 = fmul:(fs:FMUL.4, fs:cos_thetaX)      ; FMUL.1 = (cos(xrot) * Y2)
            fs        FMUL.2 = fmul:(fs:FMUL.5, fs:sin_thetaX)      ; FMUL.2 = (sin(xrot) * Z2)
            ; (sin(xrot) * Y2) + (cos(xrot) * Z2) 
            fs        FMUL.13 = fmul:(fs:FMUL.4, fs:sin_thetaX)     ; FMUL.13 = (sin(xrot) * Y2)
            fs        FMUL.14 = fmul:(fs:FMUL.5, fs:cos_thetaX)     ; FMUL.14 = (cos(xrot) * Z2)
            
            fs        FSUB.1 = fsub:(fs:FMUL.1, fs:FMUL.2)          ; FSUB.1 = (cos(xrot) * Y2) - (sin(xrot) * Z2)
            fs        FADD.1 = fadd:(fs:FMUL.13, fs:FMUL.14)        ; FADD.1 = (sin(xrot) * Y2) + (cos(xrot) * Z2)

       ;vertex 3
            ; (cos(xrot) * Y3) - (sin(xrot) * Z3) 
            fs        FMUL.9 = fmul:(fs:FMUL.7, fs:cos_thetaX)      ; FMUL.9 = (cos(xrot) * Y3)
            fs        FMUL.10 = fmul:(fs:FMUL.8, fs:sin_thetaX)     ; FMUL.10 = (sin(xrot) * Z3)
            ; (sin(xrot) * Y3) + (cos(xrot) * Z3) 
            fs        FMUL.11 = fmul:(fs:FMUL.7, fs:sin_thetaX)     ; FMUL.11 = (sin(xrot) * Y3)
            fs        FMUL.12 = fmul:(fs:FMUL.8, fs:cos_thetaX)     ; FMUL.12 = (cos(xrot) * Z3)
            
            fs        FSUB.2 = fsub:(fs:FMUL.9, fs:FMUL.10)         ; FSUB.2 = (cos(xrot) * Y3) - (sin(xrot) * Z3)
            fs        FADD.2 = fadd:(fs:FMUL.11, fs:FMUL.12)        ; FADD.2 = (sin(xrot) * Y3) + (cos(xrot) * Z3)            
            
            ;         X1 is now in FMUL_0
            ;         Y1 is now in FSUB_0
            ;         Z1 is now in FADD_0 
            ;         X2 is now in FMUL_3
            ;         Y2 is now in FSUB_1
            ;         Z2 is now in FADD_1
            ;         X3 is now in FMUL_6
            ;         Y3 is now in FSUB_2
            ;         Z3 is now in FADD_2      

  ;rotate around Y axis
       ;vertex 1
            ; (cos(yrot) * X1) + (sin(yrot) * Z1) 
            fs        FMUL.1 = fmul:(fs:FMUL.0, fs:cos_thetaY)      ; FMUL.1 = (cos(yrot) * X1)
            fs        FMUL.2 = fmul:(fs:FADD.0, fs:sin_thetaY)      ; FMUL.2 = (sin(yrot) * Z1)
            ; (cos(yrot) * Z1) - (sin(yrot) * X1)
            fs        FMUL.4 = fmul:(fs:FADD.0, fs:cos_thetaY)      ; FMUL.4 = (cos(xrot) * Z1)
            fs        FMUL.5 = fmul:(fs:FMUL.0, fs:sin_thetaY)      ; FMUL.5 = (sin(xrot) * X1)
            
            fs        FADD.3 = fadd:(fs:FMUL.1, fs:FMUL.2)          ; FADD.3 = (cos(yrot) * X1) + (sin(yrot) * Z1)
            fs        FSUB.3 = fsub:(fs:FMUL.4, fs:FMUL.5)          ; FSUB.3 = (cos(yrot) * Z1) - (sin(yrot) * X1)
       ;vertex 2
            ; (cos(yrot) * X2) + (sin(yrot) * Z2) 
            fs        FMUL.7 = fmul:(fs:FMUL.3, fs:cos_thetaY)      ; FMUL.7 = (cos(yrot) * X2)
            fs        FMUL.8 = fmul:(fs:FADD.1, fs:sin_thetaY)      ; FMUL.8 = (sin(yrot) * Z2)
            ; (cos(yrot) * Z2) - (sin(yrot) * X2)
            fs        FMUL.9 = fmul:(fs:FADD.1, fs:cos_thetaY)      ; FMUL.9 = (cos(xrot) * Z2)
            fs        FMUL.10 = fmul:(fs:FMUL.3, fs:sin_thetaY)     ; FMUL.10 = (sin(xrot) * X2)
            
            fs        FADD.4 = fadd:(fs:FMUL.7, fs:FMUL.8)          ; FADD.4 = (cos(yrot) * X2) + (sin(yrot) * Z2)
            fs        FSUB.4 = fmul:(fs:FMUL.9, fs:FMUL.10)         ; FSUB.4 = (cos(yrot) * Z2) - (sin(yrot) * X2)
            
       ;vertex 3
            ; (cos(yrot) * X3) + (sin(yrot) * Z3) 
            fs        FMUL.11 = fmul:(fs:FMUL.6, fs:cos_thetaY)     ; FMUL.11 = (cos(yrot) * X3)
            fs        FMUL.12 = fmul:(fs:FADD.2, fs:sin_thetaY)     ; FMUL.12 = (sin(yrot) * Z3)
            
            ; (cos(yrot) * Z3) - (sin(yrot) * X3)
            fs        FMUL.13 = fmul:(fs:FADD.2, fs:cos_thetaY)     ; FMUL.13 = (cos(xrot) * Z3)
            fs        FMUL.14 = fmul:(fs:FMUL.6, fs:sin_thetaY)     ; FMUL.14 = (sin(xrot) * X3)
            
            fs        FADD.5 = fadd:(fs:FMUL.11, fs:FMUL.12)        ; FADD.5 = (cos(yrot) * X3) + (sin(yrot) * Z3)
            fs        FSUB.5 = fsub:(fs:FMUL.13, fs:FMUL.14)        ; FSUB.5 = (cos(yrot) * Z3) - (sin(yrot) * X3)  
            
            ;         X1 is now in FADD_3
            ;         Y1 is now in FSUB_0
            ;         Z1 is now in FSUB_3
            ;         X2 is now in FADD_4
            ;         Y2 is now in FSUB_1
            ;         Z2 is now in FSUB_4
            ;         X3 is now in FADD_5
            ;         Y3 is now in FSUB_2 
            ;         Z3 is now in FSUB_5                      

  ;rotate around Z axis
       ;vertex 1
            ; (cos(zrot) * X1) - (sin(zrot) * Y1) 
            fs        FMUL.0 = fmul:(fs:FADD.3, fs:cos_thetaZ)      ; FMUL.0 = (cos(zrot) * X1)
            fs        FMUL.1 = fmul:(fs:FSUB.0, fs:sin_thetaZ)      ; FMUL.1 = (sin(xrot) * Y1)
            ; (sin(zrot) * X1) + (cos(zrot) * Y1) 
            fs        FMUL.2 = fmul:(fs:FADD.3, fs:sin_thetaZ)      ; FMUL.2 = (sin(xrot) * X1)
            fs        FMUL.3 = fmul:(fs:FSUB.0, fs:cos_thetaZ)      ; FMUL.3 = (cos(xrot) * Y1)
            
            fs        FSUB.6 = fsub:(fs:FMUL.0, fs:FMUL.1)          ; FSUB.6 = (cos(zrot) * X1) - (sin(zrot) * Y1)
            fs        FADD.6 = fadd:(fs:FMUL.2, fs:FMUL.3)          ; FADD.6 = (sin(zrot) * X1) + (cos(zrot) * Y1)

       ;vertex 2
            ; (cos(zrot) * X2) - (sin(zrot) * Y2) 
            fs        FMUL.4 = fmul:(fs:FADD.4, fs:cos_thetaZ)      ; FMUL.4 = (cos(zrot) * X1)
            fs        FMUL.5 = fmul:(fs:FSUB.1, fs:sin_thetaZ)      ; FMUL.5 = (sin(xrot) * Y1)
            ; (sin(zrot) * X2) + (cos(zrot) * Y2) 
            fs        FMUL.6 = fmul:(fs:FADD.4, fs:sin_thetaZ)      ; FMUL.6 = (sin(xrot) * X2)
            fs        FMUL.7 = fmul:(fs:FSUB.1, fs:cos_thetaZ)      ; FMUL.7 = (cos(xrot) * Y2)
            
            fs        FSUB.7 = fsub:(fs:FMUL.4, fs:FMUL.5)          ; FSUB.7 = (cos(zrot) * X2) - (sin(zrot) * Y2)
            fs        FADD.7 = fadd:(fs:FMUL.6, fs:FMUL.7)          ; FADD.7 = (sin(zrot) * X2) + (cos(zrot) * Y2)

       ;vertex 3
            ; (cos(zrot) * X3) - (sin(zrot) * Y3) 
            fs        FMUL.8 = fmul:(fs:FADD.5, fs:cos_thetaZ)      ; FMUL.8 = (cos(zrot) * X3)
            fs        FMUL.9 = fmul:(fs:FSUB.2, fs:sin_thetaZ)      ; FMUL.9 = (sin(xrot) * Y3)
            ; (sin(zrot) * X3) + (cos(zrot) * Y3)   
            fs        FMUL.10 = fmul:(fs:FADD.5, fs:sin_thetaZ)     ; FMUL.10 = (sin(xrot) * X3)
            fs        FMUL.11 = fmul:(fs:FSUB.2, fs:cos_thetaZ)     ; FMUL.11 = (cos(xrot) * Y3)
            
            fs        FSUB.8 = fsub:(fs:FMUL.8, fs:FMUL.9)          ; FSUB.8 = (cos(zrot) * X3) - (sin(zrot) * Y3)
            fs        FADD.8 = fadd:(fs:FMUL.10, fs:FMUL.11)        ; FADD.8 = (sin(zrot) * X3) + (cos(zrot) * Y3)            
            
            ;         X1 is now in FSUB.6
            ;         Y1 is now in FADD.6
            ;         Z1 is now in FSUB.3
            ;         X2 is now in FSUB.7
            ;         Y2 is now in FADD.7
            ;         Z2 is now in FSUB.4
            ;         X3 is now in FSUB.8
            ;         Y3 is now in FADD.8
            ;         Z3 is now in FSUB.5
       
    ;now translate on X, Y = Z axis
        ;vertex 1
            fs        FADD.0 = fadd:(fs:FSUB.6, fs:transX)     
            fs        FADD.1 = fadd:(fs:FADD.6, fs:transY)     
            fs        FADD.2 = fadd:(fs:FSUB.3, fs:transZ)     
        ;vertex 2
            fs        FADD.9 = fadd:(fs:FSUB.7, fs:transX)     
            fs        FADD.10 = fadd:(fs:FADD.7, fs:transY)     
            fs        FADD.11 = fadd:(fs:FSUB.4, fs:transZ)     
        ;vertex 3
            fs        FADD.12 = fadd:(fs:FSUB.8, fs:transX)     
            fs        FADD.13 = fadd:(fs:FADD.8, fs:transY)     
            fs        FADD.14 = fadd:(fs:FSUB.5, fs:transZ)     

            fs        *AR2++[4] = fs:FADD.0        ;copy transformed X1 to PDB
            fs        *AR2++[4] = fs:FADD.1        ;copy transformed Y1 to PDB
            fs        *AR2++[4] = fs:FADD.2        ;copy transformed Z1 to PDB
            fs        *AR2++[4] = fs:FADD.9        ;copy transformed X2 to PDB
            fs        *AR2++[4] = fs:FADD.10       ;copy transformed Y2 to PDB
            fs        *AR2++[4] = fs:FADD.11       ;copy transformed Z2 to PDB
            fs        *AR2++[4] = fs:FADD.12       ;copy transformed X3 to PDB
            fs        *AR2++[4] = fs:FADD.13       ;copy transformed Y3 to PDB
            fs        *AR2++[4] = fs:FADD.14       ;copy transformed Z3 to PDB

                    NEXT LPCNT0 GOTO: loop)        ;continue until done
            uw      triangles = uw:#0              ;clear triangles so it doesn't fall through again

                    GOTO done                      ;jump to done, semphr test and spin for next packet
            
; interrupt service routines        
NMI_:       uw      *SP--[8] = uw:PC_COPY          ;save return address from non-maskable interrupt (time-out timer in this instance)
            uw      TIMER = uw:#60000              ;put a new value in the timer
            uw      PC = uw:*SP++[8]               ;return from interrupt
        
INV_:       uw      *SP--[8] = uw:PC_COPY          ;save return address from floating-point invalid operation exception, which is maskable
            uw      TIMER = uw:#60000              ;put a new value in the timer
            fs      work_3 = fs:SQRT.1             ;retrieve the NaN with payload (this quiet NaN replaced the signaling NaN that caused the INV exc)
            uw      PC = uw:*SP++[1]               ;return from interrupt
            
DIVx0_:     uw      *SP--[8] = uw:PC_COPY          ;save return address from floating-point divide by 0 exception, which is maskable
            uw      capt0_save = uw:CAPTURE0       ;read out CAPTURE0 register and save it
            uw      capt1_save = uw:CAPTURE1       ;read out CAPTURE1 register and save it
            uw      capt2_save = uw:CAPTURE2       ;read out CAPTURE2 register and save it
            uw      capt3_save = uw:CAPTURE3       ;read out CAPTURE3 register and save it
            uw      TIMER = uw:#60000              ;put a new value in the timer
            uw      PC = uw:*SP++[8]               ;return from interrupt

OVFL_:      uw      *SP--[8] = uw:PC_COPY          ;save return address from floating-point overflow exception, which is maskable
            uw      TIMER = uw:#60000              ;put a new value in the timer
            uw      PC = uw:*SP++[8]               ;return from interrupt

UNFL_:      uw      *SP--[8] = uw:PC_COPY          ;save return address from floating-point underflow exception, which is maskable
            uw      TIMER = uw:#10000              ;put a new value in the timer
            uw      PC = uw:*SP++[8]               ;return from interrupt

INEXT_:     uw      *SP--[8] = uw:PC_COPY          ;save return address from floating-point inexact exception, which is maskable
            uw      TIMER = uw:#60000              ;put a new value in the timer
            uw      PC = uw:*SP++[8]               ;return from interrupt

IRQ_:       uw      *SP--[8] = uw:PC_COPY          ;save return address (general-purpose, maskable interrupt)
            uw      TIMER = uw:#60000              ;put a new value in the timer
            uw      PC = uw:*SP++[8]               ;return from interrupt 
                       
;parameters for this particular 3D transform test run
rotx:       dfl     0, 29                          ;rotate around x axis in integer degrees  
roty:       dfl     0, 44                          ;rotate around y axis in integer degrees  
rotz:       dfl     0, 75                          ;rotate around z axis in integer degrees  
scal_x:     dff     0, 2.0                         ;scale X axis amount real
scal_y:     dff     0, 2.0                         ;scale y axis amount real
scal_z:     dff     0, 2.25                        ;scale Z axis amount real
trans_x:    dff     0, 4.75                        ;translate on X axis amount real
trans_y:    dff     0, 3.87                        ;translate on Y axis amount real
trans_z:    dff     0, 2.237                       ;translate on Z axis amount real

;rotx:       dfl     0, 0                          ;rotate around x axis in integer degrees  
;roty:       dfl     0, 0                          ;rotate around y axis in integer degrees  
;rotz:       dfl     0, 0                          ;rotate around z axis in integer degrees  
;scal_x:     dff     0, 1                          ;scale X axis amount real
;scal_y:     dff     0, 1                          ;scale y axis amount real
;scal_z:     dff     0, 1                          ;scale Z axis amount real
;trans_x:    dff     0, 0                          ;translate on X axis amount real
;trans_y:    dff     0, 0                          ;translate on Y axis amount real
;trans_z:    dff     0, 0                          ;translate on Z axis amount real


progend:        
            end
          
    
