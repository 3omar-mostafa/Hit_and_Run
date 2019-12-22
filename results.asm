.Model Small
.386 ; sets the instruction set of 80386 prosessor
.Stack 2048
; These are External PROCs in draw.asm
; The linker will join them
EXTRN drawColumnUp:NEAR
EXTRN drawColumnDown:NEAR
EXTRN drawRowLeft:NEAR
EXTRN drawRowRight:NEAR

; Sizes for letters :
; extra large , large , medium , small , extra small
lineWidthXL EQU 8
lineWidthL  EQU 6
lineWidthM  EQU 4
lineWidthS  EQU 2
lineWidthXS EQU 1

; These procedures are public
; i.e. can be called from another assembly file
; shows the effect of drawing letters on the screen

EXTRN letterDrawingSpeed:BYTE

INCLUDE colors.inc
INCLUDE alphabet.inc
INCLUDE inout.inc

.Data
time db ?

yourscore DB 'Score = ' , '$'
.CODE

EXTRN score1:WORD
EXTRN score2:WORD
EXTRN heart1:WORD
EXTRN heart2:WORD

PUBLIC displayResults

displayResults PROC


	mov ax , @data
	mov ds , ax
	
	callSwitchToGraphicsMode
	
	MOV DH , 5
	MOV DL , 5
	MOV BH , 0
	MOV AH , 2
	INT 10h
	mov ah , 9
	mov dx , offset yourscore
	int 21h


	printnum score2
	
	
	MOV DH , 5
	MOV DL , 24
	MOV BH , 0
	MOV AH , 2
	INT 10h
	mov ah , 9
	mov dx , offset yourscore
	int 21h


	printnum score1
	

	mov ax , heart1
	mov bx , heart2
	mov cx , score1
	mov dx , score2


	
	cmp ax , bx
	jb player1Win
	
	cmp ax , bx
	jg player1Lose
	
	cmp cx , dx
	jb player1Win
	
	cmp cx , dx
	jg player1Lose
	
	
	draw_D 	02Bh	70      	  			70	lineWidthXL
    draw_R 	02Bh	70+6*lineWidthXL  		70	lineWidthXL
    draw_A 	02Bh	70+12*lineWidthXL		70	lineWidthXL
    draw_W 	02Bh	70+18*lineWidthXL		70	lineWidthXL
	
	
	jmp exit


player1Win:

	callDrawColumnUp    0fh lineWidthL	150 0  200

    draw_Y 	02fh	50      	  			70	lineWidthM
    draw_O 	02fh	50+6*lineWidthM  		70	lineWidthM
    draw_U 	02fh	50+12*lineWidthM 		70	lineWidthM
	
    draw_W 	02fh	50				 		120	lineWidthM
    draw_I 	02fh	50+6*lineWidthM 		120	lineWidthM
    draw_N 	02fh	50+12*lineWidthM 		120	lineWidthM
	
	draw_Y 	28h		190      	  			70	lineWidthM
    draw_O 	28h		190+6*lineWidthM  		70	lineWidthM
    draw_U 	28h		190+12*lineWidthM 		70	lineWidthM
	
    draw_L 	28h		180				 		120	lineWidthM
    draw_O 	28h		180+6*lineWidthM 		120	lineWidthM
    draw_S 	28h		180+12*lineWidthM 		120	lineWidthM
    draw_E 	28h		180+18*lineWidthM 		120	lineWidthM
	
	jmp exit

player1Lose:

	callDrawColumnUp    0fh lineWidthL	150 0  200

	draw_Y 	02fh	190      	  			70	lineWidthM
    draw_O 	02fh	190+6*lineWidthM  		70	lineWidthM
    draw_U 	02fh	190+12*lineWidthM 		70	lineWidthM
	
    draw_W 	02fh	190				 		120	lineWidthM
    draw_I 	02fh	190+6*lineWidthM 		120	lineWidthM
    draw_N 	02fh	190+12*lineWidthM 		120	lineWidthM
	
	
	draw_Y 	28h		50      	  			70	lineWidthM
    draw_O 	28h		50+6*lineWidthM  		70	lineWidthM
    draw_U 	28h		50+12*lineWidthM 		70	lineWidthM
	
    draw_L 	28h		40				 		120	lineWidthM
    draw_O 	28h		40+6*lineWidthM 		120	lineWidthM
    draw_S 	28h		40+12*lineWidthM 		120	lineWidthM
    draw_E 	28h		40+18*lineWidthM 		120	lineWidthM
	

exit:
	mov si , 5
	
wait1:
	call delay1sec
	dec si
	jnz wait1


	RET
displayResults ENDP



delay1sec PROC
    delay:
    
    ; get system time
    MOV AH , 2ch
    INT 21h
    
    CMP DH , time
    JE delay
    MOV time , DH
    
    RET
delay1sec ENDP

END