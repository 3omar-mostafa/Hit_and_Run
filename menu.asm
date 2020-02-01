; This file displays the main menu

.MODEL SMALL
.STACK 2048
.386 ; sets the instruction set of 80386 processor

PUBLIC MenuScreen

EXTRN Game:NEAR
INCLUDE const.inc
INCLUDE inout.inc
INCLUDE draw.inc

.DATA

	MENU_IMAGE_WIDTH EQU 200
	MENU_IMAGE_HEIGHT EQU 200

	menuFilename DB "images\menu.img", 0
	menuFileHandle DW ?

.CODE


MenuScreen PROC

	callOpenFile menuFilename , menuFileHandle
	
	_label_start_menu:

		callSwitchToGraphicsMode

		callDrawLargeImage menuFileHandle , 60 , 0 , MENU_IMAGE_WIDTH , MENU_IMAGE_HEIGHT

		_label_wait_for_valid_input:
			callGetPressedKey

			CMP AH , F1_SCAN_CODE
			JE start_chatting
			
			CMP AH , F2_SCAN_CODE
			JE start_game
			
			CMP AH , ESC_SCAN_CODE
			JE _label_finish
			
		JMP _label_wait_for_valid_input
		
		
	start_chatting:

	JMP _label_start_menu
	
	start_game:
		CALL Game
	JMP _label_start_menu
	
	_label_finish:
	callCloseFile menuFileHandle
	RET
MenuScreen ENDP

END