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

INCLUDE const.inc
INCLUDE inout.inc
INCLUDE draw.inc
INCLUDE serial.inc

.DATA

	MENU_IMAGE_WIDTH EQU 280
	MENU_IMAGE_HEIGHT EQU 140

	menuFilename DB "images\menu.img", 0
	menuFileHandle DW ?

.CODE


MenuScreen PROC

	callInitializeUART
	
	callOpenFile menuFilename , menuFileHandle
	
	_label_start_menu:

		callSwitchToGraphicsMode

		callDrawLargeImage menuFileHandle , 20 , 20 , MENU_IMAGE_WIDTH , MENU_IMAGE_HEIGHT

		_label_wait_for_valid_input:
			callGetPressedKey

			CMP AH , F1_SCAN_CODE
			JE _label_start_chatting
			
			CMP AH , F2_SCAN_CODE
			JE _label_start_game_split_screen
			
			CMP AH , F3_SCAN_CODE
			JE _label_start_game_two_devices
			
			CMP AH , F4_SCAN_CODE
			JE _label_show_instructions
			
			CMP AH , ESC_SCAN_CODE
			JE _label_finish
			
		JMP _label_wait_for_valid_input
		
		
	_label_start_chatting:
		CALL prepareChat
		CALL Chat
	JMP _label_start_menu
	

	_label_start_game_split_screen:

	JMP _label_start_menu
	

	_label_start_game_two_devices:
		CALL Game
	JMP _label_start_menu
	

	_label_show_instructions:

	JMP _label_start_menu


	_label_finish:
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