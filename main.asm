.MODEL SMALL
.STACK 2048
.386 ; sets the instruction set of 80386 processor

PUBLIC NamePlayer1
PUBLIC NamePlayer2

; This are external Procedures defined in other Assembly files
; The linker will join them
EXTRN displayWelcomeScreen:NEAR
EXTRN MenuScreen:NEAR

INCLUDE inout.inc

.DATA

	NamePlayer1_length DB 7 , ?
	NamePlayer1 DB 7 DUP('$')

	NamePlayer2_length DB 7 , ?
	NamePlayer2 DB 7 DUP('$')

	errorMessage DB "Please start your name with a letter",'$'
	enterMessage DB "Please enter your name (Max of 6 Characters)",'$'
	player1Message DB "Player 1 Name : " , '$'
	player2Message DB "Player 2 Name : " , '$'


.CODE
Main PROC FAR

	CALL initializeDataSegment

	CALL displayWelcomeScreen

	callSwitchToTextMode

	callSetCursorPosition 18 , 5
	callPrintString enterMessage

	CALL readPlayer1Name
	CALL readPlayer2Name

	CALL MenuScreen
	
	callSwitchToTextMode
	CALL exitProgram
	
Main ENDP


initializeDataSegment PROC
	MOV AX , @DATA
	MOV DS , AX
	
	RET
initializeDataSegment ENDP


; return control to operating system
exitProgram PROC

	MOV AH , 4Ch
	INT 21H

exitProgram ENDP


readPlayer1Name PROC
	PUSHA

	callSetCursorPosition 50 , 10
	callPrintString player1Message

	_label_Player1_verify_name_loop:

		callSetCursorPosition 53 , 12
		callClearCharacters NamePlayer2_length

		callReadString NamePlayer1

		callIsLetter NamePlayer1[0]
		JC _label_readPlayer1Name_finish

		callSetCursorPosition 22 , 20
		callPrintString errorMessage

	JMP _label_Player1_verify_name_loop
	
	_label_readPlayer1Name_finish:  
	POPA
	RET
readPlayer1Name ENDP


readPlayer2Name PROC
	PUSHA

	callSetCursorPosition 10 , 10
	callPrintString player2Message

	_label_Player2_verify_name_loop:

		callSetCursorPosition 13 , 12
		callClearCharacters NamePlayer2_length

		callReadString NamePlayer2

		callIsLetter NamePlayer2[0]
		JC _label_readPlayer2Name_finish

		callSetCursorPosition 22 , 20
		callPrintString errorMessage

	JMP _label_Player2_verify_name_loop
	
	_label_readPlayer2Name_finish:  
	POPA
	RET
readPlayer2Name ENDP


END Main