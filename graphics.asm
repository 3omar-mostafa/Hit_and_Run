.MODEL SMALL
.STACK 2048
.386 ; sets the instruction set of 80386 prosessor

public music 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;n
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;N
EXTRN INDATAP1:BYTE
EXTRN INDATAP2:BYTE
EXTRN KeyValue:BYTE
EXTRN initializeUART:NEAR
EXTRN sendChar:NEAR
EXTRN checkReceived:NEAR
EXTRN receiveChar:NEAR

EXTRN Chat:NEAR
; Inline Chat Windows variables
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;N
.DATA
include inout.inc
include draw.inc
test1 dw ?
test2 dw ?
time db ?

stackIP dw ?
	last_time db ?
	y_old DW ?
	gridWidth EQU 320
	gridHeight EQU 144
	
	gametimer db 255
	
	BP_Temp DW ?
	
	F4Scancode  EQU  3Eh
	
	positionInGridFile DW 0
	gridFilename DB 'grid.img', 0
	gridFilehandle DW ?
	gridData DB 0
	
	imagewidth EQU 16
	imageheight EQU 16
	
	
	bomerFilename DB 'bomer.img', 0
	bomerFilehandle DW ?
	bomerData DB imagewidth*imageheight dup(2)
	
	bomberx DW 288
	bomberY DW 128
	
	originalPlaceXP1 DW 288
	originalPlaceYP1 DW 128
	originalPlaceXP2 DW 16
	originalPlaceYP2 DW 32
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;N
    bomber2x DW 16
	bomber2Y DW 32
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;N
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;nn
	score1 dw 0000
	score2 dw 0000
	heart1 dw 10
	heart2 dw 10

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;nn
	bombFilename DB 'bomb.img', 0
	bombFilehandle DW ?
	bombData DB imagewidth*imageheight dup(2)
	
	bomb1_level DB 1
	bomb2_level DB 1
	
	coinFilename DB 'coin.img', 0
	coinFilehandle DW ?
	coinData DB imagewidth*imageheight dup(2)
	
	heartFilename DB 'heart.img', 0
	heartFilehandle DW ?
	heartData DB imagewidth*imageheight dup(2)
	
	PowerUpFilename DB 'PowerUp.img', 0
	PowerUpFilehandle DW ?
	PowerUpData DB imagewidth*imageheight dup(2)
	
	HPFilename DB 'HP.img', 0
	HPFilehandle DW ?
	HPData DB imagewidth*imageheight dup(2)

	ExitRecieving EQU 5
	ExitSending EQU 7
	
; set bit in Most signeficant bit refers to block (forbidden movement)
	X EQU  10000000b ; 128
	B EQU  10000001b ; 129
	G EQU  00000000b ; 0
	B1 EQU 10010000b ; 72
	B2 EQU 10100000b ; 160
	P1 EQU 00011000b ; 24
	P2 EQU 00101000b ; 40
	
	P  EQU 00001000b ; 8 -> powerup for bomb
	C EQU  00000010b ; 2
	H EQU  00000100b ; 4
	
	
	
	P_B EQU P or B
	C_B EQU C or B
	H_B EQU H or B
	
;  	    0   1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16  17  18  19
grid DB X , X , X , X , X , X , X , X , X , X , X , X , X , X , X , X , X , X , X , X
	 DB X , G , G , H_B , B , C_B , H_B , B , B , B , B , B , B , B , B , B , B , B , B , X                                                                  
	 DB X , G , X , C_B , X , G , X , B , X , G , G , X , B , X , G , X , B , X , G , X           
	 DB X , B , C_B , B , B , B , B , B , B , B , B , B , B , B , B , B , B , B , B , X                                                                                       
	 DB X , G , X , B , X , G , X , B , X , G , G , X , B , X , G , X , B , X , G , X                                                                                     
	 DB X , B , B , B , B , B , B , B , B , B , B , B , B , B , B , F_B , F_B , F_B , C_B , X                                                               
	 DB X , G , X , B , X , G , X , B , X , G , G , X , B , X , G , X , H_B , X , G , X                                                                                    
	 DB X , B , B , B , B , B , B , B , B , B , B , B , B , H_B , C_B , C_B , C_B , G , G , X                                                                    
	 DB X , X , X , X , X , X , X , X , X , X , X , X , X , X , X , X , X , X , X , X


.Code
EXTRN displayResults:NEAR

PUBLIC Graphics
PUBLIC gametimer
PUBLIC score1
PUBLIC score2
PUBLIC heart1
PUBLIC heart2

Graphics PROC
	MOV AX , @DATA
	MOV DS , AX
  
  
	MOV AH, 0
	MOV AL, 13h
	INT 10h
  
	mov stackIP , sp
	
	
	mov positionInGridFile , 0
	mov bomberx , 288
	mov bomberY , 128
    mov bomber2x , 16
	mov bomber2Y , 32
	mov score1 , 0000
	mov score2 , 0000
	mov heart1 , 10
	mov heart2 , 10
	mov gametimer , 255

	MOV originalPlaceXP1 , 288
	MOV originalPlaceYP1 , 128
	
	MOV originalPlaceXP2 , 16
	MOV originalPlaceYP2 , 32
	
	
	;call initializeGrid
	
	
	 bomb struc
		bombx dw 0
		bomby dw 0
		to_be_drawn db 0
		counter db 5
	 bomb ends
	 
	 bomb1 bomb<>
	 bomb2 bomb<>
	 
