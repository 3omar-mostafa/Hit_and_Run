; This file contains PROCs that handles input/output of the system

; The parametes for these PROCs are prepared by MACROs in inout.inc
; DO NOT CALL THESE PROCs DIRECTLY

.MODEL SMALL
.STACK 64
.386 ; sets the instruction set of 80386 prosessor
.CODE


; These procedures are public
; i.e. can be called from another assembly file
PUBLIC setCursorPosition
PUBLIC getCursorPosition
PUBLIC waitForAnyKey
PUBLIC displayString
PUBLIC switchToTextMode
PUBLIC switchToGraphicsMode


setCursorPosition PROC
	
	; Parameters :
	; DL -> x
	; DH -> y
	
	MOV AH , 2
	INT 10h

	RET
setCursorPosition ENDP



; @Returns x -> DL
; @Returns y -> DH
getCursorPosition PROC

	MOV AH , 13
	MOV BH , 0
	INT 10h

	RET
getCursorPosition ENDP



; @Returns Pressed key  scancode -> AH
; @Returns Pressed key ASCIIcode -> AL
waitForAnyKey PROC

    MOV AH , 0
    INT 16h
    
	RET
waitForAnyKey ENDP


displayString PROC

	; Parameters :
	; DX -> string to display terminated with '$'

    MOV AH, 9
    INT 21h
	
	RET
displayString ENDP



switchToTextMode PROC

    MOV AH,0          
    MOV AL,03h
    INT 10h 
	
	RET
switchToTextMode ENDP



switchToGraphicsMode PROC

    MOV AH, 0
    MOV AL, 13h
    INT 10h
	
	RET
switchToGraphicsMode ENDP


END