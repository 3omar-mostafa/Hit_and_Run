.Model Small
.386 ; sets the instruction set of 80386 prosessor
.Stack 2048
.Data

INCLUDE inout.inc

; This is an external PROC that is defined in welcome.asm
; The linker will join them
EXTRN displayWelcomeScreen:NEAR
EXTRN MenuScreen:NEAR

.Code
MAIN PROC FAR

	CALL initializeDataSegment
	
	callSwitchToGraphicsMode

	CALL displayWelcomeScreen
	CALL MenuScreen
	
	; Press any key to exit
	callSwitchToTextMode
	CALL exit
    
MAIN ENDP


initializeDataSegment PROC

    MOV AX , @DATA
    MOV DS , AX
	
	RET
initializeDataSegment ENDP


exit PROC
    ; return control to operating system
    MOV AH , 4ch
    INT 21H
exit ENDP


END MAIN