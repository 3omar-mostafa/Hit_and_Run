; This file contains Procedures that draw vertical/horizontal lines on the screen
; They support speed factor that shows the effect of drawing

; The parameters for these Procedures are prepared by MACROs in draw.inc
; DO NOT CALL THESE Procedures DIRECTLY

.MODEL SMALL
.STACK 2048
.386 ; sets the instruction set of 80386 processor


; These procedures are public
; i.e. can be called from another assembly file
PUBLIC drawColumnUp
PUBLIC drawColumnDown
PUBLIC drawRowLeft
PUBLIC drawRowRight

PUBLIC letterDrawingSpeed

INCLUDE colors.inc

.DATA

	maxDrawingSpeed EQU 512000
	letterDrawingSpeed DB 60

.CODE

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


; THis Procedure is called from callDrawColumnUp MACRO which prepares its parameters
drawColumnUp PROC

	; Parameters :
	; AL -> color
	; SI -> x1
	; BX -> lineWidth
	; DI -> y2
	; CX -> x1
	; DX -> y1

	ADD BX , SI ; BX contains x2 ( x1+lineWidth )
	
	MOV AH , 0Ch
	; draw the Vertical Line from top to bottom row by row
	_label_drawColumnUp_Loop:   
			INT 10h     ; draw pixel
			INC CX      ; x++
			CMP CX , BX ; checks if x < x2
		JNE _label_drawColumnUp_Loop
		
		CALL delay ; delay after drawing each row
		
		MOV CX , SI ; CX = x1
		INC DX      ; y++ (move to next row)
		CMP DX , DI ; checks if y < y2
	JNE _label_drawColumnUp_Loop

	RET
drawColumnUp ENDP



; This Procedure is called from callDrawColumnDown MACRO which prepares its parameters
drawColumnDown PROC

	; Parameters :
	; AL -> color
	; SI -> x1
	; BX -> lineWidth
	; DI -> y1
	; CX -> x1
	; DX -> y1

	
	ADD BX , SI ; BX contains x2 ( x1+lineWidth )
	DEC DI ; Decrement y1 because when drawing from bottom to top it is shifted by 1 pixel
	DEC DX ; Decrement y2 because when drawing from bottom to top it is shifted by 1 pixel

	MOV AH , 0Ch
	; draw the Vertical Line from bottom to top row by row
	_label_drawColumnDown_Loop:   
			INT 10h   ; draw pixel
			INC CX    ; x++
			CMP CX,BX ; checks if x < x2
		JNE _label_drawColumnDown_Loop 
		
		CALL delay ; delay after drawing each row
		
		MOV CX , SI ; CX = x1
		DEC DX      ; y-- (move to previous row)
		CMP DX , DI ; checks if y < y2
	JNE _label_drawColumnDown_Loop

	RET
drawColumnDown ENDP



; THis Procedure is called from callDrawRowLeft MACRO which prepares its parameters
drawRowLeft PROC

	; Parameters :
	; AL -> color
	; SI -> x2
	; BX -> lineWidth
	; DI -> y1
	; CX -> x1
	; DX -> y1
	
	ADD BX , DI ; BX contains y2 ( y1+lineWidth )
	
	MOV AH , 0Ch
	; draw the Horizontal Line from left to right column by column
	_label_drawRowLeft_Loop:   
			INT 10h   ; draw pixel
			INC DX    ;y++
			CMP DX,BX ; checks if y < y2
		JNE _label_drawRowLeft_Loop
		
		CALL delay ; delay after drawing each column
		
		MOV DX , DI ; DX = y1
		INC CX      ; x++ (move to next column)
		CMP CX , SI ; checks if x < x2
	JNE _label_drawRowLeft_Loop

	RET
drawRowLeft ENDP



; THis Procedure is called from callDrawRowRight MACRO which prepares its parameters
drawRowRight PROC

	; Parameters :
	; AL -> color
	; SI -> x1
	; BX -> lineWidth
	; DI -> y1
	; CX -> x1
	; DX -> y1

	ADD BX , DI ; BX contains y2 ( y1+lineWidth )
	DEC SI ; Decrement x1 because when drawing from right to left it is shifted by 1 pixel
	DEC CX ; Decrement x2 because when drawing from right to left it is shifted by 1 pixel
	
	MOV AH , 0Ch
	; draw the Horizontal Line from right to left column by column
	_label_drawRowRight_Loop:   
			INT 10h   ; draw pixel
			INC DX    ; y++
			CMP DX,BX ; checks if y < y2
		JNE _label_drawRowRight_Loop 
		
		CALL delay ; delay after drawing each column
		
		MOV DX , DI ; DX = y1
		DEC CX      ; x-- (move to previous column)
		CMP CX , SI ; checks if x < x2
	JNE _label_drawRowRight_Loop

	RET
drawRowRight ENDP

END
