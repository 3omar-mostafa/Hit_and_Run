.Model COMPACT
.Stack 64
.Data
include inout.inc


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

bomerx EQU 16
bomerY EQU 32

X EQU 'X'
B EQU 1
G EQU 0
P EQU 'P'
Q EQU 'Q'
B1 EQU 5
B2 EQU 6
C EQU 7
H EQU 8

C_B EQU C or B
H_B EQU C or B

;  	 0 	  1	   2 	    3		 4 	    5 	   6 	    7 	   8 	    9 	 10 	  11 	   12 	  13		 14		  15		 16		  17		 18   19
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


;;;;;;;;;;;;;;;;;;;;;;draw pomerman;;;;;;;;;;;;;;;;;;;;;;;;
  callOpenFile bomerFilename,bomerFilehandle
	callLoadData bomerFilehandle,bomerData,bomerWidth,bomerHeight
	callCloseFile bomerFilehandle

	drawpic bomerx,bomery,bomerData

	
	;LEA BX , bomerData ; BL contains index at the current drawn pixel
	;
  ;MOV CX,bomerx ; x1
  ;MOV DX,bomery ; y1
  ;MOV AH,0ch
	;
	;
; Drawing loop
;drawLoop1:
;
;  MOV AL,[BX]
;  INT 10h 
;  INC CX
;  INC BX
;  CMP CX,16+bomerx 
;JNE drawLoop1 
;	
;  MOV CX , bomerx
;  INC DX
;  CMP DX , 16+bomerx
;JNE drawLoop1
;
;


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



END MAIN


