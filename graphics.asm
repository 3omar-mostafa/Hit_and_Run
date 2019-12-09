.MODEL SMALL
.STACK 2048
.386 ; sets the instruction set of 80386 prosessor



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;N
EXTRN INDATAP1:BYTE
EXTRN INDATAP2:BYTE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;N
.DATA
include inout.inc
test1 dw ?
test2 dw ?
time db ?

stackIP dw ?
	last_time db ?
	y_old DW ?
	gridWidth EQU 320
	gridHeight EQU 144
	
	gametimer db 100
	
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
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;N
    bomber2x DW 16
	bomber2Y DW 32
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;N
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;nn
	score1 dw 0000
	score2 dw 0000
	heart1 dw 3
	heart2 dw 3
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;nn
	bombFilename DB 'bomb.img', 0
	bombFilehandle DW ?
	bombData DB imagewidth*imageheight dup(2)
	
	
	coinFilename DB 'coin.img', 0
	coinFilehandle DW ?
	coinData DB imagewidth*imageheight dup(2)
	
	heartFilename DB 'heart.img', 0
	heartFilehandle DW ?
	heartData DB imagewidth*imageheight dup(2)


; set bit in Most signeficant bit refers to block (forbidden movement)
	X EQU  10000000b ; 128
	B EQU  10000001b ; 129
	G EQU  00000000b ; 0
	B1 EQU 10010000b ; 72
	B2 EQU 10100000b ; 160
	P1 EQU 00011000b ; 24
	P2 EQU 00101000b ; 40
	F  EQU 00001000b ; 8 -> powerup for bomb
	C EQU  00000010b ; 2
	H EQU  00000100b ; 4
	
	Bi db  10000001b ; 129
	
	F_B EQU F or B
	C_B EQU C or B
	H_B EQU H or B

;  	    0   1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16  17  18  19
grid DB X , X , X , X , X , X , X , X , X , X , X , X , X , X , X , X , X , X , X , X
	 DB X , G , G , B , B , B , B , B , B , B , B , B , B , B , B , B , B , B , B , X                                                                  
	 DB X , G , X , B , X , G , X , B , X , G , G , X , B , X , G , X , B , X , G , X           
	 DB X , B , B , B , B , B , B , B , B , B , B , B , B , B , B , B , B , B , B , X                                                                                       
	 DB X , G , X , B , X , G , X , B , X , G , G , X , B , X , G , X , B , X , G , X                                                                                     
	 DB X , B , B , B , B , B , B , B , B , B , B , B , B , B , B , B , B , B , B , X                                                               
	 DB X , G , X , B , X , G , X , B , X , G , G , X , B , X , G , X , B , X , G , X                                                                                    
	 DB X , B , B , B , B , B , B , B , B , B , B , B , B , B , B , B , B , G , G , X                                                                    
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
	mov heart1 , 3
	mov heart2 , 3
	mov gametimer , 100
	
	
	call initializeGrid
	
	
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
    clear:
      MOV AH ,1
      INT 16h
      JZ endClear
      MOV AH,0
      INT 16h
      CMP AX , 0          
      JMP clear
    endCLear:
ENDM ClearBuffer


drawpic macro x,y,imageData

LEA BX , imageData ; BL contains index at the current drawn pixel
	
	push si
	push di
	push bp
	mov si,x
	mov bp,x
	mov di,y
    MOV CX,x ; x1
    MOV DX,y ; y1
    call drawpixel 
    pop bp
	pop di
    pop si
endm drawpic 



checkTypeAndDraw MACRO x1 , y1 , type1,bombtype
local _finish , _label_G , _label_P1 , _label_P2 , _label_F , _label_C , _label_H,increase_score1,increase_score2,decrease_score1,decrease_score2,bombtype

