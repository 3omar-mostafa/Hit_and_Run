.Model Small
.Stack 64
.Data

blockWidth EQU 16
blockHeight EQU 16

screenWidth EQU 320
screenHeight EQU 200

arenaHeight EQU 144
arenaWidth EQU 320

backgroundColor EQU 02h

blockFilename DB 'block', 0

blockFilehandle DW ?

blockData DB blockWidth*blockHeight dup(0)

.Code
MAIN PROC FAR
    MOV AX , @DATA
    MOV DS , AX
    
    MOV AH, 0
    MOV AL, 13h
    INT 10h
	
    CALL OpenFile
    CALL ReadData
	
	
	
	
	
	
	MOV AH,0ch
	MOV CX , 0
	MOV DX , 0

drawLoop4:
    MOV AL,backgroundColor
    INT 10h 
    INC CX
    CMP CX,arenaWidth
JNE drawLoop4
	
    MOV CX , 0
    INC DX
    CMP DX , arenaHeight
JNE drawLoop4

	
	
	
;    LEA BX , blockData ; BL contains index at the current drawn pixel
;	
;    MOV CX,0
;    MOV DX,blockHeight
;	MOV DI,blockWidth
;	MOV SI, 0
;    MOV AH,0ch
;	
;	
;; Drawing loop
;drawLoop:
;    MOV AL,[BX]
;    INT 10h 
;    INC CX
;    INC BX
;    CMP CX,DI
;JNE drawLoop 
;	
;    MOV CX , SI
;    INC DX
;    CMP DX , 2*blockHeight
;JNE drawLoop
;
;ADD SI , blockWidth
;ADD DI , blockWidth
;lea bx , blockData
;mov dx , blockHeight
;cmp cx , screenWidth
;jne drawLoop
;
;
;    LEA BX , blockData ; BL contains index at the current drawn pixel
;	
;    MOV CX,0
;    MOV DX,arenaHeight - blockHeight
;	MOV DI,blockWidth
;	MOV SI, 0
;    MOV AH,0ch
;	
;; Drawing loop
;drawLoop1:
;    MOV AL,[BX]
;    INT 10h 
;    INC CX
;    INC BX
;    CMP CX,DI
;JNE drawLoop1 
;	
;    MOV CX , SI
;    INC DX
;    CMP DX , arenaHeight
;JNE drawLoop1
;
;ADD SI , blockWidth
;ADD DI , blockWidth
;lea bx , blockData
;mov dx , arenaHeight - blockHeight
;cmp cx , screenWidth
;jne drawLoop1
;
;
;
;
;
;    LEA BX , blockData ; BL contains index at the current drawn pixel
;    MOV CX,0
;    MOV DX,blockHeight
;	MOV DI,2*blockHeight
;    MOV AH,0ch
;
;; Drawing loop
;drawLoop2:
;    MOV AL,[BX]
;    INT 10h 
;    INC CX
;    INC BX
;    CMP CX,blockWidth
;JNE drawLoop2
;    MOV CX , 0
;    INC DX
;    CMP DX , DI
;JNE drawLoop2
;ADD DI , blockHeight
;lea bx , blockData
;cmp DX , arenaHeight-blockHeight
;JNE drawLoop2
;
;
;
;
;
;    LEA BX , blockData ; BL contains index at the current drawn pixel
;    MOV CX,arenaWidth-blockWidth
;    MOV DX,blockHeight
;	MOV DI,2*blockHeight
;    MOV AH,0ch
;
;; Drawing loop
;drawLoop3:
;    MOV AL,[BX]
;    INT 10h 
;    INC CX
;    INC BX
;    CMP CX,arenaWidth
;JNE drawLoop3
;    MOV CX , arenaWidth-blockWidth
;    INC DX
;    CMP DX , DI
;JNE drawLoop3
;ADD DI , blockHeight
;lea bx , blockData
;cmp DX , arenaHeight-blockHeight
;JNE drawLoop3









    ; Press any key to exit
    MOV AH , 0
    INT 16h
    
    call CloseFile
    
    ;Change to Text MODE
    MOV AH,0          
    MOV AL,03h
    INT 10h 

    ; return control to operating system
    MOV AH , 4ch
    INT 21H
    
MAIN ENDP




OpenFile PROC 

    ; Open file

    MOV AH, 3Dh
    MOV AL, 0 ; read only
    LEA DX, blockFilename
    INT 21h
    
    ; you should check carry flag to make sure it worked correctly
    ; carry = 0 -> successful , file handle -> AX
    ; carry = 1 -> failed , AX -> error code
     
    MOV [blockFilehandle], AX
    
    RET

OpenFile ENDP

ReadData PROC

    MOV AH,3Fh
    MOV BX, [blockFilehandle]
    MOV CX,blockWidth*blockHeight ; number of bytes to read
    LEA DX, blockData
    INT 21h
    RET
ReadData ENDP 


CloseFile PROC
	MOV AH, 3Eh
	MOV BX, [blockFilehandle]

	INT 21h
	RET
CloseFile ENDP

END MAIN