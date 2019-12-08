; This file contains MACROs fo preparing parameters and call the real PROCs in inout.asm
; These MACROs should be called insted of the PROCs in inout.asm

; THese procedures are external
; MUST be declared at another assembly file with same name,type
; so that the linker join them

EXTRN setCursorPosition:NEAR
EXTRN getCursorPosition:NEAR
EXTRN waitForAnyKey:NEAR
EXTRN displayString:NEAR
EXTRN switchToTextMode:NEAR
EXTRN switchToGraphicsMode:NEAR
EXTRN openFile:NEAR
EXTRN loadData:NEAR
EXTRN closeFile:NEAR
EXTRN spaceforprinting:BYTE

writescore2 macro score
           pusha
		   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;NN
		   MOV DH,00
		   MOV DL,01
		   MOV BH,0
		   MOV AH,2
		   INT 10H
		
		
		
		
		   MOV AH ,9
		   MOV DX, OFFSET INDATAP1
		   ADD DX,2
		   INT 21H
		   
		   
		   
		   
		   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;NN
           ;;;set cursor;;;
           MOV DH , 00
           MOV DL , 0DH
           MOV BH , 0
           MOV AH , 2
           INT 10h
           ;;;;;;;;;;;;;
           mov ah , 2
           mov dl , ':'
           int 21h
           ;;;;;;;;;;;;nn
		   MOV DH , 00
           MOV DL , 0EH
           MOV BH , 0
           MOV AH , 2
           INT 10h
		   mov ah , 9
		   mov dl , offset spaceforprinting
		   int 21h
		   MOV DH , 00
           MOV DL , 0EH
           MOV BH , 0
           MOV AH , 2
           INT 10h
		   ;;;;;;;;;;;;nn
		   mov ax , score
           printnum ax
           popa
ENDM       writescore2

writescore1 macro score
           pusha
		    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;NN
		   MOV DH,00
		   MOV DL,15
		   MOV BH,0
		   MOV AH,2
		   INT 10H
		   MOV AH ,9
		   MOV DX, OFFSET INDATAP2
		   ADD DX,2
		   INT 21H
		   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;NN
           ;;;set cursor;;;
           MOV DH , 00
           MOV DL , 1BH
           MOV BH , 0
           MOV AH , 2
           INT 10h
           ;;;;;;;;;;;;;
           mov ah , 2
           mov dl , ':'
           int 21h
           ;;;;;;;;;;;nn
		   MOV DH , 00
           MOV DL , 1CH
           MOV BH , 0
           MOV AH , 2
           INT 10h
		   mov ah , 9
		   mov dl , offset spaceforprinting
		   int 21h
		   MOV DH , 00
           MOV DL , 1CH
           MOV BH , 0
           MOV AH , 2
           INT 10h
		   ;;;;;;;;;;;;nn
		   mov ax , score
           printnum ax
           popa
ENDM       writescore1


writeheart2 macro heart
           pusha
           ;;;set cursor;;;
           MOV DH , 00
           MOV DL , 13h
           MOV BH , 0
           MOV AH , 2
           INT 10h
           ;;;;;;;;;;;;;
           mov ah , 2
           mov dl , ':'
           int 21h
           ;;;;;;;;;;;;
		   mov ax , heart
           printnum ax
           popa
ENDM       writeheart2

writeheart1 macro heart
           pusha
           ;;;set cursor;;;
           MOV DH , 00
           MOV DL , 26h
           MOV BH , 0
           MOV AH , 2
           INT 10h
           ;;;;;;;;;;;;;
           mov ah , 2
           mov dl , ':'
           int 21h
           ;;;;;;;;;;;;
		   mov ax , heart
           printnum ax
           popa
ENDM       writeheart1

GetCurrentTime macro time
            pusha
			
            mov ah , 2ch
            int 21h
			mov time , dh
			
			popa
            
endm GetCurrentTime 



callSetCursorPosition MACRO x , y
	PUSH DX
	PUSH AX

	MOV DL , x
	MOV DH , y
	
	CALL setCursorPosition
	
	POP AX
	POP DX
ENDM callSetCursorPosition



; @Returns x -> DL
; @Returns y -> DH
callGetCursorPosition MACRO
	PUSH BX
	PUSH AX
	
	CALL getCursorPosition
	
	POP AX
	POP BX
ENDM callGetCursorPosition



; @Returns Pressed key  scancode -> AH
; @Returns Pressed key ASCIIcode -> AL
callWaitForAnyKey MACRO
	CALL waitForAnyKey
ENDM callWaitForAnyKey

;@string must be a memory location terminated with '$'
callDisplayString MACRO string
	
	PUSH AX
	PUSH DX
	
	LEA DX , string 
	
	CALL displayString

	POP DX
	POP AX
ENDM callDisplayString



callSwitchToTextMode MACRO
	PUSH AX
	
	CALL switchToTextMode
	
	POP AX
ENDM callSwitchToTextMode



callSwitchToGraphicsMode MACRO
	PUSH AX
	
	CALL switchToGraphicsMode
	
	POP AX
ENDM callSwitchToGraphicsMode


; open file from the device with filename
; @ returns the output pointer to this file in fieHandle
callOpenFile MACRO filenamea , fileHandlea
	; Open file

    MOV AH, 3Dh
    MOV AL, 0 ; read only
    LEA DX, Filenamea
    INT 21h
    
    ; you should check carry flag to make sure it worked correctly
    ; carry = 0 -> successful , file handle -> AX
    ; carry = 1 -> failed , AX -> error code
     
    MOV [Filehandlea], AX
    

ENDM callOpenFile



; Loads data from image with its filehandle and save them in imageData
; dimensions of the image is _width , _height
; imageData is assumed an array with available space to store the data 
callLoadData MACRO filehandleb , imageData , _width , _height
	MOV AH,3Fh
    MOV BX, [Filehandleb]
    MOV CX,_width*_height ; number of bytes to read
    LEA DX, imageData
    INT 21h

ENDM callLoadData 


; Closes the opened file with its coresponding fieHandle
callCloseFile MACRO filehandle 
	MOV AH, 3Eh
	MOV BX, [Filehandle]

	INT 21h
 
ENDM callCloseFile



printnum MACRO inputdata ; inputdata is assumed as Word variable
    LOCAL start , print ; MUST be at the 2nd line , DO NOT LEAVE EMPTY LINE
 
	pusha
	
    MOVzx AX , inputdata
    MOV CX , 0
    MOV DX , 0
    MOV BX , 10

    start:        
        DIV BX         ; Divides the input every iteration by 10 to extract one digit from it
        ADD DL , '0'   ; Adds '0' to convert the digit to its ascii value
        PUSH DX        ; Push it to the stack because we extract values from right and we want to print it from the left
        MOV DX , 0     ; resets the DX register in order not to have division overflow (div treats the number as DX:AX)
        INC CX         ; count the number of digits to pop them from the stack and print

    CMP AX , 0
    JNE start

    print:
        POP DX
        MOV AH , 2
        INT 21h
    LOOP print

	popa
ENDM printnum


printTime MACRO

   MOV DH , 0
   MOV DL , 18
   MOV BH , 0
   MOV AH , 2
   INT 10h
   mov ah , 9
   mov dl , offset spaceforprinting
   int 21h


   MOV DH , 0
   MOV DL , 18
   MOV BH , 0
   MOV AH , 2
   INT 10h
   printnum gametimer


ENDM printTime
