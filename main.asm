.Model Small
.386 ; sets the instruction set of 80386 prosessor
.Stack 64
.Data

; This is an external PROC that is defined in welcome.asm
; The linker will join them
EXTRN displayWelcomeScreen:NEAR

.Code
MAIN PROC FAR

	CALL initializeDataSegment
	
	CALL switchToGraphicsMode

	CALL displayWelcomeScreen
	
	; Press any key to exit
	CALL waitForAnyKey
	CALL switchToTextMode
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



; @Returns Pressed key  scancode -> AH
; @Returns Pressed key ASCIIcode -> AL
waitForAnyKey PROC


    MOV AH , 0
    INT 16h
    
	RET
waitForAnyKey ENDP



switchToTextMode PROC
	PUSH AX
	
    MOV AH,0          
    MOV AL,03h
    INT 10h 
	
	POP AX
	
	RET
switchToTextMode ENDP



switchToGraphicsMode PROC
	PUSH AX
	
    MOV AH, 0
    MOV AL, 13h
    INT 10h

	
	POP AX
	
	RET
switchToGraphicsMode ENDP

END MAIN