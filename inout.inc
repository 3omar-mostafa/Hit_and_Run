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