pusha

	CMP type1 , G  
	JE _label_G 
	
	CMP type1 , P1
	JE _label_P1
	
	CMP type1 , P2 
	JE _label_P2
	
	CMP type1 , F  
	JE _label_F 
	
	CMP type1 , C  
	JE _label_C 
	
	CMP type1 , H  
	JE _label_H
	
	
	_label_G:  
	clearBlock x1 , y1
	JMP _finish
	
	; TODO to be completed
	_label_P1: 
	clearBlock x1 , y1
	
	mov bomberx ,288
	mov bombery , 128
	drawpic bomberx , bombery , bomerData
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;nn
	;push cx
	mov cx , bombtype
	cmp cx,1
	je decrease_score1
	mov cx , bombtype
	cmp cx,2
	je increase_score1
	decrease_score1:
	dec heart1
	writeheart1 heart1
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
	 writeheart1 heart1
	 cmp heart1,0
	je exit
	 mov cx , 200
	 add score2,cx
	 writescore2 score2
	
	;pop cx
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;nn
	;drawpic bomberx,bombery,bomerData
	JMP _finish
	
	; TODO to be completed
	_label_P2: 
	clearBlock x1 , y1
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;N
	mov bomber2x ,16
	mov bomber2y ,32
	drawpic bomber2x , bomber2y , bomerData

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;N
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;nn
	;push cx
	mov cx , bombtype
	cmp cx , 2
	je decrease_score2
	mov cx , bombtype
	cmp cx , 1
	je increase_score2
	decrease_score2:
	 
	  dec heart2
	  writeheart2 heart2
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
	 writeheart2 heart2
	 cmp heart2,0
	 
	je exit
	 mov cx , 200
	 add score1,cx
	 writescore1 score1
	
	 ;pop cx
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;nn
	
	JMP _finish
	
	_label_F:  
	;
	JMP _finish

	_label_C: 
	drawpic x1 , y1 , coinData
	JMP _finish
	
	_label_H:
	;
	JMP _finish
	
_finish:popa 

ENDM checkTypeAndDraw




checkBlock MACRO x_1 , y_1,bombtype
local __finish , _label_G , _label_P1 , _label_P2 , _label_F , _label_C , _label_H,bombtype



call find1Darray


mov cl , DS:[BP][DI]
;-----------------
;printnum cl
;	push ax
;	MOV AH , 0
;	INT 16h
;	pop ax 
;-----------------

cmp cl , X
je __finish

shl cl , 1
shr cl , 1
shr cl , 1
shl cl , 1

;-----------------
;printnum cl
;	push ax
;	mov ah,2
;	mov dl,','
;	int 21h
;	
;	
;	MOV AH , 0
;	INT 16h
;	
;	mov ah,2
;	mov dl,','
;	int 21h
;	pop ax 
;	
;-----------------


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
	
	;wait_for_bomb:
	;mov last_time,al
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
	
	mov bomb1.counter , 5 ; 5 is any arbitrary value above 3 
	mov ax , bomb1.bomby
	mov bx , bomb1.bombx
	mov bomb1.to_be_drawn , 0
	

	
	
	push bx
	push ax
	
	;call find1Darray

	;--------------------------------------------
	
	
	updategrid bomb1.bombx , bomb1.bomby , G

	clearBlock bomb1.bombx , bomb1.bomby
;------------------------------

;------------------------------
	pop ax
	pop bx
	
	
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
	
	;jmp ___label
	
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;nn	
	;ClearBuffer
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;nn	
	
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;N
;___label2:
	
	
	; GetCurrentTime time
	; mov al,time
	; cmp al,last_time
	; je wait_for_bomb2
	; inc bomb2.counter
	
	
	; wait_for_bomb2:
	; mov last_time,al
	
	
	; call checkkeypressed2
	; ClearBuffer
	
	;cmp bomb2.counter , 3
	;je explode2 
	
	jmp ___label
	;jmp ___label2
	
explode2:
  
      
	
	mov bomb2.counter , 5 ; 5 is any arbitrary value above 3 
	mov ax , bomb2.bomby
	mov bx , bomb2.bombx
	mov bomb2.to_be_drawn , 0
	
	push bx
	push ax
	
	;call find1Darray

	;--------------------------------------------
	
	
	
	updategrid bomb2.bombx , bomb2.bomby , G

	clearBlock bomb2.bombx , bomb2.bomby
