.Model Small
.Stack 64
.Data



blockWidth EQU 16
blockHeight EQU 16


blockFilename DB 'bomer.img', 0

blockFilehandle DW ?

blockData DB blockWidth*blockHeight dup(2)

.Code
MAIN PROC FAR
    MOV AX , @DATA
    MOV DS , AX
    
    MOV AH, 0
    MOV AL, 13h
    INT 10h
	
    CALL OpenFile
    CALL ReadData
    CALL CloseFile

	
	MOV AH,0ch
	MOV CX , 0
	MOV DX , 0

	
	LEA BX , blockData ; BL contains index at the current drawn pixel
	
    MOV CX,0 ; x1
    MOV DX,0 ; y1
    MOV AH,0ch
	
	
; Drawing loop
drawLoop:

    MOV AL,[BX]
    INT 10h 
    INC CX
    INC BX
    CMP CX,16 
JNE drawLoop 
	
    MOV CX , 0
    INC DX
    CMP DX , 16
JNE drawLoop



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