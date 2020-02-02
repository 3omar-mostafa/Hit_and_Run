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
PUBLIC isLetter
PUBLIC readString
PUBLIC printString
PUBLIC clearCharacters
PUBLIC switchToTextMode
PUBLIC switchToGraphicsMode
PUBLIC openFile
PUBLIC loadImageData
PUBLIC closeFile
PUBLIC getSystemTime
PUBLIC delayInSeconds

PUBLIC time_seconds

.DATA

	time_seconds DB ?

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


; @Return result in carry flag
; Carry = 1 -> true , Carry = 0 -> false
; JC -> true , JNC -> false
isLetter PROC

	; Parameters:
	; AL -> Character

	_label_isLetter_check_Capital_A:
		CMP AL , "A"
		JAE _label_isLetter_check_Capital_Z
		JMP _label_isLetter_check_small_a

	_label_isLetter_check_Capital_Z:   
		CMP AL , "Z"
		JBE _label_isLetter_true


	_label_isLetter_check_small_a:
		CMP AL , "a" 
		JAE _label_isLetter_check_small_z
		JMP _label_isLetter_false
	
	_label_isLetter_check_small_z:
		CMP AL , "z"
		JBE _label_isLetter_true
		JMP _label_isLetter_false

	_label_isLetter_true:
		STC
	JMP _label_isLetter_finish

	_label_isLetter_false:
		CLC

	_label_isLetter_finish:
	RET
isLetter ENDP


; inputBuffer should have 2 bytes before it determining the size of buffer
; inputBuffer offsets:
; DX-2 -> max bytes to read including Enter
; DX-1 -> @return the actual number of characters read
; DX   -> the input string
; returned string is saved at memory location of DX
readString PROC

	; Parameters :
	; DX -> inputBuffer to save input in

	MOV AH , 0Ah
	INT 21h

	; Add '$' terminator at the end of the string
	MOV BX , DX
	INC BX
	MOVZX SI , BYTE PTR DS:[BX] ; [BX] contains the actual number of read characters
	MOV BYTE PTR [BX][SI]+1 , '$' ; put in the last character '$' terminator
	
	RET
readString ENDP


; string is printed at the current cursor position
printString PROC

	; Parameters :
	; DX -> string to display terminated with '$'

	MOV AH, 9
	INT 21h
	
	RET
printString ENDP

; Clear number of characters to reprint over them without overlapping
; i.e. printing spaces to clear the screen
; Note: it does not change the cursor position
clearCharacters PROC

	; Parameters:
	; CX -> numberOfCharactersToClear

	MOV AH , 0Ah
	MOV AL , " " ; character to display
	MOV BH , 0 ; page number
	MOV BL , 0Fh ; color (white text on black background)
	INT 10h

	RET
clearCharacters ENDP


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


getSystemTime PROC
	; get system time (returns CH -> hour , CL -> minute -> DH = second)
	MOV AH , 2Ch
	INT 21h
	
	MOV time_seconds , DH
	
	RET
getSystemTime ENDP


delayOneSecond PROC
	PUSHA

	CALL getSystemTime
	MOV AL , time_seconds

	_label_delayOneSecond_delay:
		CALL getSystemTime
		CMP AL , time_seconds
	JE _label_delayOneSecond_delay
	
	POPA
	RET
delayOneSecond ENDP


delayInSeconds PROC

	; Parameters:
	; CX -> _label_delayOneSecond_delay

	MOV AH , time_seconds

	_label_delayInSeconds_delay:
		CALL delayOneSecond
	LOOP _label_delayInSeconds_delay

	MOV time_seconds , AH
	RET
delayInSeconds ENDP

END