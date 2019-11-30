; This file contains MACROs fo preparing parameters and call the real PROCs in draw.asm
; These MACROs should be called insted of the PROCs in draw.asm

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
	
    MOV BX , x1
    ADD BX , lineWidth ; BX contains x2 ( x1+lineWidth )
    
    ; Parameters for INT 10h (draw pixel interrupt)
    MOV CX , x1
    MOV DX , y1
    MOV AL , color
    MOV AH , 0ch
    
    CALL drawColumnUp
	
    POPA	
ENDM callDrawColumnUp





; Draw Vertical Line from bottom to top with small speed to show effect of drawing
; @inputs: color -> 8 bits drawing color
;          draw drom ( x1+lineWidth , y2 ) to  ( x1 , y1 )
;          x1 , y1 , y2 are 16 bits
;          Assumed y2 > y1

callDrawColumnDown MACRO color , lineWidth , x1 , y1 , y2

    PUSHA
    
    MOV SI , x1
    MOV DI,y1 ; Decrement y1 because when drawing from bottom to top it is shifted by 1 pixel
    DEC DI
    
    MOV BX,x1
    ADD BX,lineWidth ; BX contains x2 ( x1+lineWidth )
    
    ; Parameters for INT 10h (draw pixel interrupt)
    MOV CX,x1
    MOV DX,y2
    DEC DX    ; Decrement y2 because when drawing from bottom to top it is shifted by 1 pixel
    MOV AL,color
    MOV AH,0ch
	
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
    
    MOV SI , x2
    MOV DI , y1
    
    MOV BX,y1
    ADD BX,lineWidth ; BX contains y2 ( y1+lineWidth )
    
    ; Parameters for INT 10h (draw pixel interrupt)
    MOV CX,x1
    MOV DX,y1
    MOV AL,color
    MOV AH,0ch
	
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
    

    MOV SI,x1 ; Decrement x1 because when drawing from right to left it is shifted by 1 pixel
    DEC SI
    
    MOV DI , y1
    
    MOV BX,y1
    ADD BX,lineWidth ; BX contains y2 ( y1+lineWidth )
    
    ; Parameters for INT 10h (draw pixel interrupt)
    MOV CX,x2
    DEC CX    ; Decrement x2 because when drawing from right to left it is shifted by 1 pixel
    MOV DX,y1
    MOV AL,color
    MOV AH,0ch
    
    CALL drawRowRight

    POPA
ENDM callDrawRowRight