clearBlock MACRO x , y
local sketch

	pusha
	MOV CX,x
    MOV DX,y
	MOV DI,x
	MOV SI, y
	ADD DI , 16
	ADD SI , 16
    MOV AH,0ch
	
	
; Drawing loop
sketch:
    MOV AL,02h
    INT 10h 
    INC CX
    CMP CX,DI
JNE sketch 
	
    MOV CX , x
    INC DX
    CMP DX , SI
JNE sketch
	popa
ENDM clearBlock

updategrid macro objectx,objecty,object
			
			
			pusha 
			mov ax , objecty
			mov bx , objectx
			call find1Darray 
			mov al,object
			mov  DS:[BP][di],al
			popa
			
			

endm updategrid	


ClearBuffer MACRO
LOCAL clear , endClear
PUSH AX
    clear:
      MOV AH ,1
      INT 16h
      JZ endClear
      MOV AH,0
      INT 16h
      CMP AX , 0          
      JMP clear
    endCLear:
POP AX
ENDM ClearBuffer


drawpic macro x,y,imageData
PUSHA
	
	mov si,x
	mov bp,x
	MOV BP_Temp , BP
	mov di,y
    MOV CX,x ; x1
    MOV DX,y ; y1
	LEA BP , imageData ; BP contains index at the current drawn pixel
    call drawpixel 

POPA
endm drawpic 



checkTypeAndDraw MACRO x1 , y1 , type1,bombtype
local _finish , _label_G , _label_P1 , _label_P2 , _label_P , _label_C , _label_H , _label_skip_heart1 , _label_skip_heart2 , __label_skip_heart1 , __label_skip_heart2
local increase_score1,increase_score2,decrease_score1,decrease_score2,bombtype,_label_print_heart1,_label_print_heart2 , __label_print_heart1,__label_print_heart2

pusha

	CMP type1 , G  
	JE _label_G 
	
	CMP type1 , P  
	JE _label_P 
	
	CMP type1 , H  
	JE _label_H 
	
	CMP type1 , P1
	JE _label_P1
	
	CMP type1 , P2 
	JE _label_P2
	
	CMP type1 , C  
	JE _label_C 
	
	_label_G:  
	clearBlock x1 , y1
	JMP _finish
	
	
	_label_P:  
	drawpic x1 , y1 , PowerUpData
	JMP _finish

	_label_C: 
	drawpic x1 , y1 , coinData
	JMP _finish
	
	_label_H:
	drawpic x1 , y1 , HPData
	JMP _finish
	
	
	_label_P1: 
	clearBlock x1 , y1
	
	
	push ax
	mov ax ,originalPlaceXP1
	mov bomberx ,ax
	mov ax ,originalPlaceYP1
	mov bombery , ax
	pop ax
	
	
	
	drawpic bomberx , bombery , bomerData
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;nn
	
	mov cx , bombtype
	cmp cx,1
	je decrease_score1
	mov cx , bombtype
	cmp cx,2
	je increase_score1
	decrease_score1:
	dec heart1
	CMP originalPlaceXP1 , 288
	JE _label_print_heart2
	writeheart2 heart1
	JMP _label_skip_heart2
	
	_label_print_heart2:
	writeheart1 heart1
	
	_label_skip_heart2:
	cmp heart1,0
	je exit
	cmp score1 , 0
	je _finish
	mov cx , 200
	 sub score1,cx
	 writescore1 score1
	 
	 jmp _finish
	 increase_score1:
	dec heart1
	CMP originalPlaceXP1 , 288
	JE __label_print_heart2
	writeheart2 heart1
	JMP __label_skip_heart2
	
	__label_print_heart2:
	writeheart1 heart1
	
	__label_skip_heart2:
	 cmp heart1,0
	je exit
	 mov cx , 200
	 add score2,cx
	 writescore2 score2
	
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;nn
	
	JMP _finish
	
	_label_P2: 
	clearBlock x1 , y1
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;N
	push ax
	mov ax ,originalPlaceXP2
	mov bomber2x ,ax
	mov ax ,originalPlaceYP2
	mov bomber2y , ax
	pop ax
	
	drawpic bomber2x , bomber2y , bomerData

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;N
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;nn
	mov cx , bombtype
	cmp cx , 2
	je decrease_score2
	mov cx , bombtype
	cmp cx , 1
	je increase_score2
	decrease_score2:
	 
	dec heart2
	CMP originalPlaceXP2 , 16
	JE _label_print_heart1
	writeheart1 heart2
	JMP _label_skip_heart1
	
	_label_print_heart1:
	writeheart2 heart2
	
	_label_skip_heart1:
	cmp heart2,0
	 
	 je exit
	cmp score2 ,0

	je _finish
	mov cx , 200
	 sub score2,cx
	writescore2 score2
	 
	 jmp _finish
	 increase_score2:
	    dec heart2
	 	CMP originalPlaceXP2 , 16
	JE __label_print_heart1
	writeheart1 heart2
	JMP __label_skip_heart1
	
	__label_print_heart1:
	writeheart2 heart2
	
	__label_skip_heart1:
	 cmp heart2,0
	 
	je exit
	 mov cx , 200
	 add score1,cx
	 writescore1 score1
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;nn
	
	
	
