.Model COMPACT
.386
.Stack 64
.Data
include inout.inc

y_old DW ?
gridWidth EQU 320
gridHeight EQU 144

gridFilename DB 'grid.img', 0
gridFilehandle DW ?
gridData DB gridWidth*gridHeight dup(2)

bomerWidth EQU 16
bomerHeight EQU 16


bomerFilename DB 'bomer.img', 0
bomerFilehandle DW ?
bomerData DB bomerWidth*bomerHeight dup(2)

bomberx DW 16
bomberY DW 32

bombFilename DB 'bomb.img', 0
bombFilehandle DW ?
bombData DB bomerWidth*bomerHeight dup(2)



; set bit in Most signeficant bit refers to block (forbidden movement)
X EQU 10000000b ;128
B EQU 10000001b ;129
G EQU 0
P EQU 'P'
Q EQU 'Q'
B1 EQU 5
B2 EQU 6
C EQU 7
H EQU 8

C_B EQU C or B
H_B EQU C or B

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



MAIN PROC FAR
  MOV AX , @DATA
  MOV DS , AX
  
  MOV AH, 0
  MOV AL, 13h
  INT 10h
	
	 bomb struc
		bombx dw 0
		bomby dw 0
		to_be_drawn db 0
		start_time db ?
	 bomb ends
	 
	 bomb1 bomb<>
	 bomb2 bomb<>
	 
	clearBlock MACRO x , y
local sketch

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

ENDM clearBlock


	
drawpic macro x,y,imageData

LEA BX , imageData ; BL contains index at the current drawn pixel
	
	push si
	push di
	push bp
	mov si ,x
	mov bp ,x
	mov di,y
  MOV CX,x ; x1
  MOV DX,y ; y1
	call drawpixel 
  pop bp
	pop di
  pop si
endm drawpic 


  callOpenFile gridFilename,gridFilehandle
	callLoadData gridFilehandle,gridData,gridWidth,gridHeight
	callCloseFile gridFilehandle
	
	MOV AH,0ch
	MOV CX , 0
	MOV DX , 0

	
	LEA BX , gridData ; BL contains index at the current drawn pixel
	
  MOV CX,0 ; x1
  MOV DX,16 ; y1
  MOV AH,0ch
	
	
; Drawing loop
drawLoop:

  MOV AL,[BX]
  INT 10h 
  INC CX
  INC BX
  CMP CX,320 
JNE drawLoop 
	
  MOV CX , 0
  INC DX
  CMP DX , 160
JNE drawLoop

callOpenFile bombFilename,bombFilehandle
	callLoadData bombFilehandle,bombData,16,16
	callCloseFile bombFilehandle
;;;;;;;;;;;;;;;;;;;;;;draw pomerman;;;;;;;;;;;;;;;;;;;;;;;;
  callOpenFile bomerFilename,bomerFilehandle
	callLoadData bomerFilehandle,bomerData,bomerWidth,bomerHeight
	callCloseFile bomerFilehandle

	drawpic bomberx,bomberY,bomerData

	
	LEA bp , grid	
	___label:
	
	call checkkeypressed
	
	jmp ___label

  ; Press any key to exit
  MOV AH , 0
  INT 16h
  

  
  ;Change to Text MODE
  MOV AH,0     
  MOV AL,03h
  INT 10h 

  ; return control to operating system
  MOV AH , 4ch
  INT 21H
  
MAIN ENDP


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
            mov ah , 0
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
			mov bomb1.bombx , bomberx
			mov bomb1.bomby , bombery
			;put start time
			mov bomb1.to_be_drawn , 1
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
	nodraw:
			
			clearblock bomberX , y_old
			drawpic bomberx,bomberY,bomerData
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
	nodraw1:
			mov bomb1.to_be_drawn ,0
			clearblock bomberX , y_old
			drawpic bomberx,bomberY,bomerData
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
	nodraw3:
			
			mov bomb1.to_be_drawn ,0
			clearblock y_old , bomberY
			drawpic bomberx,bomberY,bomerData
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
	nodraw4:
			
			mov bomb1.to_be_drawn ,0
			clearblock y_old , bomberY
			drawpic bomberx,bomberY,bomerData
finish:            
			RET
checkkeypressed ENDP

find1Darray PROC
            ;sub al , 16  ;Y
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
			
            RET
find1Darray ENDP

END MAIN