;------------------------------

;------------------------------
	pop ax
	pop bx
	
	
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
	;jmp ___label2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; return and exit
exit:
	
	call displayResults
	
	mov sp , stackIP

	RET
Graphics ENDP


drawpixel proc
	MOV AH,0ch
	add si,16
	add di,16
; Drawing loop
	drawLoop1:

	MOV AL,[BX]
	INT 10h 
	INC CX
	INC BX
	CMP CX,si 
JNE drawLoop1 
	
	MOV CX , bp
	INC DX
	CMP DX , di
JNE drawLoop1

  RET
drawpixel endp



checkkeypressed PROC 
            mov ah , 1
            int 16h
			
			
			
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
            jmp tempfinish1
                
isup:
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
			
			
			cmp bomb1.to_be_drawn,1
			jne nodraw4
			drawpic bomb1.bombx , bomb1.bomby , bombData
			mov bomb1.to_be_drawn ,0
			
			drawpic bomberx,bomberY,bomerData
			updategrid bomberx , bomberY , p1
			jmp finish
tempexit1: 	jmp exit					
nodraw4:
			
			
			clearblock y_old , bomberY
			updategrid y_old , bomberY ,G
			
			drawpic bomberx,bomberY,bomerData
			updategrid bomberx , bomberY , p1
			jmp finish
space:			
			
			cmp bomb1.counter,2
			jb finish
			
            mov ax, bomberx
			mov bomb1.bombx , ax
			mov ax, bombery
			mov bomb1.bomby , ax
			;GetCurrentTime bomb1.to_be_drawn
			mov bomb1.to_be_drawn , 1
			mov bomb1.counter , 0
		
			updategrid bomberX , bomberY , B1
			;don't forget to ubdate the grid to ground
			
			
			
			
finish:            
			RET
checkkeypressed ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;N
checkkeypressed2 PROC 
            mov ah , 1
            int 16h
			
			
			
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
			;GetCurrentTime bomb1.to_be_drawn
			mov bomb2.to_be_drawn , 1
			mov bomb2.counter , 0
		
			updategrid bomber2X , bomber2Y , B1
			;don't forget to ubdate the grid to ground
			
			
			
			
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
		
		;;;;;;;;;;;;;;;;load bomb right;;;;;;;;;;;;;;;;;;;;;;;;
		;callOpenFile bombrightFilename,bombrightFilehandle
		;callLoadData bombrightFilehandle,bombrightData,imagewidth,imageheight
		;callCloseFile bombrightFilehandle
		;;;;;;;;;;;;;;;;load bomb left;;;;;;;;;;;;;;;;;;;;;;;;
		;callOpenFile bombleftFilename,bombleftFilehandle
		;callLoadData bombleftFilehandle,bombleftData,imagewidth,imageheight
		;callCloseFile bombleftFilehandle
		;;;;;;;;;;;;;;;load bomb up;;;;;;;;;;;;;;;;;;;;;;;;
		;callOpenFile bombupFilename,bombupFilehandle
		;callLoadData bombupFilehandle,bombupData,imagewidth,imageheight
		;callCloseFile bombupFilehandle
		;;;;;;;;;;;;;;;;load bomb down;;;;;;;;;;;;;;;;;;;;;;;;
		;callOpenFile bombdownFilename,bombdownFilehandle
		;callLoadData bombdownFilehandle,bombdownData,imagewidth,imageheight
		;callCloseFile bombdownFilehandle
		
		;;;;;;;;;;;;;;;load coin ;;;;;;;;;;;;;;;;;;;;;;;;
		callOpenFile coinFilename,coinFilehandle
		callLoadData coinFilehandle,coinData,imagewidth,imageheight
		callCloseFile coinFilehandle
		
		;;;;;;;;;;;;;;;;load heart ;;;;;;;;;;;;;;;;;;;;;;;;
		callOpenFile heartFilename,heartFilehandle
		callLoadData heartFilehandle,heartData,imagewidth,imageheight
		callCloseFile heartFilehandle
		
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


END