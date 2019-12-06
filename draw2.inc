blockWidth EQU 16
blockHeight EQU 16

drawRow MACRO x1 , y1 , x2 ,  blockData
local drawLoop

    LEA BX , blockData ; BL contains index at the current drawn pixel
	
    MOV CX,x1 ; x1
    MOV DX,y1 ; y1
	MOV DI,x1+blockWidth ; x1 + width
	MOV SI, x1 ; x1
    MOV AH,0ch
	
	
; Drawing loop
drawLoop:

    MOV AL,[BX]
    INT 10h 
    INC CX
    INC BX
    CMP CX,DI 
JNE drawLoop 
	
    MOV CX , SI
    INC DX
    CMP DX , y1+blockHeight
JNE drawLoop

ADD SI , 2*blockWidth
ADD DI , 2*blockWidth
lea bx , blockData
MOV CX , SI
mov dx , y1
cmp cx , x2
jbe drawLoop



ENDM drawRow