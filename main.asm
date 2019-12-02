.Model Small
.386 ; sets the instruction set of 80386 prosessor
.Stack 64
.Data

INCLUDE inout.inc

; This is an external PROC that is defined in welcome.asm
; The linker will join them
EXTRN displayWelcomeScreen:NEAR

.Code
MAIN PROC FAR

	CALL initializeDataSegment
	
	callSwitchToGraphicsMode

	CALL displayWelcomeScreen
	
	; Press any key to exit
	callWaitForAnyKey
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