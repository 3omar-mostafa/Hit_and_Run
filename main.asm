.MODEL SMALL
.STACK 2048
.386 ; sets the instruction set of 80386 processor

.DATA


.CODE
Main PROC FAR

	CALL initializeDataSegment
	
	; Press any key to exit
	CALL waitForAnyKey
	CALL switchToTextMode
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



; @Returns Pressed key scan code -> AH
; @Returns Pressed key ASCII code -> AL
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

END Main