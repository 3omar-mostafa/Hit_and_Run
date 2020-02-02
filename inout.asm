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
PUBLIC clearKeyboardBuffer
PUBLIC printString
PUBLIC switchToTextMode
PUBLIC switchToGraphicsMode
PUBLIC openFile
PUBLIC loadImageData
PUBLIC closeFile
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


clearKeyboardBuffer PROC
	_label_clearKeyboardBuffer_clear:
		CALL isKeyPressed
		JZ _label_clearKeyboardBuffer_finish
		CALL getPressedKey
	JMP _label_clearKeyboardBuffer_clear
	
	_label_clearKeyboardBuffer_finish:
	RET
clearKeyboardBuffer ENDP


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

; @Return result in carry flag
; Carry = 0 -> successful , Carry = 1 -> failed
; JNC -> succeeded , JC -> failed
openFile PROC 

	; Parameters
	; DX -> filename
	; SI -> fileHandle

	MOV AH , 3Dh
	MOV AL , 0 ; read only
	INT 21h ; return file handle in AX if succeeded
	MOV [SI] , AX
	
	RET
openFile ENDP


; Loads data from image with its fileHandle and save them in imageData
; dimensions of the image is 16 px * 16 px
; imageData is assumed an array with available space to store the data (16 * 16 bytes)
loadImageData PROC

	; Parameters
	; SI -> fileHandle
	; CX -> number of bytes to read
	; DX -> imageData (where to save the data we get from the file)

	MOV AH , 3Fh
	MOV CX , 16*16 ; size the image
	INT 21h
	RET
loadImageData ENDP 


closeFile PROC
	
	; Parameters
	; SI -> fileHandle
	
	MOV AH , 3Eh
	MOV BX , [SI]

	INT 21h
	RET
closeFile ENDP


END