_finish:popa 

ENDM checkTypeAndDraw




checkBlock MACRO x_1 , y_1,bombtype
local __finish



call find1Darray


mov cl , DS:[BP][DI]

cmp cl , X
je __finish

shl cl , 1
shr cl , 1
shr cl , 1
shl cl , 1


updategrid x_1 , y_1 , cl 



checkTypeAndDraw x_1 ,y_1, cl,bombtype

__finish:
ENDM checkBlock

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;start of the program;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


call loadimages


	;;;;;;;;;;;;;;load and draw grid;;;;;;;;;;;;;;;;
	callOpenFile gridFilename,gridFilehandle
	
	
	LEA BX , gridData ; BL contains index at the current drawn pixel
	
	MOV CX,0 ; x1
	MOV DX,16 ; y1
	MOV AH,0ch
		
; Drawing loop
drawLoop:

	pusha
	;JUMP TO POSITION INSIDE THE FILE.                            <==============
	mov  ah, 42h          	;SERVICE FOR SEEK.
	mov  al, 0            	;START FROM THE BEGINNING OF FILE.
	mov  bx, gridFilehandle  	;FILE.
	mov  cx, 0            	;THE FILE POSITION MUST BE PLACED IN
	mov  dx, positionInGridFile   ;CX:DX, EXAMPLE, TO JUMP TO POSITION
	int  21h

	;READ ONE CHAR FROM CURRENT FILE POSITION.
	mov  ah, 3fh          ;SERVICE TO READ FROM FILE.
	mov  bx, gridFilehandle
	mov  cx, 1            ;HOW MANY BYTES TO READ.
	inc positionInGridFile
	lea  dx, gridData       ;WHERE TO STORE THE READ BYTES.  
	int  21h
		
	popa
		
	MOV AL,[BX]
	INT 10h 
	INC CX
	CMP CX,320 
JNE drawLoop 



	MOV CX , 0
	INC DX
	CMP DX , 160
JNE drawLoop
	
	
	callCloseFile gridFilehandle
	

;;;;;;;;;;;;;;;;;;;;;;;draw pomerman;;;;;;;;;;;;;;;;;;;;;;;;

	CALL initializeUART


initilizationLoop:
	
    CALL checkReceived
    CMP AL , 0
    JE send1

    CALL receiveChar
    CMP KeyValue , ExitRecieving
	JE swap
	
	CMP KeyValue , ExitSending
	JE end_initializeLoop


swap:
	MOV AX , bomberx
	MOV BX , bomber2X
	
	MOV bomber2X , AX
	MOV bomberx , BX
	
	MOV AX , bombery
	MOV BX , bomber2y
	
	MOV bomber2y , AX
	MOV bombery , BX
	

	MOV originalPlaceXP1 , 16
	MOV originalPlaceXP2 , 288
	
	MOV originalPlaceYP1 , 32
	MOV originalPlaceYP2 , 128
	
	MOV KeyValue , ExitSending
	JMP send
	
send1:
	MOV KeyValue , ExitRecieving

send:

    CALL sendChar

CMP KeyValue , ExitSending
JNE initilizationLoop

end_initializeLoop:

	drawpic bomberx,bomberY,bomerData
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;N
	drawpic bomber2x,bomber2Y,bomerData
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;N
	drawpic 96 , 0 , heartData
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;N
	drawpic 288 , 0 , heartData
	

	
	
    writescore1 score1
	writescore2 score2
	writeheart1 heart1
	writeheart2 heart2
	

	LEA bp , grid	
___label:
	
	
	GetCurrentTime time
	mov al,time
	
	cmp al , last_time
	je temptime
	
	printTime
	
	dec gametimer
	
	CMP gametimer , 0
	je exit
	
temptime:
	
	cmp al,last_time
	je wait_for_bomb
	inc bomb1.counter
	
	;;;;;;;;;;;;;;;;;;;;;n
	GetCurrentTime time
	mov al,time
	cmp al,last_time
	je wait_for_bomb2
	inc bomb2.counter
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;n
	wait_for_bomb:
	mov last_time,al
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;n
	wait_for_bomb2:
	mov last_time,al
	;;;;;;;;;;;;;;;;;;;;;;n
	call checkkeypressed
	call checkkeypressed2
	ClearBuffer
	
	cmp bomb1.counter , 2
	je explode 
	
	;;;;;;;;;;;;;;;;;;;;;nn
	cmp bomb2.counter , 2
	je explode2 
	;;;;;;;;;;;;;;;;;;;;;nn
	
	jmp ___label
	
