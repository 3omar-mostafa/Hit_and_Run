; This file contains MACROs fo preparing parameters and CALL the real Procedures in inout.asm
; These MACROs should be called instead of the Procedures in inout.asm

; THese procedures are external
; MUST be declared at another assembly file with same name,type
; so that the linker join them

EXTRN setCursorPosition:NEAR
EXTRN getCursorPosition:NEAR
EXTRN getPressedKey:NEAR
EXTRN isKeyPressed:NEAR
EXTRN printString:NEAR
EXTRN switchToTextMode:NEAR
EXTRN switchToGraphicsMode:NEAR
EXTRN openFile:NEAR
EXTRN loadImageData:NEAR
EXTRN closeFile:NEAR

callSetCursorPosition MACRO x , y
	PUSHA
	
	MOV DL , x
	MOV DH , y
	
	CALL setCursorPosition
	
	POPA
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



callWaitForAnyKey MACRO
	PUSH AX

	CALL getPressedKey

	POP AX
ENDM callWaitForAnyKey

; return AH -> scan code , AL -> ASCII code
callGetPressedKey MACRO

	CALL getPressedKey

ENDM callGetPressedKey


; @Return answer in Zero flag
; Zero Flag = 0 -> true , Zero Flag = 1 -> false
; JNZ -> true , JZ -> false
; return AH -> scan code , AL -> ASCII code
callIsKeyPressed MACRO

	CALL isKeyPressed

ENDM callIsKeyPressed


; string must be a memory location terminated with '$'
; string is printed at the current cursor position
callPrintString MACRO string
	PUSH AX
	PUSH DX
	
	LEA DX , string 
	
	CALL printString

	POP DX
	POP AX
ENDM callPrintString

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
; @ returns the output pointer to this file in fileHandle
callOpenFile MACRO filename , fileHandle
	PUSHA
	
	LEA DX , Filename
	LEA SI , fileHandle
	CALL openFile

	POPA
ENDM callOpenFile



; Loads data from image with its fileHandle and save them in imageData
; dimensions of the image is 16px * 16px
; imageData is assumed an array with available space to store the data (16 * 16 bytes)
callLoadImageData MACRO fileHandle , imageData
	PUSHA

	MOV BX , [fileHandle]
	LEA DX , imageData
	CALL loadImageData

	POPA
ENDM callLoadImageData


; Closes the opened file with its corresponding fileHandle
callCloseFile MACRO fileHandle 
	PUSHA

	LEA SI , fileHandle
	CALL closeFile

	POPA 
ENDM callCloseFile

