
callUpdateGrid MACRO x1 , y1 , newData
	PUSHA

	MOV BX , x1
	MOV AX , y1
	MOV CL , newData

	CALL updateGrid

	POPA
ENDM callUpdateGrid


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