explode:
	call BOOMmusic
	mov bomb1.counter , 5 ; 5 is any arbitrary value above 3 
	mov ax , bomb1.bomby
	mov bx , bomb1.bombx
	mov bomb1.to_be_drawn , 0
	

	
	
	push bx
	push ax

	;--------------------------------------------
	
	
	updategrid bomb1.bombx , bomb1.bomby , G

	clearBlock bomb1.bombx , bomb1.bomby
;------------------------------

;------------------------------
	pop ax
	pop bx
	
	cmp bomb1_level,2
	JNE Level1_boom_p1
	
	PUSH BX
	ADD BX , 32

	checkBlock BX , AX,1
	SUB BX , 64
	checkBlock BX , AX,1
	
	POP BX
	Push Ax
	
	ADD AX , 32
	checkBlock BX , AX,1
	SUB AX , 64
	checkBlock BX , AX,1
	
	pop ax
	
Level1_boom_p1:	
	PUSH BX
	ADD BX , 16

	checkBlock BX , AX,1
	SUB BX , 32
	checkBlock BX , AX,1
	
	POP BX
	
	ADD AX , 16
	checkBlock BX , AX,1
	SUB AX , 32
	checkBlock BX , AX,1
	
	jmp ___label
	
explode2:
  
      
	call BOOMmusic
	mov bomb2.counter , 5 ; 5 is any arbitrary value above 3 
	mov ax , bomb2.bomby
	mov bx , bomb2.bombx
	mov bomb2.to_be_drawn , 0
	
	push bx
	push ax
	
	;--------------------------------------------
	
	
	
	updategrid bomb2.bombx , bomb2.bomby , G

	clearBlock bomb2.bombx , bomb2.bomby
;------------------------------

;------------------------------
	pop ax
	pop bx
	
	cmp bomb2_level,2
	JNE level1_bomb_p2
	
	PUSH BX
	ADD BX , 32

	checkBlock BX , AX,2
	SUB BX , 64
	checkBlock BX , AX,2
	
	POP BX
	push ax 
	
	ADD AX , 32
	checkBlock BX , AX,2
	SUB AX , 64
	checkBlock BX , AX,2
	
	pop ax

level1_bomb_p2:	
	
	PUSH BX
	ADD BX , 16

	checkBlock BX , AX,2
	SUB BX , 32
	checkBlock BX , AX,2
	
	POP BX
	
	ADD AX , 16
	checkBlock BX , AX,2
	SUB AX , 32
	checkBlock BX , AX,2
	
	
	
	
	jmp ___label
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; return and exit
exit:
	call music
	call displayResults
	
	mov sp , stackIP

	RET
Graphics ENDP


drawpixel proc
	MOV AH,0ch
	add si,16
	add di,16
	MOV BX , 0
; Drawing loop
	drawLoop1:

	MOV AL,DS:[BP]
	INT 10h 
	INC CX
	INC BP
	CMP CX,si 
JNE drawLoop1 
	
	MOV CX , BP_Temp
	INC DX
	CMP DX , di
JNE drawLoop1

  RET
drawpixel endp



checkkeypressed PROC 
            mov ah , 1 ;ZF set if no keystroke available
            int 16h    ;ZF clear if keystroke available
			JZ temp3
			
			
            cmp ah , 72
            jz isup
            cmp ah , 80
            jz isdown
            cmp ah , 77
            jz tempright
            cmp ah , 75
            jz temp2
            cmp ah , 57
			jz space
			cmp ah, F4Scancode
			jz tempexit1
			mov ah , 1
            int 16h
			JZ temp3
			MOV KeyValue , 0
			CALL sendChar
			CALL inlineChat
			jmp temp3
                
isup:			

			Mov KeyValue,17                         ;send W
			CALL sendChar
			mov ax , bomberY
			mov y_old , ax
			
			mov ax , bomberY
			mov bx , bomberX
			sub ax , 16
			call find1Darray 
			mov dl , DS:[BP][di]
			shl dl ,1      ;shift to check if it's a block or brick
			jc temp3    ;don't draw
			
			sub bomberY , 16
			
			shr dl , 1
			CMP dl , C
			JNE _label_increment_score1_up
			ADD score1 , 100
			_label_increment_score1_up:
			
			CMP dl , H
			JNE _label_increment_Heart1_up
			ADD heart1 , 1
			_label_increment_Heart1_up:
			
			CMP dl , P
			JNE _label_bomb1_powerup_up
			mov bomb1_level,2
			_label_bomb1_powerup_up:
			
			
			cmp bomb1.to_be_drawn,1
			jne nodraw
			drawpic bomb1.bombx , bomb1.bomby , bombData
			mov bomb1.to_be_drawn ,0
	
			drawpic bomberx,bomberY,bomerData
			updategrid bomberx , bomberY , p1
			jmp finish
			
