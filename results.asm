.MODEL SMALL
.STACK 2048
.386 ; sets the instruction set of 80386 processor

PUBLIC displayResults


; These procedures are public
; i.e. can be called from another assembly file
; shows the effect of drawing letters on the screen

INCLUDE colors.inc
INCLUDE alphabet.inc
INCLUDE inout.inc

.DATA
    yourScore DB "Score = " , '$'

    ; Sizes for letters :
    ; extra large , large , medium , small , extra small
    lineWidthXL EQU 8
    lineWidthL  EQU 6
    lineWidthM  EQU 4
    lineWidthS  EQU 2
    lineWidthXS EQU 1

.CODE

displayResults PROC

    ; Parameters:
    ; AL -> Player1.lives
    ; AH -> Player2.lives
    ; CX -> Player1.score
    ; DX -> Player2.score
	
	callSwitchToGraphicsMode
	
	callSetCursorPosition 5 , 5

	callPrintString yourScore

	callPrintNumber DX
	
	callSetCursorPosition 24 , 5

	callPrintString yourScore

	callPrintNumber CX
	
	
	CMP AL , AH
	JB _label_player1_win
	
	CMP AL , AH
	JG _label_player1_loses
	
	CMP CX , DX
	JB _label_player1_win
	
	CMP CX , DX
	JG _label_player1_loses
	

    _label_player1_player2_draw:
        draw_D 	color_orange , 70      	  		 , 70 , lineWidthXL
        draw_R 	color_orange , 70+6*lineWidthXL  , 70 , lineWidthXL
        draw_A 	color_orange , 70+12*lineWidthXL , 70 , lineWidthXL
        draw_W 	color_orange , 70+18*lineWidthXL , 70 , lineWidthXL
	
	
	JMP _label_finish


    _label_player1_win:

        callDrawColumnUp color_white , lineWidthL , 150 , 0 , 200

        draw_Y 	color_bright_green , 50                , 70 , lineWidthM
        draw_O 	color_bright_green , 50+6*lineWidthM   , 70 , lineWidthM
        draw_U 	color_bright_green , 50+12*lineWidthM  , 70 , lineWidthM
        
        draw_W 	color_bright_green , 50               , 120 , lineWidthM
        draw_I 	color_bright_green , 50+6*lineWidthM  , 120 , lineWidthM
        draw_N 	color_bright_green , 50+12*lineWidthM , 120 , lineWidthM
        
        draw_Y 	color_red , 190               , 70 , lineWidthM
        draw_O 	color_red , 190+6*lineWidthM  , 70 , lineWidthM
        draw_U 	color_red , 190+12*lineWidthM , 70 , lineWidthM
        
        draw_L 	color_red , 180               , 120 , lineWidthM
        draw_O 	color_red , 180+6*lineWidthM  , 120 , lineWidthM
        draw_S 	color_red , 180+12*lineWidthM , 120 , lineWidthM
        draw_E 	color_red , 180+18*lineWidthM , 120 , lineWidthM
	
	JMP _label_finish


    _label_player1_loses:

        callDrawColumnUp color_white , lineWidthL , 150 , 0 , 200

        draw_Y 	color_bright_green , 190               , 70 , lineWidthM
        draw_O 	color_bright_green , 190+6*lineWidthM  , 70 , lineWidthM
        draw_U 	color_bright_green , 190+12*lineWidthM , 70 , lineWidthM
        
        draw_W 	color_bright_green , 190               , 120 , lineWidthM
        draw_I 	color_bright_green , 190+6*lineWidthM  , 120 , lineWidthM
        draw_N 	color_bright_green , 190+12*lineWidthM , 120 , lineWidthM
        
        
        draw_Y 	color_red , 50               , 70 , lineWidthM
        draw_O 	color_red , 50+6*lineWidthM  , 70 , lineWidthM
        draw_U 	color_red , 50+12*lineWidthM , 70 , lineWidthM
        
        draw_L 	color_red , 40               , 120 , lineWidthM
        draw_O 	color_red , 40+6*lineWidthM  , 120 , lineWidthM
        draw_S 	color_red , 40+12*lineWidthM , 120 , lineWidthM
        draw_E 	color_red , 40+18*lineWidthM , 120 , lineWidthM
        

    _label_finish:

        callDelayInSeconds 3

	RET
displayResults ENDP


END