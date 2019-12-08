; This file displays the main menu

.MODEL SMALL
.STACK 1024
.386 ; sets the instruction set of 80386 prosessor
.DATA

F1Scancode  EQU  3Bh
F2Scancode  EQU  3Ch
F3Scancode  EQU  3Dh
F4Scancode  EQU  3Eh
ESCScancode EQU  01h


imagewidth  EQU 200
imageheight EQU 200

positionInFile DW 0
menuFilename DB 'menu.img', 0
menuFilehandle DW ?
menuData DB ?

pressedKeyScanCode DB ?

EXTRN Graphics:FAR

.CODE
INCLUDE inout.inc

PUBLIC MenuScreen


MenuScreen PROC FAR
	
	MOV AX , @DATA
	MOV DS , AX

start:

	callSwitchToGraphicsMode

	callOpenFile menuFilename,menuFilehandle

	
	LEA BX , menuData ; BL contains index at the current drawn pixel
	
	MOV CX,60 ; x1
	MOV DX,0 ; y1
	MOV AH,0ch
	
; Drawing loop
drawLoop:

pusha
	;JUMP TO POSITION INSIDE THE FILE.                            <==============
  mov  ah, 42h          	;SERVICE FOR SEEK.
  mov  al, 0            	;START FROM THE BEGINNING OF FILE.
  mov  bx, menuFilehandle  	;FILE.
  mov  cx, 0            	;THE FILE POSITION MUST BE PLACED IN
  mov  dx, positionInFile   ;CX:DX, EXAMPLE, TO JUMP TO POSITION
  int  21h

;READ ONE CHAR FROM CURRENT FILE POSITION.
  mov  ah, 3fh          ;SERVICE TO READ FROM FILE.
  mov  bx, menuFilehandle
  mov  cx, 1            ;HOW MANY BYTES TO READ.
  inc positionInFile
  lea  dx, menuData       ;WHERE TO STORE THE READ BYTES.  
  int  21h
	
popa
	
	MOV AL,[BX]
	INT 10h 
	INC CX
	CMP CX,260 
JNE drawLoop 

	MOV CX , 60
	INC DX
	CMP DX , 200
JNE drawLoop
	
	
	callCloseFile menuFilehandle
	

getKey:
    callWaitForAnyKey
	mov pressedKeyScanCode , AH
	
	CMP pressedKeyScanCode , F1Scancode
	JE start_chatting
	
	CMP pressedKeyScanCode , F2Scancode
	JE start_game
	
	
	CMP pressedKeyScanCode , ESCScancode
	JNE getKey
	
	JMP exit
	
	
	; TODO: to be continued
	start_chatting:

	
	JMP start
	
;----------------------------------

	start_game:
	CALL Graphics
	jmp exit
	
	
	JMP start
	
exit:
	;RET
	
callSwitchToTextMode
	
	; return control to operating system
    MOV AH , 4ch
    INT 21H
	
MenuScreen ENDP

END MenuScreen