nodraw:
			clearblock bomberX , y_old
			updategrid bomberX , y_old , G
			
			drawpic bomberx,bomberY,bomerData
			updategrid bomberx , bomberY , p1
			
temp3:
			jmp finish
temp2: 		jmp temp
tempright:  jmp isright
isdown:

			Mov KeyValue,31                         ;send s
			CALL sendChar
			mov ax , bomberY
			mov y_old , ax
			
			mov ax , bomberY
			mov bx , bomberX
			add ax , 16
			call find1Darray
			mov dl , DS:[BP][di]
			shl dl,1
			jc temp4
			
			add bomberY , 16
			
			shr dl , 1
			CMP dl , C
			JNE _label_increment_score1_down
			ADD score1 , 100
			_label_increment_score1_down:
			
			CMP dl , H
			JNE _label_increment_Heart1_down
			ADD heart1 , 1
			_label_increment_Heart1_down:
			
			CMP dl , P
			JNE _label_bomb1_powerup_down
			mov bomb1_level,2
			_label_bomb1_powerup_down:
			
			cmp bomb1.to_be_drawn,1
			jne nodraw1
			drawpic bomb1.bombx , bomb1.bomby , bombData
			mov bomb1.to_be_drawn ,0
			
			drawpic bomberx,bomberY,bomerData
			updategrid bomberx , bomberY , p1
			jmp finish
nodraw1:
			
			clearblock bomberX , y_old
			updategrid bomberX , y_old , G
			
			drawpic bomberx,bomberY,bomerData
			updategrid bomberx , bomberY , p1
temp4:
			jmp finish
tempfinish1:jmp tempfinish2
temp: 		jmp isleft
isright:

			Mov KeyValue,32                         ;send D
			CALL sendChar
			mov ax , bomberX
			mov y_old , ax
			
			mov ax , bomberY
			mov bx , bomberX
			add bx , 16
			call find1Darray
			mov dl , DS:[BP][di]
			shl dl,1
			jc temp5
			add bomberX , 16
			
			shr dl , 1
			CMP dl , C
			JNE _label_increment_score1_right
			ADD score1 , 100
			_label_increment_score1_right:
			
			CMP dl , H
			JNE _label_increment_Heart1_right
			ADD heart1 , 1
			_label_increment_Heart1_right:
			
			CMP dl , P
			JNE _label_bomb1_powerup_right
			mov bomb1_level,2
			_label_bomb1_powerup_right:
			
			cmp bomb1.to_be_drawn,1
			jne nodraw3
			drawpic bomb1.bombx , bomb1.bomby , bombData
			mov bomb1.to_be_drawn ,0
			
			drawpic bomberx,bomberY,bomerData
			updategrid bomberx , bomberY , p1
			jmp finish
nodraw3:
			
		
			clearblock y_old , bomberY
			updategrid y_old , bomberY , G
			
			drawpic bomberx,bomberY,bomerData
			updategrid bomberx , bomberY , p1
temp5:			
			jmp finish
tempfinish2:jmp finish
isleft: 

			Mov KeyValue,30                         ;send A
			CALL sendChar
			mov ax , bomberX
			mov y_old , ax
			
			mov ax , bomberY
			mov bx , bomberX
			sub bx , 16
			call find1Darray
			mov dl , DS:[BP][di]
			shl dl,1
			jc finish
			sub bomberX , 16
			
			shr dl , 1
			CMP dl , C
			JNE _label_increment_score1_left
			ADD score1 , 100
			_label_increment_score1_left:
			
			CMP dl , H
			JNE _label_increment_Heart1_left
			ADD heart1 , 1
			_label_increment_Heart1_left:
			
			CMP dl , P
			JNE _label_bomb1_powerup_left
			mov bomb1_level,2
			_label_bomb1_powerup_left:
			
			cmp bomb1.to_be_drawn,1
			jne nodraw4
			drawpic bomb1.bombx , bomb1.bomby , bombData
			mov bomb1.to_be_drawn ,0
			
			drawpic bomberx,bomberY,bomerData
			updategrid bomberx , bomberY , p1
			jmp finish
tempexit1:
			MOV KeyValue , F4Scancode
			CALL sendChar
			jmp exit					
nodraw4:
			
			
			clearblock y_old , bomberY
			updategrid y_old , bomberY ,G
			
			drawpic bomberx,bomberY,bomerData
			updategrid bomberx , bomberY , p1
			jmp finish
space:			
			
			Mov KeyValue,15                         ;send tap
			CALL sendChar
			cmp bomb1.counter,2
			jb finish
			
            mov ax, bomberx
			mov bomb1.bombx , ax
			mov ax, bombery
			mov bomb1.bomby , ax
			mov bomb1.to_be_drawn , 1
			mov bomb1.counter , 0
		
			updategrid bomberX , bomberY , B1
			
			
			
			
			
finish:            
			RET
