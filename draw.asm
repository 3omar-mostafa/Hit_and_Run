; This file contains PROCs that draw vertical/horizontal lines on the screen
; They support speed factor that shows the effect of drawing

; The parametes for these PROCs are prepared by MACROs in draw.inc
; DO NOT CALL THESE PROCs DIRECTLY

.MODEL SMALL
.STACK 64
.386 ; sets the instruction set of 80386 prosessor
.DATA

bombFireUpStartX DW ?
bombFireUpStartX DW ?
bombFireUpEndX DW ?
bombFireUpEndY DW ?

bombFireDownStartX DW ?
bombFireDownStartX DW ?
bombFireDownEndX DW ?
bombFireDownEndY DW ?

bombFireLeftStartX DW ?
bombFireLeftStartX DW ?
bombFireLeftEndX DW ?
bombFireLeftEndY DW ?

bombFireRightStartX DW ?
bombFireRightStartX DW ?
bombFireRightEndX DW ?
bombFireRightEndY DW ?


.CODE

; These procedures are public
; i.e. can be called from another assembly file
PUBLIC drawColumnUp
PUBLIC drawColumnDown
PUBLIC drawRowLeft
PUBLIC drawRowRight
PUBLIC drawFire

; These variales are external
; MUST be declared at another assembly file with same name,type
; so that the linker join them
EXTRN bombrightData:WORD
EXTRN bombleftData:WORD
EXTRN bombUpData:WORD
EXTRN bombDownData:WORD


maxDrawingSpeed EQU 512000


delay PROC
	
	PUSHA
	
	MOV EDX , 0
	MOV EAX , maxDrawingSpeed

	MOVZX EBX , letterDrawingSpeed
	DIV EBX
	_label_delay_Loop:
		DEC EAX
	JNZ _label_delay_Loop
	
	POPA
    
    RET
delay ENDP


; THis Prodecure is called from callDrawColumnUp MACRO which prepares its parameters

drawColumnUp PROC

	; Parameters :
	; AL -> color
	; SI -> x1
	; BX -> x1 + lineWidth  (x2)
	; DI -> y2
	
	; CX -> x1
	; DX -> y1
	
    ; draw the Vertical Line from top to bottom row by row
_label_drawColumnUp_Loop:   
    INT 10h     ; draw pixel
    INC CX      ; x1++
    CMP CX , BX ; checks if x1 < x2
JNE _label_drawColumnUp_Loop
	
    call delay ; delay after drawing each row
	
    MOV CX , SI
    INC DX      ; y1++ (move to next row)
    CMP DX , DI ; checks if y1 < y2
JNE _label_drawColumnUp_Loop

    RET
drawColumnUp ENDP





; THis Prodecure is called from callDrawColumnDown MACRO which prepares its parameters

drawColumnDown PROC

	; Parameters :
	; AL -> color
	; SI -> x1
	; BX -> x1 + lineWidth (x2)
	; DI -> y1
	
	; CX -> x1
	; DX -> y1
	
    ; draw the Vertical Line from bottom to top row by row
_label_drawColumnDown_Loop:   
    INT 10h   ; draw pixel
    INC CX    ; x1++
    CMP CX,BX ; checks if x1 < x2
JNE _label_drawColumnDown_Loop 
	
    call delay ; delay after drawing each row
	
    MOV CX , SI
    DEC DX      ; y1-- (move to previous row)
    CMP DX , DI ; checks if y1 < y2
JNE _label_drawColumnDown_Loop

	RET
drawColumnDown ENDP





; THis Prodecure is called from callDrawRowLeft MACRO which prepares its parameters

drawRowLeft PROC

	; Parameters :
	; AL -> color
	; SI -> x2
	; BX -> y1 + lineWidth (y2)
	; DI -> y1
	
	; CX -> x1
	; DX -> y1
	
    ; draw the Horizontal Line from left to right column by column
_label_drawRowLeft_Loop:   
    INT 10h   ; draw pixel
    INC DX    ;y1++
    CMP DX,BX ; checks if y1 < y2
JNE _label_drawRowLeft_Loop 
	
    call delay ; delay after drawing each column
	
    MOV DX , DI
    INC CX      ; x1++ (move to next column)
    CMP CX , SI ; checks if x1 < x2
JNE _label_drawRowLeft_Loop

    RET
drawRowLeft ENDP





; THis Prodecure is called from callDrawRowRight MACRO which prepares its parameters

drawRowRight PROC

	; Parameters :
	; AL -> color
	; SI -> x1
	; BX -> y1 + lineWidth (y2)
	; DI -> y1
	
	; CX -> x1
	; DX -> y1


    ; draw the Horizontal Line from right to left column by column
_label_drawRowRight_Loop:   
    INT 10h   ; draw pixel
    INC DX    ;y1++
    CMP DX,BX ; checks if y1 < y2
JNE _label_drawRowRight_Loop 
	
    call delay ; delay after drawing each column
	
    MOV DX , DI
    DEC CX      ; x1-- (move to previous column)
    CMP CX , SI ; checks if x1 < x2
JNE _label_drawRowRight_Loop

    RET
drawRowRight ENDP



; CX -> bombStartX , DX -> bombStartY
drawFire PROC






RET
drawFire ENDP





END
