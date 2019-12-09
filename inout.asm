; This file contains PROCs that handles input/output of the system

; The parametes for these PROCs are prepared by MACROs in inout.inc
; DO NOT CALL THESE PROCs DIRECTLY

.MODEL SMALL
.STACK 2048
.386 ; sets the instruction set of 80386 prosessor
.DATA

spaceforprinting db '    ','$'


.CODE

; These procedures are public
; i.e. can be called from another assembly file
PUBLIC setCursorPosition
PUBLIC getCursorPosition
PUBLIC waitForAnyKey
PUBLIC displayString
PUBLIC switchToTextMode
PUBLIC switchToGraphicsMode
PUBLIC openFile
PUBLIC loadData
PUBLIC closeFile
PUBLIC spaceforprinting



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


openFile PROC 

	;Parameters
	;DX -> filename
	;SI -> fieHandle

    MOV AH, 3Dh
    MOV AL, 0 ; read only
    INT 21h
    
    ; you should check carry flag to make sure it worked correctly
    ; carry = 0 -> successful , file handle -> AX
    ; carry = 1 -> failed , AX -> error code
     
    MOV [SI], AX
    
    RET

openFile ENDP

loadData PROC

	;Parameters
	; SI -> fieHandle
	; CX -> number of bytes to read
	; DX -> imageData (where to save the data we get from the file)

    MOV AH,3Fh
    MOV BX, SI
    INT 21h
    RET
loadData ENDP 


closeFile PROC
	
	;Parameters
    ;SI -> fieHandle
	
	MOV AH, 3Eh
	MOV BX, [SI]

	INT 21h
	RET
closeFile ENDP






END