checkkeypressed ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;N
checkkeypressed2 PROC 
            CALL checkReceived
			CMP AL , 0
			JE temp2_23_2

			CALL receiveChar
			mov ah,KeyValue
			
            cmp ah , 17
            jz isup2
            cmp ah , 31
            jz isdown2
            cmp ah , 32
            jz temp2_2right2
            cmp ah , 30
            jz temp2_22_2
            cmp ah , 15
			jz tab
			cmp ah, F4Scancode
			jz tempexit2
			CMP AH , 0
			JNE temp2_2finish21_2
			CALL inlineChat
            jmp temp2_2finish21_2
                
isup2:
			mov ax , bomber2Y
			mov y_old , ax
			
			mov ax , bomber2Y
			mov bx , bomber2X
			sub ax , 16
			call find1Darray 
			mov dl , DS:[BP][di]
			shl dl ,1      ;shift to check if it's a block or brick
			jc temp2_23_2    ;don't draw
			
			sub bomber2Y , 16
			
			shr dl , 1
			CMP dl , C
			JNE _label_increment_score2_up
			ADD score2 , 100
			_label_increment_score2_up:
			
			CMP dl , H
			JNE _label_increment_Heart2_up
			ADD heart2 , 1
			_label_increment_Heart2_up:
			
			CMP dl , P
			JNE _label_bomb2_powerup_up
			mov bomb2_level,2
			_label_bomb2_powerup_up:
			
			cmp bomb2.to_be_drawn,1
			jne nodraw2
			drawpic bomb2.bombx , bomb2.bomby , bombData
			mov bomb2.to_be_drawn ,0
	
			drawpic bomber2X,bomber2Y,bomerData
			updategrid bomber2X , bomber2Y , p2
			jmp finish2
			
nodraw2:
			clearblock bomber2X , y_old
			updategrid bomber2X , y_old , G
			
			drawpic bomber2X,bomber2Y,bomerData
			updategrid bomber2X , bomber2Y , p2
			
temp2_23_2:
			jmp finish2
temp2_22_2: 		jmp temp2_2
temp2_2right2:  jmp isright2
isdown2:
			mov ax , bomber2Y
			mov y_old , ax
			
			mov ax , bomber2Y
			mov bx , bomber2X
			add ax , 16
			call find1Darray
			mov dl , DS:[BP][di]
			shl dl,1
			jc temp2_24_2
			
			add bomber2Y , 16
			
			shr dl , 1
			CMP dl , C
			JNE _label_increment_score2_down
			ADD score2 , 100
			_label_increment_score2_down:
			
			CMP dl , H
			JNE _label_increment_Heart2_down
			ADD heart2 , 1
			_label_increment_Heart2_down:
			
			CMP dl , P
			JNE _label_bomb2_powerup_down
			mov bomb2_level,2
			_label_bomb2_powerup_down:
			
			cmp bomb2.to_be_drawn,1
			jne nodraw21_2
			drawpic bomb2.bombx , bomb2.bomby , bombData
			mov bomb2.to_be_drawn ,0
			
			drawpic bomber2X,bomber2Y,bomerData
			updategrid bomber2X , bomber2Y , p2
			jmp finish2
nodraw21_2:
			
			clearblock bomber2X , y_old
			updategrid bomber2X , y_old , G
			
			drawpic bomber2X,bomber2Y,bomerData
			updategrid bomber2X , bomber2Y , p2
temp2_24_2:
			jmp finish2
temp2_2finish21_2:jmp temp2_2finish22_2
temp2_2: 		jmp isleft2
isright2:
			mov ax , bomber2X
			mov y_old , ax
			
			mov ax , bomber2Y
			mov bx , bomber2X
			add bx , 16
			call find1Darray
			mov dl , DS:[BP][di]
			shl dl,1
			jc temp2_25_2
			add bomber2X , 16
			
			shr dl , 1
			CMP dl , C
			JNE _label_increment_score2_right
			ADD score2 , 100
			_label_increment_score2_right:
			
			CMP dl , H
			JNE _label_increment_Heart2_right
			ADD heart2 , 1
			_label_increment_Heart2_right:
			
			CMP dl , P
			JNE _label_bomb2_powerup_right
			mov bomb2_level,2
			_label_bomb2_powerup_right:
			
			cmp bomb2.to_be_drawn,1
			jne nodraw23_2
			drawpic bomb2.bombx , bomb2.bomby , bombData
			mov bomb2.to_be_drawn ,0
			
			drawpic bomber2X,bomber2Y,bomerData
			updategrid bomber2X , bomber2Y , p2
			jmp finish2
nodraw23_2:
			
		
			clearblock y_old , bomber2Y
			updategrid y_old , bomber2Y , G
			
			drawpic bomber2X,bomber2Y,bomerData
			updategrid bomber2X , bomber2Y , p2
temp2_25_2:			
			jmp finish2
