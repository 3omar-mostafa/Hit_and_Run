
callUpdateGrid MACRO x1 , y1 , newData
	PUSHA

	MOV BX , x1
	MOV AX , y1
	MOV CL , newData

	CALL updateGrid

	POPA
ENDM callUpdateGrid

