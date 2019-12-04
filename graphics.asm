.Model COMPACT
.Stack 64
.Data
include inout.inc


gridWidth EQU 320
gridHeight EQU 144

gridFilename DB 'grid.img', 0
gridFilehandle DW ?
gridData DB gridWidth*gridHeight dup(2)

bomerWidth EQU 16
bomerHeight EQU 16

bomerFilename DB 'bomer.img', 0
bomerFilehandle DW ?
bomerData DB bomerWidth*bomerHeight dup(2)

bomerx EQU 16
bomerY EQU 16


.Code
MAIN PROC FAR
    MOV AX , @DATA
    MOV DS , AX
    
    MOV AH, 0
    MOV AL, 13h
    INT 10h
	
    callOpenFile gridFilename,gridFilehandle
	callLoadData gridFilehandle,gridData,gridWidth,gridHeight
	callCloseFile gridFilehandle
	
	MOV AH,0ch
	MOV CX , 0
	MOV DX , 0

	
	LEA BX , gridData ; BL contains index at the current drawn pixel
	
    MOV CX,0 ; x1
    MOV DX,0 ; y1
    MOV AH,0ch
	
	
; Drawing loop
drawLoop:

    MOV AL,[BX]
    INT 10h 
    INC CX
    INC BX
    CMP CX,320 
JNE drawLoop 
	
    MOV CX , 0
    INC DX
    CMP DX , 144
JNE drawLoop


;;;;;;;;;;;;;;;;;;;;;;draw pomerman;;;;;;;;;;;;;;;;;;;;;;;;
    callOpenFile bomerFilename,bomerFilehandle
	callLoadData bomerFilehandle,bomerData,bomerWidth,bomerHeight
	callCloseFile bomerFilehandle

	

	
	LEA BX , bomerData ; BL contains index at the current drawn pixel
	
    MOV CX,bomerx ; x1
    MOV DX,bomery ; y1
    MOV AH,0ch
	
	
; Drawing loop
drawLoop1:

    MOV AL,[BX]
    INT 10h 
    INC CX
    INC BX
    CMP CX,16+bomerx 
JNE drawLoop1 
	
    MOV CX , bomerx
    INC DX
    CMP DX , 16+bomerx
JNE drawLoop1




    ; Press any key to exit
    MOV AH , 0
    INT 16h
    

    
    ;Change to Text MODE
    MOV AH,0          
    MOV AL,03h
    INT 10h 

    ; return control to operating system
    MOV AH , 4ch
    INT 21H
    
MAIN ENDP

;OpenFile PROC 
;
;    ; Open file
;
;    MOV AH, 3Dh
;    MOV AL, 0 ; read only
;    LEA DX, gridFilename
;    INT 21h
;    
;    ; you should check carry flag to make sure it worked correctly
;    ; carry = 0 -> successful , file handle -> AX
;    ; carry = 1 -> failed , AX -> error code
;     
;    MOV [gridFilehandle], AX
;    
;    RET
;
;OpenFile ENDP
;
;ReadData PROC
;




END MAIN