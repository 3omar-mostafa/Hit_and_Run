.MODEL SMALL
.STACK 2048
.386 ; sets the instruction set of 80386 processor

PUBLIC NamePlayer1
PUBLIC NamePlayer2

PUBLIC displayReadNameHeader
PUBLIC readSinglePlayerName
PUBLIC readTwoPlayersNames

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
	player1Message DB "Player 1 Name :" , '$'
	player2Message DB "Player 2 Name :" , '$'
	playerMessage DB "Player Name :" , '$'


.CODE
Main PROC FAR

	CALL initializeDataSegment

	CALL displayWelcomeScreen

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


displayReadNameHeader PROC
	PUSHA

	callSwitchToTextMode

	callSetCursorPosition 18 , 5
	callPrintString enterMessage

	POPA
	RET
displayReadNameHeader ENDP



readSinglePlayerName PROC
	PUSHA

	callSetCursorPosition 33 , 10
	callPrintString playerMessage

	_label_readSinglePlayerName_loop:

		callSetCursorPosition 36 , 12
		callClearCharacters NamePlayer1_length

		callReadString NamePlayer1

		callIsLetter NamePlayer1[0]
		JC _label_readSinglePlayerName_finish

		callSetCursorPosition 22 , 15
		callPrintString errorMessage

	JMP _label_readSinglePlayerName_loop
	
	_label_readSinglePlayerName_finish:  
	POPA
	RET
readSinglePlayerName ENDP



readTwoPlayersNames PROC
	PUSHA

	_label_read_Player1_Name:

		callSetCursorPosition 50 , 10
		callPrintString player1Message

		_label_Player1_verify_name_loop:

			callSetCursorPosition 53 , 12
			callClearCharacters NamePlayer1_length

			callReadString NamePlayer1

			callIsLetter NamePlayer1[0]
			JC _label_read_Player2_Name

			callSetCursorPosition 22 , 20
			callPrintString errorMessage

		JMP _label_Player1_verify_name_loop
	

	_label_read_Player2_Name:  

		callSetCursorPosition 10 , 10
		callPrintString player2Message

		_label_Player2_verify_name_loop:

			callSetCursorPosition 13 , 12
			callClearCharacters NamePlayer2_length

			callReadString NamePlayer2

			callIsLetter NamePlayer2[0]
			JC _label_readTwoPlayersNames_finish

			callSetCursorPosition 22 , 20
			callPrintString errorMessage

		JMP _label_Player2_verify_name_loop
	
	_label_readTwoPlayersNames_finish:  
	POPA
	RET
readTwoPlayersNames ENDP


END Main