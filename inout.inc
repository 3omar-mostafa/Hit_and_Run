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