; This file contains Procedures that handles input/output of the system

; The parameters for these Procedures are prepared by MACROs in inout.inc
; DO NOT CALL THESE Procedures DIRECTLY

.MODEL SMALL
.STACK 2048
.386 ; sets the instruction set of 80386 processor

; These procedures are public
; i.e. can be called from another assembly file
PUBLIC setCursorPosition
PUBLIC getCursorPosition
PUBLIC isKeyPressed
PUBLIC getPressedKey
PUBLIC printString
PUBLIC switchToTextMode
PUBLIC switchToGraphicsMode
.CODE

setCursorPosition PROC
	
	; Parameters :
	; DL -> x
	; DH -> y
	
	MOV AH , 2
	MOV BH , 0 ; page number
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

; return AH -> scan code , AL -> ASCII code
getPressedKey PROC

	MOV AH , 0
	INT 16H

	RET
getPressedKey ENDP


; @Return answer in Zero flag
; Zero Flag = 0 -> true , Zero Flag = 1 -> false
; JNZ -> true , JZ -> false
; return AH -> scan code , AL -> ASCII code
isKeyPressed PROC

	MOV AH , 1
	INT 16H

	RET
isKeyPressed ENDP



; string is printed at the current cursor position
printString PROC

	; Parameters :
	; DX -> string to display terminated with '$'

	MOV AH, 9
	INT 21h
	
	RET
printString ENDP

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