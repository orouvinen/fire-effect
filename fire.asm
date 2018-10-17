CODE SEGMENT PUBLIC 'CODE'
ASSUME CS:CODE,DS:CODE,ES:CODE
.386
               A        equ 670         ; Parameter A of random number gen.
               B        equ 35954       ; Parameter B       -"-
               M        equ 32767       ; Max random num. value
     SEED_OFFSET        equ 64642       ; Offset of random number seed
                                        ; in the data segment
        VBUFSIZE        equ 64000       ; Size of double buffer (320x200)
        ORG 100H                       
BEGIN:
        ; Use the segment after code for double buffer + palette data
        MOV   AX,CS
        ADD   AH,10H
        MOV   ES,AX
        MOV   DS,AX

        ; Prepare palette buffer
        MOV   DI,VBUFSIZE+640    ; palette buffer offset
        PUSH  DI                 ; is needed later to write dac regs,
        MOV   CL,64 
        XOR   AX,AX              ; For STOSW (zero values where needed)
        XOR   BX,BX              ; RGB value

        ; write palette buffer with gradient palette
PALETTE:
        MOV   [DI],BL                  ; store R of the gradient black -> red
        INC   DI                  
        STOSW                          ; store G & B (black -> red)
        MOV   BYTE PTR [DI+189],3FH    ; store R in red -> yellow
        MOV   [DI+190],BX              ; store G & B (red -> yellow)
        MOV   WORD PTR [DI+381],3F3FH  ; store R & G in yellow -> white
        MOV   [DI+383],BL              ; store B (yellow -> white)
        INC   BX
        LOOP  PALETTE

        ; Clear double buffer and set change video mode to 320x200
        XOR   DI,DI
        MOV   CX,(VBUFSIZE/2)+320
        REP STOSW                  

        MOV   AL,13H
        INT   10H

        ; Set palette
        POP   DX
        MOV   AX,1012H
        XOR   BX,BX
        MOV   CH,1
        INT   10H

        PUSH  0A000H
        POP   ES

        ; Main loop
FIRELOOP:
        MOV   CL,15              ; number of hotspots to create
HOTSPOTS:
        PUSH  CX
        MOV   CL,2                
        MOV   AL,191             ; hotspot value
INLOOP:
        PUSH  AX

        ; Generate random number.
        ; with
        ;      x = ((a * x) + b) % M
        ;
        MOV   AX,[DS:SEED_OFFSET]
        MOV   BP,A
        MUL   BP
        ADD   AX,B
        MOV   BP,M
        DIV   BP
        MOV   [DS:SEED_OFFSET],DX
        MOV   AX,DX

        ; Write hotspots
        AND   AX,511
        ADD   AX,VBUFSIZE+320-192
        XCHG  AX,DI
        POP   AX
        MOV   [DI],AL
        MOV   [DI-320],AL
        XOR   AX,AX
        LOOP  INLOOP
        POP   CX
        LOOP  HOTSPOTS

        ; Average all the pixels in the double buffer
        MOV   CX,VBUFSIZE
        XOR   DI,DI
AVGPIXEL:
        MOV   BL,[DI]
        MOV   AL,[DI+319]
        ADD   AX,BX
        MOV   BL,[DI+321]
        ADD   AX,BX
        MOV   BL,[DI+640]
        ADD   AX,BX
        SHR   AX,2
AVGDONE:
        MOV   [DI],AL
        INC   DI
        LOOP  AVGPIXEL

        ; prepare for blasting double buffer to VGA
        XOR   SI,SI
        XOR   DI,DI
        MOV   CX,VBUFSIZE/4

        ; Wait for vertical retrace.
        ; If a retrace is already currently being done, then that'll have to do. 
        MOV   DX,3DAH
        IN    AL,DX
        AND   AL,8
        JZ    $-5

        REP MOVSD       ; write data to VGA

        ; check if there is key ready to be grabbed
        ; and return control to DOS if so
        MOV   AH,1
        INT   16H          
        JZ    FIRELOOP     
        XOR   AH,AH       
        INT   16H                     
        MOV   AX,3
        INT   10H
        INT   20H
        CODE ENDS
        END BEGIN