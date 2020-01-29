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
PUBLIC drawLargeImage
PUBLIC drawImage
PUBLIC clearBlock

PUBLIC letterDrawingSpeed

INCLUDE colors.inc

.DATA

	maxDrawingSpeed EQU 512000
	letterDrawingSpeed DB 60
	; I use these variable because sometimes I run out of Registers
	_variable_Graphics_position_x1 DB ?
	position_in_file DW ?
	imageData DB ?

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



; Draw Large image at position x1 , y1
; The difference Between This Function and drawImage is that here we have a large image
; and can not load the entire image because we will run out of memory
; Therefore Here we load one byte at a time and draw it to use less memory
drawLargeImage PROC

	; Parameters :
	; CX -> x1
	; DX -> y1
	; SI -> x2
	; DI -> y2
	; BX -> fileHandle

	MOV BP , CX

	MOV AH , 0Ch ; Draw pixel mode of int 10h
	MOV position_in_file , 0 ; stores the current position in the file

	_label_drawLargeImage_drawLoop:

		; Read the next byte from the file
		PUSHA
			; JUMP TO POSITION INSIDE THE FILE.
			MOV AH , 42h
			MOV AL , 0 ; START FROM THE BEGINNING OF FILE.
			MOV CX , 0 ; FILE POSITION is CX:DX
			MOV DX , position_in_file
			INT 21h

			;READ ONE CHAR FROM CURRENT FILE POSITION.
			MOV AH , 3Fh
			MOV CX , 1 ; HOW MANY BYTES TO READ.
			LEA DX , imageData ; WHERE TO STORE THE READ BYTES.  
			INT 21h
			
		POPA
		
		INC position_in_file  ; Move to the next byte in the file

		; Draw the pixel we read from the file
		MOV AL , imageData
		INT 10h ; Draw the  pixel
		INC CX ; x++
		CMP CX , SI ; checks if x < x2
	JNE _label_drawLargeImage_drawLoop 
		MOV CX , BP ; Cx = x1
		INC DX  ; y++ (move to next row)
		CMP DX , DI ; checks if y < y2
	JNE _label_drawLargeImage_drawLoop

	RET
drawLargeImage ENDP


; Draw 16px * 16px image at position x1 , y1
; THis Procedure is called from callDrawImage MACRO which prepares its parameters
; DO NOT call it directly 
drawImage PROC

	; Parameters :
	; CX -> x1
	; DX -> y1
	; BP -> imageData

	MOV _variable_Graphics_position_x1 , CX
	MOV SI , CX ; SI = x1
	ADD SI , 16 ; SI = x2 = x1 + 16
	MOV DI , DX ; DI = y1
	ADD DI , 16 ; DI = y2 = y2 + 16
	MOV BH , 0 ; BH contains the page number to draw in 

	MOV AH , 0Ch ; Draw pixel mode of INT 10h
	_label_drawImage_drawLoop:

			MOV AL , DS:[BP] ; Move current pixel color Data from the image to AL 
			INT 10h ; Draw the pixel
			INC BP ; Move to next pixel in image
			INC CX ; x++
			CMP CX , SI ; checks if x < x2
		JNE _label_drawImage_drawLoop
		
		MOV CX , _variable_Graphics_position_x1
		INC DX  ; y++ (move to next row)
		CMP DX , DI ; checks if y < y2
	JNE _label_drawImage_drawLoop

	RET
drawImage ENDP


clearBlock PROC

	; Parameters:
	; CX -> x1
	; DX -> y1

	MOV BP , CX ; BP = x1
	MOV SI , CX ; SI = x1
	ADD SI , 16 ; SI = x2 = x1 + 16
	MOV DI , DX ; DI = y1
	ADD DI , 16 ; DI = y2 = y2 + 16
	MOV BH , 0 ; BH contains the page number to draw in 

	MOV AH , 0Ch ; Draw pixel mode of int 10h
	MOV AL , color_background
	; Drawing loop
	_label_clearBlock_drawLoop:
			INT 10h ; Draw the  pixel
			INC CX ; x++
			CMP CX , SI ; checks if x < x2
		JNE _label_clearBlock_drawLoop 
		
		MOV CX , BP ; CX = x1 
		INC DX  ; y++ (move to next row)
		CMP DX , DI ; checks if y < y2
	JNE _label_clearBlock_drawLoop

	RET
clearBlock ENDP



END
