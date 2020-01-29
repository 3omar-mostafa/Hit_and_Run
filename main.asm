.MODEL SMALL
.STACK 2048
.386 ; sets the instruction set of 80386 processor

PUBLIC NamePlayer1
PUBLIC NamePlayer2

; This are external Procedures defined in other .asm files
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
	player1Message DB "Player Name : " , '$'


.CODE
MAIN PROC FAR

	CALL initializeDataSegment

	CALL displayWelcomeScreen

	callSwitchToTextMode

	CALL readPlayer1Name

	CALL MenuScreen
	
	callSwitchToTextMode

	CALL exitProgram
    
MAIN ENDP


initializeDataSegment PROC

    MOV AX , @DATA
    MOV DS , AX
	
	RET
initializeDataSegment ENDP


exitProgram PROC

    ; return control to operating system
    MOV AH , 4Ch
    INT 21H

exitProgram ENDP


readPlayer1Name PROC
	PUSHA

	callSetCursorPosition 18 , 5
	callPrintString enterMessage

	callSetCursorPosition 33 , 10
	callPrintString player1Message

	_label_readPlayer1Name_loop:

		callSetCursorPosition 36 , 12
		callClearCharacters NamePlayer2_length

		callReadString NamePlayer1

		callIsLetter NamePlayer1[0]
		JC _label_readPlayer1Name_finish

		callSetCursorPosition 22 , 15
		callPrintString errorMessage

	JMP _label_readPlayer1Name_loop
	
	_label_readPlayer1Name_finish:	  	  
	POPA
	RET
readPlayer1Name ENDP			



END MAIN