; This file displays the welcome screen
; i.e. WELCOME TO HIT AND RUN

.MODEL SMALL
.STACK 2048
.386 ; sets the instruction set of 80386 processor

; These procedures are public
; i.e. can be called from another assembly file
PUBLIC displayWelcomeScreen

; These are External Procedures in draw.asm
; The linker will join them
EXTRN drawColumnUp:NEAR
EXTRN drawColumnDown:NEAR
EXTRN drawRowLeft:NEAR
EXTRN drawRowRight:NEAR

; shows the effect of drawing letters on the screen
EXTRN letterDrawingSpeed:BYTE ; MIN value is 1

INCLUDE colors.inc
INCLUDE alphabet.inc
INCLUDE inout.inc

.DATA

    message DB "Press any key to Continue",'$'

    ; Sizes for letters :
    ; extra large , large , medium , small , extra small
    lineWidthXL EQU 8
    lineWidthL  EQU 6
    lineWidthM  EQU 4
    lineWidthS  EQU 2
    lineWidthXS EQU 1

    ; for WELCOME word
    start_x1 EQU 80
    start_y1 EQU 10

    ; for TO word
    start_x2 EQU 140
    start_y2 EQU 60

    ; for HIT , RUN words
    start_x3 EQU 20
    start_y3 EQU 100

    ; for AND word
    start_x4 EQU 140
    start_y4 EQU 110

    ; for Press any key to Continue
    start_x5 EQU 7
    start_y5 EQU 150


.CODE

displayWelcomeScreen PROC

    callSwitchToGraphicsMode

    MOV letterDrawingSpeed , 60

	; WARNING: DO NOT PUT SPACES BETWEEN ANY OPERAND IN THE SAME PARAMETER
	; IT WILL TREAT IT AS TWO PARAMETERS AND GIVE ERRORS
	; EX: start_x1+6*lineWidthM -> start_x1 + 6 * lineWidthM
	
    draw_W 	color_light_green , start_x1               , start_y1 , lineWidthM
    draw_E 	color_light_green , start_x1+6*lineWidthM  , start_y1 , lineWidthM
    draw_L 	color_light_green , start_x1+12*lineWidthM , start_y1 , lineWidthM
    draw_C 	color_light_green , start_x1+18*lineWidthM , start_y1 , lineWidthM
    draw_O 	color_light_green , start_x1+24*lineWidthM , start_y1 , lineWidthM
    draw_M 	color_light_green , start_x1+30*lineWidthM , start_y1 , lineWidthM
    draw_E 	color_light_green , start_x1+36*lineWidthM , start_y1 , lineWidthM
	
    draw_T 	color_light_orange , start_x2               , start_y2 , lineWidthS
    draw_O 	color_light_orange , start_x2+12*lineWidthS , start_y2 , lineWidthS
	
    draw_H 	color_dark_red , start_x3               , start_y3 , lineWidthL
    draw_I 	color_dark_red , start_x3+6*lineWidthL  , start_y3 , lineWidthL
    draw_T 	color_dark_red , start_x3+12*lineWidthL , start_y3 , lineWidthL
	
    draw_A 	color_light_orange , start_x4               , start_y4 , lineWidthS
    draw_N 	color_light_orange , start_x4+6*lineWidthS  , start_y4 , lineWidthS
    draw_D 	color_light_orange , start_x4+12*lineWidthS , start_y4 , lineWidthS
	
    draw_R 	color_blue , start_x3+30*lineWidthL , start_y3 , lineWidthL
    draw_U 	color_blue , start_x3+36*lineWidthL , start_y3 , lineWidthL
    draw_N 	color_blue , start_x3+42*lineWidthL , start_y3 , lineWidthL
    
	callSetCursorPosition start_x5  start_y5
	callPrintString message
    callWaitForAnyKey


	RET
displayWelcomeScreen ENDP


END