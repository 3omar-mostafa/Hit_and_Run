; This file displays the main menu

.MODEL SMALL
INCLUDE inout.inc
.STACK 64
.386 ; sets the instruction set of 80386 prosessor
.DATA

F1Scancode  EQU  3Bh
F2Scancode  EQU  3Ch
F3Scancode  EQU  3Dh
F4Scancode  EQU  3Eh
ESCScancode EQU  01h


imagewidth  EQU 200
imageheight EQU 200

menuFilename DB 'menu.img', 0
menuFilehandle DW ?
menuData DB imagewidth*imageheight dup(2)

pressedKeyScanCode DB ?

;EXTRN Graphics:FAR

.CODE

PUBLIC MenuScreen


MenuScreen PROC FAR
	
	MOV AX , @DATA
	MOV DS , AX

	callSwitchToGraphicsMode

	callOpenFile menuFilename,menuFilehandle
	callLoadData menuFilehandle,menuData,imagewidth,imageheight
	callCloseFile menuFilehandle
	
	CALL drawMenu

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

	
	JMP exit
	
	start_game:
	;CALL Graphics
	JMP exit
	
exit:
	;RET
	
callSwitchToTextMode
	
	    ; return control to operating system
    MOV AH , 4ch
    INT 21H
	
MenuScreen ENDP


drawMenu PROC

	MOV AH ,0ch
	MOV CX , 0
	MOV DX , 0

	
	LEA BX , menuData ; BL contains index at the current drawn pixel
	
	MOV CX,60 ; x1
	MOV DX,0 ; y1
	MOV AH,0ch
	
	
; Drawing loop
drawLoop:

	MOV AL,[BX]
	INT 10h 
	INC CX
	INC BX
	CMP CX,260 
JNE drawLoop 

	MOV CX , 60
	INC DX
	CMP DX , 200
JNE drawLoop

RET

drawMenu ENDP


END MenuScreen