temp2_2finish22_2:jmp finish2
isleft2: 
			mov ax , bomber2X
			mov y_old , ax
			
			mov ax , bomber2Y
			mov bx , bomber2X
			sub bx , 16
			call find1Darray
			mov dl , DS:[BP][di]
			shl dl,1
			jc finish2
			sub bomber2X , 16
			
			shr dl , 1
			CMP dl , C
			JNE _label_increment_score2_left
			ADD score2 , 100
			_label_increment_score2_left:
			
			CMP dl , H
			JNE _label_increment_Heart2_left
			ADD heart2 , 1
			_label_increment_Heart2_left:
			
			CMP dl , P
			JNE _label_bomb2_powerup_left
			mov bomb2_level,2
			_label_bomb2_powerup_left:
			
			cmp bomb2.to_be_drawn,1
			jne nodraw24_2
			drawpic bomb2.bombx , bomb2.bomby , bombData
			mov bomb2.to_be_drawn ,0
			
			drawpic bomber2X,bomber2Y,bomerData
			updategrid bomber2X , bomber2Y , p2
			jmp finish2
tempexit2:jmp exit			
nodraw24_2:
			
			
			clearblock y_old , bomber2Y
			updategrid y_old , bomber2Y ,G
			
			drawpic bomber2X,bomber2Y,bomerData
			updategrid bomber2X , bomber2Y , p2
			jmp finish2
tab:			
			
			cmp bomb2.counter,2
			jb finish2
			
            mov ax, bomber2X
			mov bomb2.bombx , ax
			mov ax, bomber2Y
			mov bomb2.bomby , ax
			mov bomb2.to_be_drawn , 1
			mov bomb2.counter , 0
		
			updategrid bomber2X , bomber2Y , B1
			
			
			
			
finish2:            
			RET
checkkeypressed2 ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;N

find1Darray PROC
            ;sub al , 16  ;Y
			push ax
			push bx
			push cx
			
            INC AX
            INC BX

			shr ax , 1
			shr ax , 1
			shr ax , 1
			shr ax , 1
			
			shr  bx , 1
			shr  bx , 1
			shr  bx , 1
			shr  bx , 1
			             
			DEC AX
			   
			             
            mov cx , 20 ; 320/16
            mul cx
            add ax , bx;bx = y

            mov di , ax
			
			pop cx
			pop bx
			pop ax
			
            RET
find1Darray ENDP


















loadimages proc
        ;;;;;;;;;;;;;;load bomb;;;;;;;;;;;;;;;;		
		callOpenFile bombFilename,bombFilehandle
		callLoadData bombFilehandle,bombData,imagewidth,imageheight
		callCloseFile bombFilehandle
        ;;;;;;;;;;;;;;load bomberman;;;;;;;;;;;;;;;;;;;;;;;;
		callOpenFile bomerFilename,bomerFilehandle
		callLoadData bomerFilehandle,bomerData,imagewidth,imageheight
		callCloseFile bomerFilehandle
		
		;;;;;;;;;;;;;;;load coin ;;;;;;;;;;;;;;;;;;;;;;;;
		callOpenFile coinFilename,coinFilehandle
		callLoadData coinFilehandle,coinData,imagewidth,imageheight
		callCloseFile coinFilehandle
		
		;;;;;;;;;;;;;;;;load heart ;;;;;;;;;;;;;;;;;;;;;;;;
		callOpenFile heartFilename,heartFilehandle
		callLoadData heartFilehandle,heartData,imagewidth,imageheight
		callCloseFile heartFilehandle
		
		;;;;;;;;;;;;;;;load coin ;;;;;;;;;;;;;;;;;;;;;;;;
		callOpenFile HPFilename,HPFilehandle
		callLoadData HPFilehandle,HPData,imagewidth,imageheight
		callCloseFile HPFilehandle
		
		;;;;;;;;;;;;;;;;load heart ;;;;;;;;;;;;;;;;;;;;;;;;
		callOpenFile PowerUpFilename,PowerUpFilehandle
		callLoadData PowerUpFilehandle,PowerUpData,imagewidth,imageheight
		callCloseFile PowerUpFilehandle
		
		ret

loadimages endp


initializeGrid proc 

	mov al , X
	lea bx , grid
	mov cx,20
fill_f:
	mov [BX] , al
	inc bx
	loop fill_f
	
	
	
	MOV [BX] , al
	INC BX
	MOV AL , G
	MOV [BX] , AL
	INC BX
	MOV [BX] , AL
	inc bx

	
	MOV CX , 16
	CALL fillBricks

	
	MOV AL , X
	MOV [BX] , AL
	INC BX
	
	call fillLine2
	
	
	MOV AL , X
	MOV [BX] , AL
	INC BX
	
	MOV CX , 18
	CALL fillBricks
	
	
	MOV AL , X
	MOV [BX] , AL
	INC BX
	
	call fillLine2
	
	
		
	MOV AL , X
	MOV [BX] , AL
	INC BX
	
	MOV CX , 18
	CALL fillBricks
	
	
	MOV AL , X
	MOV [BX] , AL
	INC BX
	
	
	call fillLine2
	
	
		
	MOV AL , X
	MOV [BX] , AL
	INC BX
	
	MOV CX , 16
	CALL fillBricks
	
	
	MOV AL , G
	MOV [BX] , AL
	INC BX
	
	MOV AL , G
	MOV [BX] , AL
	INC BX
	
	MOV AL , X
	MOV [BX] , AL
	INC BX
	
	lea bx , grid
	add bx,160
	mov cx,19
