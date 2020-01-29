; This file displays the main menu

.MODEL SMALL
.STACK 2048
.386 ; sets the instruction set of 80386 processor

PUBLIC MenuScreen

EXTRN Game:NEAR
EXTRN Chat:NEAR
; Chat Windows variables
EXTRN windowOneStartX:BYTE
EXTRN windowOneEndX:BYTE
EXTRN windowOneStartY:BYTE
EXTRN windowOneEndY:BYTE
EXTRN WindowOneColor:BYTE
EXTRN windowTwoStartX:BYTE
EXTRN windowTwoEndX:BYTE
EXTRN windowTwoStartY:BYTE
EXTRN windowTwoEndY:BYTE
EXTRN WindowTwoColor:BYTE

INCLUDE inout.inc
INCLUDE draw.inc
INCLUDE serial.inc

.DATA

	F1_SCAN_CODE  EQU  3Bh
	F2_SCAN_CODE  EQU  3Ch
	F3_SCAN_CODE  EQU  3Dh
	F4_SCAN_CODE  EQU  3Eh
	ESC_SCAN_CODE EQU  01h

	menuImageWidth  EQU 200
	menuImageHeight EQU 200

	menuFilename DB 'menu.img', 0
	menuFileHandle DW ?

.CODE


MenuScreen PROC

	callInitializeUART

	callOpenFile menuFilename,menuFileHandle
	
	start:

		callSwitchToGraphicsMode

		callDrawLargeImage menuFileHandle , 60 , 0 , menuImageWidth , menuImageHeight

	getKey:
		callGetPressedKey
				
		CMP AH , F1_SCAN_CODE
		JE start_chatting
		
		CMP AH , F2_SCAN_CODE
		JE start_game
		
		CMP AH , ESC_SCAN_CODE
		JNE getKey
		
		JMP exit
		
		
		start_chatting:
			CALL prepareChat
			CALL Chat
		JMP start
		
		start_game:
			CALL Game
		JMP start
	
	exit:
		callCloseFile menuFileHandle
		RET
MenuScreen ENDP


prepareChat PROC

	callSwitchToTextMode

	MOV windowOneStartX , 0
	MOV windowOneEndX , 79
	MOV windowOneStartY , 0
	MOV windowOneEndY , 12
	MOV WindowOneColor , 1FH

	MOV windowTwoStartX , 0
	MOV windowTwoEndX , 79
	MOV windowTwoStartY , 13
	MOV windowTwoEndY , 24
	MOV WindowTwoColor , 4FH

	RET
prepareChat ENDP

END