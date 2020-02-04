; This file displays the main menu

.MODEL SMALL
.STACK 2048
.386 ; sets the instruction set of 80386 processor

PUBLIC MenuScreen

EXTRN displayReadNameHeader:NEAR
EXTRN readSinglePlayerName:NEAR
EXTRN readTwoPlayersNames:NEAR

EXTRN Game:NEAR
EXTRN isSplitScreenGame:BYTE

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

	INSTRUCTIONS_IMAGE_WIDTH EQU 320
	INSTRUCTIONS_IMAGE_HEIGHT EQU 200

	instructions1Filename DB "images\instruc1.img" , 0
	instructions1FileHandle DW ?
	
	instructions2Filename DB "images\instruc2.img" , 0
	instructions2FileHandle DW ?

	instructions3Filename DB "images\instruc3.img" , 0
	instructions3FileHandle DW ?

	instructions4Filename DB "images\instruc4.img" , 0
	instructions4FileHandle DW ?


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
		CALL displayReadNameHeader
		CALL readTwoPlayersNames
		
		MOV isSplitScreenGame , true
		CALL Game
	JMP _label_start_menu
	

	_label_start_game_two_devices:
		CALL displayReadNameHeader
		CALL readSinglePlayerName

		MOV isSplitScreenGame , false
		CALL Game
	JMP _label_start_menu
	

	_label_show_instructions:
		callOpenFile instructions1Filename , instructions1FileHandle
		callDrawLargeImage instructions1FileHandle , 0 , 0 , INSTRUCTIONS_IMAGE_WIDTH , INSTRUCTIONS_IMAGE_HEIGHT
		callCloseFile instructions1FileHandle
		callWaitForAnyKey


		callOpenFile instructions2Filename , instructions2FileHandle
		callDrawLargeImage instructions2FileHandle , 0 , 0 , INSTRUCTIONS_IMAGE_WIDTH , INSTRUCTIONS_IMAGE_HEIGHT
		callCloseFile instructions2FileHandle
		callWaitForAnyKey


		callOpenFile instructions3Filename , instructions3FileHandle
		callDrawLargeImage instructions3FileHandle , 0 , 0 , INSTRUCTIONS_IMAGE_WIDTH , INSTRUCTIONS_IMAGE_HEIGHT
		callCloseFile instructions3FileHandle
		callWaitForAnyKey


		callOpenFile instructions4Filename , instructions4FileHandle
		callDrawLargeImage instructions4FileHandle , 0 , 0 , INSTRUCTIONS_IMAGE_WIDTH , INSTRUCTIONS_IMAGE_HEIGHT
		callCloseFile instructions4FileHandle
		callWaitForAnyKey

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