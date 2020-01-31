.MODEL SMALL
.STACK 2048
.386 ; sets the instruction set of 80386 processor

; This is an external PROC that is defined in welcome.asm
; The linker will join them
EXTRN displayWelcomeScreen:NEAR
EXTRN MenuScreen:NEAR

INCLUDE inout.inc

.DATA


.CODE
Main PROC FAR

	CALL initializeDataSegment
	
	CALL switchToGraphicsMode

	CALL displayWelcomeScreen
	
	; Press any key to exit
	CALL MenuScreen
	callSwitchToTextMode
	CALL exitProgram
	
Main ENDP


initializeDataSegment PROC
	MOV AX , @DATA
	MOV DS , AX
	
	RET
initializeDataSegment ENDP


; return control to operating system
exitProgram PROC

	MOV AH , 4Ch
	INT 21H

exitProgram ENDP


END Main