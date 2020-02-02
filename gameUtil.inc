
callUpdateGrid MACRO x1 , y1 , newData
	PUSHA

	MOV BX , x1
	MOV AX , y1
	MOV CL , newData

	CALL updateGrid

	POPA
ENDM callUpdateGrid



; Parameters:
; BX -> X
; AX -> Y
callExplodeBlock MACRO whoseBomb
	PUSHA

	MOV DL , whoseBomb

	CALL explodeBlock

	POPA
ENDM callExplodeBlock



callExplodeBomb MACRO bomb , whoseBomb
	PUSHA
	MOV bomb.to_be_drawn , false
	
	MOV BX , bomb.bomb_x
	MOV AX , bomb.bomb_y

	MOV DL , whoseBomb

	CALL explodeBomb

	POPA
ENDM callExplodeBomb

callMoveIfAvailable_Player1 MACRO direction
	PUSHA

		LEA BP , direction
		CALL moveIfAvailable_Player1

	POPA
ENDM callMoveIfAvailable_Player1


callMoveIfAvailable_Player2 MACRO direction
	PUSHA

		LEA BP , direction
		CALL moveIfAvailable_Player2

	POPA
ENDM callMoveIfAvailable_Player2