fill_l:
	mov [BX] , al
	inc bx
	loop fill_l
	 
	RET
initializeGrid endp


; START FROM bX FOR CX TIMES
fillBricks PROC

MOV AL , B

fillBrick:
	mov [BX] , al
	inc BX
	LOOP fillBrick

RET
fillBricks ENDP

; start from bx for 20 times
fillLine2 PROC

MOV AL , X
MOV [BX] , AL
INC BX
MOV AL , G
MOV [BX] , AL
INC BX
MOV AL , X
MOV [BX] , AL
INC BX
MOV AL , B
MOV [BX] , AL
INC BX
MOV AL , X
MOV [BX] , AL
INC BX
MOV AL , G
MOV [BX] , AL
INC BX
MOV AL , X
MOV [BX] , AL
INC BX
MOV AL , B
MOV [BX] , AL
INC BX
MOV AL , X
MOV [BX] , AL
INC BX
MOV AL , G
MOV [BX] , AL
INC BX
MOV AL , G
MOV [BX] , AL
INC BX
MOV AL , X
MOV [BX] , AL
INC BX
MOV AL , B
MOV [BX] , AL
INC BX
MOV AL , X
MOV [BX] , AL
INC BX
MOV AL , G
MOV [BX] , AL 
inc bx
MOV AL , X
MOV [BX] , AL
INC BX
MOV AL , B
MOV [BX] , AL
INC BX
MOV AL , X
MOV [BX] , AL
INC BX
MOV AL , G
MOV [BX] , AL
INC BX
MOV AL , X
MOV [BX] , AL
INC BX

RET
fillLine2 ENDP





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;N
music proc near 
pusha
mov     al, 182         ; Prepare the speaker for the
        out     43h, al         ;  note.
        mov     ax, 4560        ; Frequency number (in decimal)
                                ;  for middle C.
        out     42h, al         ; Output low byte.
        mov     al, ah          ; Output high byte.
        out     42h, al 
        in      al, 61h         ; Turn on note (get value from
                                ;  port 61h).
        or      al, 00000011b   ; Set bits 1 and 0.
        out     61h, al         ; Send new value.
        mov     bx, 25          ; Pause for duration of note.
.pause1:
        mov     cx, 65535
.pause2:
        dec     cx
        jne     .pause2
        dec     bx
        jne     .pause1
        in      al, 61h         ; Turn off note (get value from
                                ;  port 61h).
        and     al, 11111100b   ; Reset bits 1 and 0.
        out     61h, al
		popa
ret
music endp 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;N

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;NN
BOOMmusic proc NEAR
push ax
push bx
push cx
push dx
sound :     

MOV     DX,2000          ; Number of times to repeat whole routine.

MOV     BX,1             ; Frequency value.

MOV     AL, 10110110B    ; The Magic Number (use this binary number only)
OUT     43H, AL          ; Send it to the initializing port 43H Timer 2.

NEXT_FREQUENCY:          ; This is were we will jump back to 2000 times.

MOV     AX, BX           ; Move our Frequency value into AX.

OUT     42H, AL          ; Send LSB to port 42H.
MOV     AL, AH           ; Move MSB into AL  
OUT     42H, AL          ; Send MSB to port 42H.

IN      AL, 61H          ; Get current value of port 61H.
OR      AL, 00000011B    ; OR AL to this value, forcing first two bits high.
OUT     61H, AL          ; Copy it to port 61H of the PPI Chip
                         ; to turn ON the speaker.

MOV     CX, 100          ; Repeat loop 100 times
DELAY_LOOP:              ; Here is where we loop back too.
LOOP    DELAY_LOOP       ; Jump repeatedly to DELAY_LOOP until CX = 0


INC     BX               ; Incrementing the value of BX lowers 
                         ; the frequency each time we repeat the
                         ; whole routine

DEC     DX               ; Decrement repeat routine count

CMP     DX, 0            ; Is DX (repeat count) = to 0
JNZ     NEXT_FREQUENCY   ; If not jump to NEXT_FREQUENCY
                         ; and do whole routine again.

                         ; Else DX = 0 time to turn speaker OFF

IN      AL,61H           ; Get current value of port 61H.
AND     AL,11111100B     ; AND AL to this value, forcing first two bits low.
OUT     61H,AL           ; Copy it to port 61H of the PPI Chip
                         ; to
pop dx
pop cx
pop bx
pop ax
ret
BOOMmusic endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;NN


inlineChat PROC

MOV windowOneStartX , 0
MOV windowOneEndX , 18
MOV windowOneStartY , 20
MOV windowOneEndY , 24
MOV WindowOneColor , 0

MOV windowTwoStartX , 21
MOV windowTwoEndX , 39
MOV windowTwoStartY , 20
MOV windowTwoEndY , 24
MOV WindowTwoColor , 0

callDrawColumnUp 02 , 12 , 154 , 160 , 200 

CALL Chat

RET
inlineChat ENDP


END