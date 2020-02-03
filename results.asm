.MODEL SMALL
.STACK 2048
.386 ; sets the instruction set of 80386 processor

PUBLIC displayResults

EXTRN isSplitScreenGame:BYTE


INCLUDE colors.inc
INCLUDE alphabet.inc
INCLUDE inout.inc
INCLUDE const.inc

.DATA

	; Sizes for letters :
	; extra large , large , medium , small , extra small
	LINE_WIDTH_XL EQU 8
	LINE_WIDTH_L  EQU 6
	LINE_WIDTH_M  EQU 4
	LINE_WIDTH_S  EQU 2
	LINE_WIDTH_XS EQU 1

.CODE

displayResults PROC

	; Parameters:
	; AL -> Player1.lives
	; AH -> Player2.lives
	; CX -> Player1.score
	; DX -> Player2.score
	
	callSwitchToGraphicsMode ; To clear the screen
	
	CMP AL , AH
	JB _label_player1_win
	
	CMP AL , AH
	JG _label_player1_loses
	
	CMP CX , DX
	JG _label_player1_win
	
	CMP CX , DX
	JB _label_player1_loses
	

	_label_player1_player2_draw:
		draw_D COLOR_ORANGE , 70                  , 70 , LINE_WIDTH_XL
		draw_R COLOR_ORANGE , 70+6*LINE_WIDTH_XL  , 70 , LINE_WIDTH_XL
		draw_A COLOR_ORANGE , 70+12*LINE_WIDTH_XL , 70 , LINE_WIDTH_XL
		draw_W COLOR_ORANGE , 70+18*LINE_WIDTH_XL , 70 , LINE_WIDTH_XL
	
	
	JMP _label_finish


	_label_player1_win:

		CMP isSplitScreenGame , true
		JE _label_player1_win_split_screen

			draw_Y COLOR_BRIGHT_GREEN , 80                   , 25 , LINE_WIDTH_XL
			draw_O COLOR_BRIGHT_GREEN , 80+6*LINE_WIDTH_XL   , 25 , LINE_WIDTH_XL
			draw_U COLOR_BRIGHT_GREEN , 80+12*LINE_WIDTH_XL  , 25 , LINE_WIDTH_XL
			
			draw_W COLOR_BRIGHT_GREEN , 80                  , 115 , LINE_WIDTH_XL
			draw_I COLOR_BRIGHT_GREEN , 80+6*LINE_WIDTH_XL  , 115 , LINE_WIDTH_XL
			draw_N COLOR_BRIGHT_GREEN , 80+12*LINE_WIDTH_XL , 115 , LINE_WIDTH_XL
	
		JMP _label_finish

		_label_player1_win_split_screen:
			
			callDrawColumnUp COLOR_WHITE , LINE_WIDTH_L , 150 , 0 , 200

			draw_Y COLOR_BRIGHT_GREEN , 200                 , 50 , LINE_WIDTH_M
			draw_O COLOR_BRIGHT_GREEN , 200+6*LINE_WIDTH_M  , 50 , LINE_WIDTH_M
			draw_U COLOR_BRIGHT_GREEN , 200+12*LINE_WIDTH_M , 50 , LINE_WIDTH_M
			
			draw_W COLOR_BRIGHT_GREEN , 200                 , 110 , LINE_WIDTH_M
			draw_I COLOR_BRIGHT_GREEN , 200+6*LINE_WIDTH_M  , 110 , LINE_WIDTH_M
			draw_N COLOR_BRIGHT_GREEN , 200+12*LINE_WIDTH_M , 110 , LINE_WIDTH_M
			
			
			draw_Y COLOR_RED , 40                 , 50 , LINE_WIDTH_M
			draw_O COLOR_RED , 40+6*LINE_WIDTH_M  , 50 , LINE_WIDTH_M
			draw_U COLOR_RED , 40+12*LINE_WIDTH_M , 50 , LINE_WIDTH_M
			
			draw_L COLOR_RED , 30                 , 110 , LINE_WIDTH_M
			draw_O COLOR_RED , 30+6*LINE_WIDTH_M  , 110 , LINE_WIDTH_M
			draw_S COLOR_RED , 30+12*LINE_WIDTH_M , 110 , LINE_WIDTH_M
			draw_E COLOR_RED , 30+18*LINE_WIDTH_M , 110 , LINE_WIDTH_M

	JMP _label_finish


	_label_player1_loses:

		CMP isSplitScreenGame , true
		JE _label_player1_loses_split_screen
		
			draw_Y COLOR_RED , 80                  , 25 , LINE_WIDTH_XL
			draw_O COLOR_RED , 80+6*LINE_WIDTH_XL  , 25 , LINE_WIDTH_XL
			draw_U COLOR_RED , 80+12*LINE_WIDTH_XL , 25 , LINE_WIDTH_XL
			
			draw_L COLOR_RED , 70                  , 115 , LINE_WIDTH_XL
			draw_O COLOR_RED , 70+6*LINE_WIDTH_XL  , 115 , LINE_WIDTH_XL
			draw_S COLOR_RED , 70+12*LINE_WIDTH_XL , 115 , LINE_WIDTH_XL
			draw_E COLOR_RED , 70+18*LINE_WIDTH_XL , 115 , LINE_WIDTH_XL
		
		JMP _label_finish

		_label_player1_loses_split_screen:

			callDrawColumnUp COLOR_WHITE , LINE_WIDTH_L , 150 , 0 , 200

			draw_Y COLOR_BRIGHT_GREEN , 40                  , 50 , LINE_WIDTH_M
			draw_O COLOR_BRIGHT_GREEN , 40+6*LINE_WIDTH_M   , 50 , LINE_WIDTH_M
			draw_U COLOR_BRIGHT_GREEN , 40+12*LINE_WIDTH_M  , 50 , LINE_WIDTH_M
			
			draw_W COLOR_BRIGHT_GREEN , 40                 , 110 , LINE_WIDTH_M
			draw_I COLOR_BRIGHT_GREEN , 40+6*LINE_WIDTH_M  , 110 , LINE_WIDTH_M
			draw_N COLOR_BRIGHT_GREEN , 40+12*LINE_WIDTH_M , 110 , LINE_WIDTH_M
			
			draw_Y COLOR_RED , 200                 , 50 , LINE_WIDTH_M
			draw_O COLOR_RED , 200+6*LINE_WIDTH_M  , 50 , LINE_WIDTH_M
			draw_U COLOR_RED , 200+12*LINE_WIDTH_M , 50 , LINE_WIDTH_M
			
			draw_L COLOR_RED , 190                 , 110 , LINE_WIDTH_M
			draw_O COLOR_RED , 190+6*LINE_WIDTH_M  , 110 , LINE_WIDTH_M
			draw_S COLOR_RED , 190+12*LINE_WIDTH_M , 110 , LINE_WIDTH_M
			draw_E COLOR_RED , 190+18*LINE_WIDTH_M , 110 , LINE_WIDTH_M


	_label_finish:

		callDelayInSeconds 3

	RET
displayResults ENDP


END