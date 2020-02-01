; This file contains MACROs fo preparing parameters and CALL the real Procedures in draw.asm
; These MACROs should be called instead of the Procedures in draw.asm

; THese procedures are external
; MUST be declared at another assembly file with same name,type
; so that the linker join them

EXTRN drawColumnUp:NEAR
EXTRN drawColumnDown:NEAR
EXTRN drawRowLeft:NEAR
EXTRN drawRowRight:NEAR


; Draw Vertical Line from top to bottom with small speed to show effect of drawing
; @inputs: color -> 8 bits drawing color
;          draw from ( x1 , y1 ) to ( x1+lineWidth , y2 )
;          x1 , y1 , y2 are 16 bits
;          Assumed y2 > y1
callDrawColumnUp MACRO color , lineWidth , x1 , y1 , y2

	PUSHA
	
	MOV SI , x1
	MOV DI , y2
	
	MOV BX , lineWidth

	MOV CX , x1
	MOV DX , y1
	MOV AL , color
	
	CALL drawColumnUp
	
	POPA
ENDM callDrawColumnUp





; Draw Vertical Line from bottom to top with small speed to show effect of drawing
; @inputs: color -> 8 bits drawing color
;          draw from ( x1+lineWidth , y2 ) to  ( x1 , y1 )
;          x1 , y1 , y2 are 16 bits
;          Assumed y2 > y1
callDrawColumnDown MACRO color , lineWidth , x1 , y1 , y2

	PUSHA
	
	MOV SI , x1
	MOV DI , y1
	
	MOV BX , lineWidth
	
	MOV CX , x1
	MOV DX , y2
	MOV AL , color
	
	CALL drawColumnDown
	
	POPA
ENDM callDrawColumnDown





; Draw Horizontal Line from Left to Right with small speed to show effect of drawing
; @inputs: color -> 8 bits drawing color
;          draw from ( x1 , y1 ) to ( x2 , y1+lineWidth )
;          x1 , y1 , x2 are 16 bits
;          Assumed x2 > x1
callDrawRowLeft MACRO color , lineWidth , x1 , y1 , x2

	PUSHA
	
	MOV SI  ,  x2
	MOV DI  ,  y1
	
	MOV BX , lineWidth
	
	MOV CX , x1
	MOV DX , y1
	MOV AL , color
	
	CALL drawRowLeft

	POPA
ENDM callDrawRowLeft





; Draw Horizontal Line from Right to Left with small speed to show effect of drawing
; @inputs: color -> 8 bits drawing color
;          draw from ( x2 , y1+lineWidth ) to ( x1 , y1 )
;          x1 , y1 , x2 are 16 bits
;          Assumed x2 > x1
callDrawRowRight MACRO color , lineWidth , x1 , y1 , x2

	PUSHA
	

	MOV SI , x1
	MOV DI  , y1
	
	MOV BX , lineWidth
	
	MOV CX , x2
	MOV DX , y1
	MOV AL , color
	
	CALL drawRowRight

	POPA
ENDM callDrawRowRight
