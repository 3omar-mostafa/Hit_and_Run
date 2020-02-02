.MODEL SMALL
.STACK 2048
.386 ; sets the instruction set of 80386 processor

PUBLIC Game

EXTRN NamePlayer1:BYTE
EXTRN NamePlayer2:BYTE

EXTRN displayResults:NEAR

EXTRN Chat:NEAR
; Inline Chat Windows variables
EXTRN windowOneStartX:BYTE
EXTRN windowOneEndX:BYTE
EXTRN windowOneStartY:BYTE
EXTRN windowOneEndY:BYTE
EXTRN WindowOneColor:BYTE
EXTRN windowTwoStartX:BYTE
EXTRN windowTwoEndX:BYTE
EXTRN windowTwoStartY:BYTE
EXTRN windowTwoEndY:BYTE
EXTRN WindowTwoColor:BYTE

INCLUDE inout.inc
INCLUDE draw.inc
INCLUDE gameUtil.inc
INCLUDE serial.inc
INCLUDE const.inc

.DATA

	; Player 1 Controls:
	CONTROLS_PLAYER_1_UP EQU ARROW_UP_SCAN_CODE
	CONTROLS_PLAYER_1_DOWN EQU ARROW_DOWN_SCAN_CODE
	CONTROLS_PLAYER_1_LEFT EQU ARROW_LEFT_SCAN_CODE
	CONTROLS_PLAYER_1_RIGHT EQU ARROW_RIGHT_SCAN_CODE
	CONTROLS_PLAYER_1_FIRE EQU SPACE_BAR_SCAN_CODE

	; Player 2 Controls:
	CONTROLS_PLAYER_2_UP EQU LETTER_W_SCAN_CODE
	CONTROLS_PLAYER_2_DOWN EQU LETTER_S_SCAN_CODE
	CONTROLS_PLAYER_2_LEFT EQU LETTER_A_SCAN_CODE
	CONTROLS_PLAYER_2_RIGHT EQU LETTER_D_SCAN_CODE
	CONTROLS_PLAYER_2_FIRE EQU TAB_BAR_SCAN_CODE

	BLOCK_WIDTH EQU 16
	BLOCK_HEIGHT EQU 16

	IMAGE_WIDTH EQU BLOCK_WIDTH
	IMAGE_HEIGHT EQU BLOCK_HEIGHT

	true EQU 1
	false EQU 0

	COIN_SCORE EQU 100
	DYING_PENALTY_SCORE EQU 200

	PLAYER_1_BOMB EQU 1
	PLAYER_2_BOMB EQU 2

	BOMB_LEVEL_1 EQU 1
	BOMB_LEVEL_2 EQU 2

	BOMB_TIME_TO_EXPLODE EQU 2

	; Game Connection Menu Messages
	sendInvitationMessage DB "Press F1 to send Invitation" , '$'
	receiveInvitationMessage DB "Press F2 to receive Invitation" , '$'
	returnToPreviousMenu DB "Press F3 to return to previous menu" , '$'
	validInputMessage DB "Please enter a valid value" , '$'
	playerWantsToConnectMessage DB " invites you to play" , '$'
	acceptInvitationMessage DB 	"Press F1 to accept" , '$'
	rejectInvitationMessage DB "Press F2 to reject" , '$'
	waitingForResponse DB "Waiting for other player's response . . ." , '$'
	rejectionMessage DB "Sorry the other player does not want to play right now" , '$'

	; any arbitrary values
	SEND_INVITATION EQU 5
	ACKNOWLEDGMENT EQU 6
	ACCEPT_INVITATION EQU 7
	REJECT_INVITATION EQU 8


	;Movement   dx , dy
	UP      DW  0  , -16
	DOWN    DW  0  ,  16
	LEFT    DW -16 ,  0
	RIGHT   DW  16 ,  0

	last_time DB ?
	gameTimer DB 150

	exitFlag DB false

	bomberManFilename DB "images\bomber.img", 0
	bomberManFileHandle DW ?
	bomberManData DB IMAGE_WIDTH*IMAGE_HEIGHT dup(?)
	
	bombFilename DB "images\bomb.img", 0
	bombFileHandle DW ?
	bombData DB IMAGE_WIDTH*IMAGE_HEIGHT dup(?)
	
	coinFilename DB "images\coinUp.img", 0
	coinFileHandle DW ?
	coinData DB IMAGE_WIDTH*IMAGE_HEIGHT dup(?)
	
	HPFilename DB "images\healthUp.img", 0
	HPFileHandle DW ?
	HPData DB IMAGE_WIDTH*IMAGE_HEIGHT dup(?)

	PowerUpFilename DB "images\bombUp.img", 0
	PowerUpFileHandle DW ?
	PowerUpData DB IMAGE_WIDTH*IMAGE_HEIGHT dup(?)
	
	heartIconFilename DB "images\heartIco.img", 0
	heartIconFileHandle DW ?
	heartIconData DB IMAGE_WIDTH*IMAGE_HEIGHT dup(?)


	bomb STRUC
		bomb_x DW 0
		bomb_y DW 0

		to_be_drawn DB false
		counter DB BOMB_TIME_TO_EXPLODE + 1 ; count seconds passed after putting the bomb (used to know when to explode)
		level DB BOMB_LEVEL_1
	bomb ENDS

	; Creating objects from the struct
	bomb1 bomb<>
	bomb2 bomb<>
	

	Player STRUC
		position_x DW ?
		position_y DW ?

		respawn_x DW ? ; position to return to after death
		respawn_y DW ? ; position to return to after death
		
		lives DB 3
		score DW 0

		; Score bar variables
		name_position DB ?
		lives_position DB ?
		score_position DB ?
	Player ENDS

	; Creating objects from the struct
	Player1 Player<>
	Player2 Player<>
	

	; set bit (1) in Most significant bit refers to block (forbidden movement)
	;      |
	;      V
	X  EQU 10000000b ; 128 -> Unbreakable Block
	B  EQU 10000001b ; 129 -> Breakable Block
	G  EQU 00000000b ; 0   -> Ground
	B1 EQU 10010000b ; 72  -> Bomb of Player1
	P1 EQU 00011000b ; 24  -> Player1
	B2 EQU 10100000b ; 160 -> Bomb of Player2
	P2 EQU 00110000b ; 48  -> Player2
	
	P1_B1 EQU B1 OR P1 ; Player1 put a bomb but did not move (player and bomb on the same block)
	P2_B2 EQU B2 OR P2 ; Player2 put a bomb but did not move (player and bomb on the same block)

	C EQU 00000010b ; 2 -> Coin powerup
	H EQU 00000100b ; 4 -> Health powerup
	P EQU 00001000b ; 8 -> Bomb powerup
	
	C_B EQU C OR B ; Coin powerup under the breakable block
	H_B EQU H OR B ; Health powerup under the breakable block
	P_B EQU P OR B ; Bomb powerup under the breakable block
	
	GRID_WIDTH EQU 20
	GRID_HEIGHT EQU 9

	GRID_BOUNDARY_RIGHT EQU 320
	GRID_BOUNDARY_LEFT EQU 0
	GRID_BOUNDARY_DOWN EQU 160
	GRID_BOUNDARY_UP EQU 16

	gridFilename DB "images\grid.img", 0
	gridFileHandle DW ?
	
	;        0     1     2     3     4     5    6      7     8     9     10    11    12    13    14    15    16    17    18    19
	grid DB  X  ,  X  ,  X  ,  X  ,  X  ,  X  ,  X  ,  X  ,  X  ,  X  ,  X  ,  X  ,  X  ,  X  ,  X  ,  X  ,  X  ,  X  ,  X  ,  X ; 0
	     DB  X  ,  G  ,  G  ,  B  ,  B  ,  B  ,  B  ,  B  ,  B  ,  B  , P_B ,  B  ,  B  ,  B  ,  B  ,  B  ,  B  ,  B  ,  B  ,  X ; 1
	     DB  X  ,  G  ,  X  , C_B ,  X  ,  G  ,  X  ,  B  ,  X  ,  G  ,  G  ,  X  ,  B  ,  X  ,  G  ,  X  ,  B  ,  X  ,  G  ,  X ; 2
	     DB  X  ,  B  ,  B  ,  B  ,  B  ,  B  ,  B  , C_B ,  B  , H_B ,  B  , C_B ,  B  ,  B  ,  B  ,  B  ,  B  ,  B  ,  B  ,  X ; 3
	     DB  X  ,  G  ,  X  ,  B  ,  X  ,  G  ,  X  ,  B  ,  X  ,  G  ,  G  ,  X  ,  B  ,  X  ,  G  ,  X  ,  B  ,  X  ,  G  ,  X ; 4
	     DB  X  ,  B  ,  B  ,  B  ,  B  ,  B  ,  B  ,  B  ,  B  ,  B  ,  B  ,  B  ,  B  , H_B ,  B  ,  B  ,  B  ,  B  ,  B  ,  X ; 5
	     DB  X  ,  G  ,  X  ,  B  ,  X  ,  G  ,  X  ,  B  ,  X  ,  G  ,  G  ,  X  ,  B  ,  X  ,  G  ,  X  , C_B ,  X  ,  G  ,  X ; 6
	     DB  X  ,  B  ,  B  , H_B ,  B  ,  B  , C_B ,  B  ,  B  , C_B ,  B  ,  B  ,  B  ,  B  ,  B  ,  B  ,  B  ,  G  ,  G  ,  X ; 7
	     DB  X  ,  X  ,  X  ,  X  ,  X  ,  X  ,  X  ,  X  ,  X  ,  X  ,  X  ,  X  ,  X  ,  X  ,  X  ,  X  ,  X  ,  X  ,  X  ,  X ; 8
 

.CODE

Game PROC

	callSwitchToTextMode

	backupGridData  ; Grid content is spoiled after the game
	                ; Therefore changes that players made will remain in the next game
	                ; We backup the grid and restore it when the game finish


	CALL initializeData ; Same as grid we initialize data because it was spoiled

	CALL loadImages
	
	CALL startConnection

	CMP exitFlag , true
	JE _label_exit
	
	callSwitchToGraphicsMode

	callOpenFile gridFilename , gridFileHandle
	callDrawLargeImage gridFileHandle , 0 , 16 , 320 , 144
	callCloseFile gridFileHandle

	; Put the players in their places
	callUpdateGrid Player1.position_x , Player1.position_y , P1
	callDrawImage Player1.position_x , Player1.position_y , bomberManData

	callUpdateGrid Player2.position_x , Player2.position_y , P2
	callDrawImage Player2.position_x , Player2.position_y , bomberManData

	; The heart icons in the score bar
	callDrawImage 96 , 0 , heartIconData
	callSetCursorPosition 14 , 0
	callPrintChar ':'

	callDrawImage 288 , 0 , heartIconData
	callSetCursorPosition 38 , 0
	callPrintChar ':'

	CALL printPlayersNames

	GameLoop:
		
		CALL checkAction_Player1
		CALL checkAction_Player2
		callClearKeyboardBuffer
		
		callGetSystemTime
		
		CMP_MEMORY time_seconds , last_time
		JE _label_Game_loop_end
		
		; One Second have passed
			
			MOV_MEMORY_BYTE last_time , time_seconds

			CMP gameTimer , 0
			JE _label_go_to_results

			DEC gameTimer
			CALL printTime

			CALL updateScoreBar

			INC bomb1.counter
			INC bomb2.counter
			
			CMP bomb1.counter , BOMB_TIME_TO_EXPLODE
			JE _label_explode_bomb1 
			
			CMP bomb2.counter , BOMB_TIME_TO_EXPLODE
			JE _label_explode_bomb2 
			

		JMP _label_Game_loop_end
		
		_label_explode_bomb1:
			callExplodeBomb bomb1 , PLAYER_1_BOMB
			
		JMP _label_Game_loop_end

		_label_explode_bomb2:
			callExplodeBomb bomb2 , PLAYER_2_BOMB

	_label_Game_loop_end:
	CMP exitFlag , true
	JNE GameLoop

	_label_go_to_results:
		CALL updateScoreBar
		callDelayInSeconds 1

		; displayResults Parameters
		MOV AL , Player1.lives
		MOV AH , Player2.lives
		MOV CX , Player1.score
		MOV DX , Player2.score

		CALL displayResults
	
	_label_exit:
		restoreGridData

		RET
Game ENDP


checkAction_Player1 PROC
	PUSHA

	callIsKeyPressed
	JZ _label_checkAction_P1_finish
	
	callGetPressedKey

	CMP AH , CONTROLS_PLAYER_1_UP
	JE _label_checkAction_P1_up

	CMP AH , CONTROLS_PLAYER_1_DOWN
	JE _label_checkAction_P1_down

	CMP AH , CONTROLS_PLAYER_1_RIGHT
	JE _label_checkAction_P1_right

	CMP AH , CONTROLS_PLAYER_1_LEFT
	JE _label_checkAction_P1_left

	CMP AH , CONTROLS_PLAYER_1_FIRE
	JE _label_checkAction_P1_put_bomb

	CMP AH, F4_SCAN_CODE
	JE _label_checkAction_P1_exit

	CALL inlineChat
	JMP _label_checkAction_P1_finish



	_label_checkAction_P1_up:

		callSendByte CONTROLS_PLAYER_2_UP
		callMoveIfAvailable_Player1 UP
		
	JMP _label_checkAction_P1_finish


	_label_checkAction_P1_down:

		callSendByte CONTROLS_PLAYER_2_DOWN
		callMoveIfAvailable_Player1 DOWN

	JMP _label_checkAction_P1_finish


	_label_checkAction_P1_right:

		callSendByte CONTROLS_PLAYER_2_RIGHT
		callMoveIfAvailable_Player1 RIGHT

	JMP _label_checkAction_P1_finish


	_label_checkAction_P1_left: 

		callSendByte CONTROLS_PLAYER_2_LEFT
		callMoveIfAvailable_Player1 LEFT
		
	JMP _label_checkAction_P1_finish


	_label_checkAction_P1_put_bomb:
	
		callSendByte CONTROLS_PLAYER_2_FIRE
		CALL putBomb_Player1

	JMP _label_checkAction_P1_finish
	

	_label_checkAction_P1_exit:
		callSendByte F4_SCAN_CODE
		MOV exitFlag , true

	_label_checkAction_P1_finish:
	POPA
	RET
checkAction_Player1 ENDP




checkAction_Player2 PROC
	PUSHA

	callCheckIfReceived
	JNC _label_checkAction_P2_finish

	callGetReceivedByte
	MOV AH , receivedByte

	CMP AH , CONTROLS_PLAYER_2_UP
	JE _label_checkAction_P2_up

	CMP AH , CONTROLS_PLAYER_2_DOWN
	JE _label_checkAction_P2_down

	CMP AH , CONTROLS_PLAYER_2_RIGHT
	JE _label_checkAction_P2_right

	CMP AH , CONTROLS_PLAYER_2_LEFT
	JE _label_checkAction_P2_left

	CMP AH , CONTROLS_PLAYER_2_FIRE
	JE _label_checkAction_P2_put_bomb

	CMP AH, F4_SCAN_CODE
	JE _label_checkAction_P2_exit

	CALL inlineChat
	JMP _label_checkAction_P2_finish
	


	_label_checkAction_P2_up:

		callMoveIfAvailable_Player2 UP

	JMP _label_checkAction_P2_finish


	_label_checkAction_P2_down:

		callMoveIfAvailable_Player2 DOWN

	JMP _label_checkAction_P2_finish


	_label_checkAction_P2_right:

		callMoveIfAvailable_Player2 RIGHT
	
	JMP _label_checkAction_P2_finish


	_label_checkAction_P2_left:

		callMoveIfAvailable_Player2 LEFT
	
	JMP _label_checkAction_P2_finish

	_label_checkAction_P2_put_bomb:

		CALL putBomb_Player2
	
	JMP _label_checkAction_P2_finish

	_label_checkAction_P2_exit:
		MOV exitFlag , true
	
	_label_checkAction_P2_finish:
	POPA           
	RET
checkAction_Player2 ENDP


startConnection PROC
	PUSHA

	callSetCursorPosition 26 , 8
	callPrintString sendInvitationMessage

	callSetCursorPosition 25 , 12
	callPrintString receiveInvitationMessage

	callSetCursorPosition 23 , 16
	callPrintString returnToPreviousMenu

	callSetCursorPosition 0 , 25 ; outside the screen to hide it

	_label_startConnection_get_input:

		callGetPressedKey
		CMP AH , F1_SCAN_CODE
		JE _label_send_invitation

		CMP AH , F2_SCAN_CODE
		JE _label_receive_invitation

		CMP AH , F3_SCAN_CODE
		JE _label_startConnection_exit_game

		callSetCursorPosition 27 , 20
		callPrintString validInputMessage
		callSetCursorPosition 0 , 25 ; outside the screen to hide it

	JMP _label_startConnection_get_input


	_label_send_invitation:
		callSendByte SEND_INVITATION

		callSwitchToTextMode ; clear the screen
		callSetCursorPosition 19 , 10
		callPrintString waitingForResponse

		; wait for other player to tell me he/she received the invitation
		_label_wait_for_acknowledgement:
			callCheckIfReceived
		JNC _label_wait_for_acknowledgement

		callGetReceivedByte ; received ACKNOWLEDGMENT

		CALL sendPlayer1Name

		_label_wait_for_response:
			callCheckIfReceived
		JNC _label_wait_for_response

		callGetReceivedByte

		CMP receivedByte , ACCEPT_INVITATION
		JE _label_invitation_accepted
		
		CMP receivedByte , REJECT_INVITATION
		JE _label_invitation_rejected

		_label_invitation_accepted:
			CALL receivePlayer2Name

		JMP _label_startConnection_finished

		_label_invitation_rejected:
			callSetCursorPosition 13 , 13
			callPrintString rejectionMessage
			callDelayInSeconds 3
		JMP _label_startConnection_exit_game


	_label_receive_invitation:
		callCheckIfReceived
		JNC _label_receive_invitation

		callGetReceivedByte
		callSendByte ACKNOWLEDGMENT

		CALL receivePlayer2Name

		callSwitchToTextMode


		callSetCursorPosition 28 , 10

		callPrintString NamePlayer2
		callPrintString playerWantsToConnectMessage

		callSetCursorPosition 15 , 15
		callPrintString acceptInvitationMessage

		callSetCursorPosition 45 , 15
		callPrintString rejectInvitationMessage
		
		callSetCursorPosition 0 , 25 ; outside the screen to hide it

		_label_get_input:
			callGetPressedKey

			CMP AH , F1_SCAN_CODE
			JE _label_accept_invitation

			CMP AH , F2_SCAN_CODE
			JE _label_reject_invitation

			callSetCursorPosition 27 , 20
			callPrintString validInputMessage
			callSetCursorPosition 0 , 25 ; outside the screen to hide it
		JMP _label_get_input

		_label_accept_invitation:
			callSendByte ACCEPT_INVITATION

			CALL sendPlayer1Name

			CALL swapPlayersPositions

			JMP _label_startConnection_finished


		_label_reject_invitation:
			callSendByte REJECT_INVITATION
			JMP _label_startConnection_exit_game


	_label_startConnection_exit_game:
		MOV exitFlag , true

	_label_startConnection_finished:

	POPA
	RET
startConnection ENDP


swapPlayersPositions PROC

	XCHG_MEMORY_WORD Player1.position_x , Player2.position_x
	XCHG_MEMORY_WORD Player1.position_y , Player2.position_y

	XCHG_MEMORY_WORD Player1.respawn_x , Player2.respawn_x
	XCHG_MEMORY_WORD Player1.respawn_y , Player2.respawn_y

	XCHG_MEMORY_BYTE Player1.name_position  , Player2.name_position
	XCHG_MEMORY_BYTE Player1.lives_position , Player2.lives_position
	XCHG_MEMORY_BYTE Player1.score_position , Player2.score_position

	RET
swapPlayersPositions ENDP


receivePlayer2Name PROC
	PUSHA

	MOV DI , 0

	_label_receivePlayer2Name_receive:
		callCheckIfReceived
	JNC _label_receivePlayer2Name_receive

		callGetReceivedByte
		MOV_MEMORY_BYTE DS:NamePlayer2[DI] , receivedByte
		INC DI
		CMP DI , 7
	JNE _label_receivePlayer2Name_receive

	POPA
	RET
receivePlayer2Name ENDP


sendPlayer1Name PROC
	PUSHA

	MOV DI , 0

	_label_sendPlayer1Name_send:
		callSendByte DS:NamePlayer1[DI]
		INC DI
		CMP DI , 7
	JNE _label_sendPlayer1Name_send

	POPA
	RET
sendPlayer1Name ENDP


printPlayersNames PROC
	PUSH AX

	MOV AL , Player1.name_position
	callSetCursorPosition AL , 0
	callPrintString NamePlayer1
	ADD AL , 6
	callSetCursorPosition AL , 0
	callPrintChar ':'

	MOV AL , Player2.name_position
	callSetCursorPosition AL , 0
	callPrintString NamePlayer2
	ADD AL , 6
	callSetCursorPosition AL , 0
	callPrintChar ':'

	POP AX
	RET
printPlayersNames ENDP


updateScoreBar PROC

	; Print Player1 score
	callSetCursorPosition Player1.score_position , 0
	callClearCharacters 4
	callPrintNumber Player1.score

	; Print Player1 lives
	callSetCursorPosition Player1.lives_position , 0
	callPrintNumber Player1.lives


	; Print Player2 score
	callSetCursorPosition Player2.score_position , 0
	callClearCharacters 4
	callPrintNumber Player2.score

	; Print Player2 lives
	callSetCursorPosition Player2.lives_position , 0
	callPrintNumber Player2.lives

	RET
updateScoreBar ENDP

printTime PROC

	callSetCursorPosition 19 , 0

	callClearCharacters 4
    
	callPrintNumber gameTimer

	RET
printTime ENDP

explodeBlock PROC

	; Parameters:
	; BX -> X
	; AX -> Y
	; DL -> whoseBomb

	; return block position in grid array in DI
	CALL getGridElementIndex

	MOV CL , DS:grid[DI]

	CMP CL , X
	JE _label_explodeBlock_finish

	; Remove the LSB (Least Significant Bit) and MSB (Most Significant Bit)
	; This explodes the brick because the brick's value is 10000001
	; Since we were OR-ing the brick with the powerups to indicate that there is a powerup under the brick
	; Therefore by removing LSB and MSB it returns to its initial condition (ex: C_B -> C )
	AND CL , NOT B ; NOT B = 01111110

	; Update the grid with the new block CL
	MOV DS:grid[DI] , CL

	CALL drawBlockAfterExplosion

	_label_explodeBlock_finish:
	RET
explodeBlock ENDP



updateGrid PROC

	; Parameters:
	; BX -> x
	; AX -> y
	; CL -> newData

	CALL getGridElementIndex 
	MOV DS:grid[DI] , CL

	RET
updateGrid ENDP


drawBlockAfterExplosion PROC

	; Parameters:
	; BX -> X
	; AX -> Y
	; CL -> BlockType (ground , coin ... )
	; DL -> whoseBomb

	CMP CL , G  
	JE _label_drawBlock_Ground
	
	CMP CL , C  
	JE _label_drawBlock_Coin
	
	CMP CL , H  
	JE _label_drawBlock_Heart
	
	CMP CL , P  
	JE _label_drawBlock_Powerup_bomb

	CMP CL , P1
	JE _label_drawBlock_Player1
	
	CMP CL , P2
	JE _label_drawBlock_Player2

	RET

	_label_drawBlock_Ground:
		callClearBlock BX , AX
	RET
	
	_label_drawBlock_Coin:
		callDrawImage BX , AX , coinData
	RET
	
	_label_drawBlock_Heart:
		callDrawImage BX , AX , HPData
	RET

	_label_drawBlock_Powerup_bomb:
		callDrawImage BX , AX , PowerUpData
	RET
	
	_label_drawBlock_Player1:
		CALL Player1Died
	RET
	
	_label_drawBlock_Player2:
		CALL Player2Died
	RET
	
drawBlockAfterExplosion ENDP



; finds the index of a block in the grid by its x , y screen coordinates
; @Return the index in DI
getGridElementIndex PROC
	; Parameters:
	; BX -> X
	; AX -> Y

	PUSH AX
	PUSH BX
	PUSH CX

	; Increment by 1 to convert coordinates from 0-based to 1-based
	INC AX
	INC BX

	; Shift Right By 4 = Division by 2^4 = Division by 16
	; Where 16 is the width/height of each block in the grid
	; i.e. Convert from Screen Coordinates to 2D grid coordinates
	MOV CL , 4
	SHR AX , CL
	SHR BX , CL

	DEC AX
	
	; To convert from 2D array (N columns * M rows) to 1D array
	; 1D = N*(Row-1) + Column

	MOV CL , GRID_WIDTH
	MUL CL ; AX = AL * CL -> (Row-1)*N
	ADD AX , BX ; (Row-1)*N + Column

	; The Result
	MOV DI , AX

	POP CX
	POP BX
	POP AX

	RET
getGridElementIndex ENDP


; Loads all small (16px * 16px) images into memory to use them
loadImages PROC
	; Load bomb
	callOpenFile bombFilename , bombFileHandle
	callLoadImageData bombFileHandle , bombData
	callCloseFile bombFileHandle

	; Load bomber man
	callOpenFile bomberManFilename , bomberManFileHandle
	callLoadImageData bomberManFileHandle , bomberManData
	callCloseFile bomberManFileHandle

	; Load coin powerup
	callOpenFile coinFilename , coinFileHandle
	callLoadImageData coinFileHandle , coinData
	callCloseFile coinFileHandle
	
	; Load heart powerup
	callOpenFile HPFilename , HPFileHandle
	callLoadImageData HPFileHandle , HPData
	callCloseFile HPFileHandle
	
	; Load bomb powerup
	callOpenFile PowerUpFilename , PowerUpFileHandle
	callLoadImageData PowerUpFileHandle , PowerUpData
	callCloseFile PowerUpFileHandle
	
	; Load heart score bar icon
	callOpenFile heartIconFilename , heartIconFileHandle
	callLoadImageData heartIconFileHandle , heartIconData
	callCloseFile heartIconFileHandle
	
	RET
loadImages ENDP


playBombSound PROC NEAR
	PUSHA

	MOV DX , 2000       ; Number of times to repeat whole routine.

	MOV BX , 1          ; Frequency value.

	MOV AL , 10110110b  ; The Magic Number (use this binary number only)
	OUT 43H , AL        ; Send it to the initializing port 43H Timer 2.

	NEXT_FREQUENCY:     ; This is were we will jump back to 2000 times.

		MOV AX , BX     ; Move our Frequency value into AX.

		OUT 42h , AL    ; Send LSB to port 42h.
		MOV AL , AH     ; Move MSB into AL  
		OUT 42h , AL    ; Send MSB to port 42h.

		IN  AL , 61H        ; Get current value of port 61H.
		OR  AL , 00000011b  ; OR AL to this value, forcing first two bits high.
		OUT 61h , AL        ; Copy it to port 61H of the PPI Chip
                            ; to turn ON the speaker.

		MOV CX , 100        ; Repeat loop 100 times
		DELAY_LOOP:         ; Here is where we loop back too.
		LOOP DELAY_LOOP     ; Jump repeatedly to DELAY_LOOP until CX = 0


		INC BX  ; Incrementing the value of BX lowers 
                ; the frequency each time we repeat the whole routine

		DEC DX  ; Decrement repeat routine count

	CMP DX , 0          ; Is DX (repeat count) = to 0
	JNZ NEXT_FREQUENCY  ; If not jump to NEXT_FREQUENCY
	                    ; and do whole routine again.
	
	                    ; Else DX = 0 time to turn speaker OFF

	IN  AL , 61h        ; Get current value of port 61H.
	AND AL , 11111100b  ; AND AL to this value, forcing first two bits low.
	OUT 61h , AL        ; Copy it to port 61H of the PPI Chip

	POPA
	RET
playBombSound ENDP


inlineChat PROC

	; Prepare windows' sizes for the chatting
	MOV windowOneStartX , 0
	MOV windowOneEndX , 18
	MOV windowOneStartY , 20
	MOV windowOneEndY , 24
	MOV WindowOneColor , 0

	MOV windowTwoStartX , 21
	MOV windowTwoEndX , 39
	MOV windowTwoStartY , 20
	MOV windowTwoEndY , 24
	MOV WindowTwoColor , 0

	; Separating column between the two chatting windows
	callDrawColumnUp 02 , 12 , 154 , 160 , 200 

	CALL Chat

	RET
inlineChat ENDP


Player1Died PROC

	; Parameters :
	; DL -> whoseBomb

	DEC Player1.lives
	CMP Player1.lives , 0
	JNE _label_P1_Died_still_have_lives

		MOV exitFlag , true
		JMP _label_P1_Died_finish

	_label_P1_Died_still_have_lives:

		callClearBlock Player1.position_x , Player1.position_y
		callUpdateGrid Player1.position_x , Player1.position_y , G
		
		MOV_MEMORY_WORD Player1.position_x , Player1.respawn_x
		MOV_MEMORY_WORD Player1.position_y , Player1.respawn_y
		MOV bomb1.level , BOMB_LEVEL_1

		callUpdateGrid Player1.position_x , Player1.position_y , P1
		callDrawImage Player1.position_x , Player1.position_y , bomberManData

		CMP DL , PLAYER_2_BOMB
		JE _label_P1_Died_increase_P2_score

		CALL decreaseScore_Player1
		JMP _label_P1_Died_finish

		_label_P1_Died_increase_P2_score:
			ADD Player2.score , DYING_PENALTY_SCORE
		

	_label_P1_Died_finish:
	RET

Player1Died ENDP



Player2Died PROC

	; Parameters :
	; DL -> whoseBomb

	DEC Player2.lives
	CMP Player2.lives , 0
	JNE _label_P2_Died_still_have_lives

		MOV exitFlag , true
		JMP _label_P2_Died_finish

	_label_P2_Died_still_have_lives:

		callClearBlock Player2.position_x , Player2.position_y
		callUpdateGrid Player2.position_x , Player2.position_y , G
		
		MOV_MEMORY_WORD Player2.position_x , Player2.respawn_x
		MOV_MEMORY_WORD Player2.position_y , Player2.respawn_y
		MOV bomb2.level , BOMB_LEVEL_1
		
		callUpdateGrid Player2.position_x , Player2.position_y , P2
		callDrawImage Player2.position_x , Player2.position_y , bomberManData

		CMP DL , PLAYER_1_BOMB
		JE _label_P2_Died_increase_P1_score

		CALL decreaseScore_Player2
		JMP _label_P2_Died_finish

		_label_P2_Died_increase_P1_score:
			ADD Player1.score , DYING_PENALTY_SCORE

	_label_P2_Died_finish:
	RET

Player2Died ENDP


decreaseScore_Player1 PROC

	CMP Player1.score , DYING_PENALTY_SCORE
	JB _label_decreaseScore_P1_zero_score
	SUB Player1.score , DYING_PENALTY_SCORE

	RET

	_label_decreaseScore_P1_zero_score:
		MOV Player1.score , 0

	RET
decreaseScore_Player1 ENDP


decreaseScore_Player2 PROC

	CMP Player2.score , DYING_PENALTY_SCORE
	JB _label_decreaseScore_P2_zero_score
	SUB Player2.score , DYING_PENALTY_SCORE

	RET

	_label_decreaseScore_P2_zero_score:
		MOV Player2.score , 0

	RET
decreaseScore_Player2 ENDP


; initialize variables data
initializeData PROC

	; Player 1 Data
	MOV Player1.position_x , 288
	MOV Player1.position_y , 128
	MOV Player1.respawn_x , 288
	MOV Player1.respawn_y , 128
	MOV Player1.score , 0
	MOV Player1.lives , 3
	MOV Player1.name_position , 24
	MOV Player1.lives_position , 39
	MOV Player1.score_position , 31

	; Player 2 Data
	MOV Player2.position_x , 16
	MOV Player2.position_y , 32
	MOV Player2.respawn_x , 16
	MOV Player2.respawn_y , 32
	MOV Player2.score , 0
	MOV Player2.lives , 3
	MOV Player2.name_position , 0
	MOV Player2.lives_position , 15
	MOV Player2.score_position , 7

	; Bomb Level
	MOV bomb1.level , BOMB_LEVEL_1
	MOV bomb2.level , BOMB_LEVEL_1

	MOV gameTimer , 150
	MOV exitFlag , false

	RET
initializeData ENDP



; Legend:
; 0 -> Bomb 
; B -> bomb_x , bomb_y
; x -> start_x , start_y of surrounding blocks
; 0 , 1 , 2 , 3 , 4 are blocks which explode in BOMB_LEVEL_1
; 0 , 1 , 2 , 3 , 4 , 5 , 6 , 7 , 8 are blocks which explode in BOMB_LEVEL_2
;
;                x______
;                |     |
;                |  8  |
;                x-----+
;                |     |
;                |  4  |
;    x-----x-----B-----x-----x------
;    |  6  |  2  |  0  |  1  |  5  |
;    ------+-----x-----+-----+------
;                |  3  |
;                |     |
;                x-----+
;                |  7  |
;                |     |
;                -------
;
explodeBomb PROC

	; Parameters:
	; BX -> bomb_x
	; AX -> bomb_y
	; CL -> BombLevel
	; DL -> whoseBomb

	CALL playBombSound

	CMP CL , BOMB_LEVEL_2
	JNE _label_explodeBomb_level1
	
	; We check for grid boundary conditions in BOMB_LEVEL_2 only
	; Because they are already handled in BOMB_LEVEL_1
	; As there are unbreakable blocks (X) surrounding the grid
	_label_explodeBomb_level2:

		ADD BX , BLOCK_WIDTH*2
		CMP BX , GRID_BOUNDARY_RIGHT
		JE _label_skip_boundary_right
			callExplodeBlock DL ; Right (block 5)
		_label_skip_boundary_right:

		SUB BX , BLOCK_WIDTH*4
		CMP BX , GRID_BOUNDARY_LEFT - BLOCK_WIDTH
		JE _label_skip_boundary_left
			callExplodeBlock DL ; Left (block 6)
		_label_skip_boundary_left:

		ADD BX , BLOCK_WIDTH*2 ; return to original position

		ADD AX , BLOCK_HEIGHT*2
		CMP AX , GRID_BOUNDARY_DOWN
		JE _label_skip_boundary_down
			callExplodeBlock DL ; Down (block 7)
		_label_skip_boundary_down:

		SUB AX , BLOCK_HEIGHT*4
		CMP AX , GRID_BOUNDARY_UP - BLOCK_HEIGHT
		JE _label_skip_boundary_up
			callExplodeBlock DL ; Up (block 8)
		_label_skip_boundary_up:

		ADD AX , BLOCK_HEIGHT*2 ; return to original position
		

	_label_explodeBomb_level1:

		; The player put a bomb but did not move
		callExplodeBlock DL ; Bomb's place (block 0)

		ADD BX , BLOCK_WIDTH
		callExplodeBlock DL ; Right (block 1)
		SUB BX , BLOCK_WIDTH*2
		callExplodeBlock DL ; Left (block 2)
		
		ADD BX , BLOCK_WIDTH ; return to original position

		ADD AX , BLOCK_HEIGHT
		callExplodeBlock DL ; Down (block 3)
		SUB AX , BLOCK_HEIGHT*2
		callExplodeBlock DL ; Up (block 4)

		ADD AX , BLOCK_HEIGHT ; return to original position

		callUpdateGrid BX , AX , G
		callClearBlock BX , AX
	RET
explodeBomb ENDP



takePowerupIfAny_Player1 PROC

	; Parameters
	; CL -> PowerupType 

	CMP CL , C
	JE _label_increment_score1_P1

	CMP CL , H
	JE _label_increment_lives_P1

	CMP CL , P
	JE _label_bomb_powerup_P1

	RET

	_label_increment_score1_P1:
		ADD Player1.score , COIN_SCORE
	RET

	_label_increment_lives_P1:
		INC Player1.lives
	RET

	_label_bomb_powerup_P1:
		MOV bomb1.level , BOMB_LEVEL_2
	RET

takePowerupIfAny_Player1 ENDP



moveIfAvailable_Player1 PROC

	; Parameters:
	; BP -> direction

	MOV BX , Player1.position_x
	MOV AX , Player1.position_y
	
	ADD BX , DS:[BP][0] ; x = x + deltaX (direction in x)
	ADD AX , DS:[BP][2] ; y = y + deltaY (direction in y)

	CALL getGridElementIndex
	MOV DL , DS:grid[DI]
	SHL DL , 1 ;shift to check if it's an unmovable place ( block or brick )
	JC _label_moveIfAvailable_P1_not_move

		; The bomb exists in the grid but we draw it only if the player moved
		; in order not draw it above him
		CMP bomb1.to_be_drawn , true
		JE _label_moveIfAvailable_P1_draw_bomb

			callClearBlock Player1.position_x , Player1.position_y
			callUpdateGrid Player1.position_x , Player1.position_y , G

		JMP _label_moveIfAvailable_P1_move
		
		_label_moveIfAvailable_P1_draw_bomb:
			callDrawImage bomb1.bomb_x , bomb1.bomb_y , bombData
			callUpdateGrid bomb1.bomb_x , bomb1.bomb_y , B1
			MOV bomb1.to_be_drawn , false

	_label_moveIfAvailable_P1_move:
		MOV Player1.position_x , BX
		MOV Player1.position_y , AX

		callTakePowerupIfAny_Player1 DS:grid[DI]

		callDrawImage Player1.position_x , Player1.position_y , bomberManData
		callUpdateGrid Player1.position_x , Player1.position_y , P1

	_label_moveIfAvailable_P1_not_move:
	RET
moveIfAvailable_Player1 ENDP


putBomb_Player1 PROC

	CMP bomb1.counter , BOMB_TIME_TO_EXPLODE ; can only add a single bomb
	JB _label_putBomb_P1_finish
	
	MOV_MEMORY_WORD bomb1.bomb_x , Player1.position_x
	MOV_MEMORY_WORD bomb1.bomb_y , Player1.position_y

	MOV bomb1.to_be_drawn , true
	MOV bomb1.counter , 0

	callUpdateGrid Player1.position_x , Player1.position_y , P1_B1

	_label_putBomb_P1_finish:
	RET
putBomb_Player1 ENDP



takePowerupIfAny_Player2 PROC

	; Parameters
	; CL -> PowerupType 

	CMP CL , C
	JE _label_increment_score2_P2

	CMP CL , H
	JE _label_increment_lives_P2

	CMP CL , P
	JE _label_bomb_powerup_P2

	RET

	_label_increment_score2_P2:
		ADD Player2.score , COIN_SCORE
	RET

	_label_increment_lives_P2:
		INC Player2.lives
	RET

	_label_bomb_powerup_P2:
		MOV bomb2.level , BOMB_LEVEL_2
	RET

takePowerupIfAny_Player2 ENDP



moveIfAvailable_Player2 PROC

	; Parameters:
	; BP -> direction

	MOV BX , Player2.position_x
	MOV AX , Player2.position_y
	
	ADD BX , DS:[BP][0] ; x = x + deltaX (direction in x)
	ADD AX , DS:[BP][2] ; y = y + deltaY (direction in y)

	CALL getGridElementIndex
	MOV DL , DS:grid[DI]
	SHL DL , 1 ;shift to check if it's an unmovable place ( block or brick )
	JC _label_moveIfAvailable_P2_not_move
	
		; The bomb exists in the grid but we draw it only if the player moved
		; in order not draw it above him
		CMP bomb2.to_be_drawn , true
		JE _label_moveIfAvailable_P2_draw_bomb

			callClearBlock Player2.position_x , Player2.position_y
			callUpdateGrid Player2.position_x , Player2.position_y , G

		JMP _label_moveIfAvailable_P2_move
		
		_label_moveIfAvailable_P2_draw_bomb:
			callDrawImage bomb2.bomb_x , bomb2.bomb_y , bombData
			callUpdateGrid bomb2.bomb_x , bomb2.bomb_y , B2
			MOV bomb2.to_be_drawn , false

	_label_moveIfAvailable_P2_move:
		MOV Player2.position_x , BX
		MOV Player2.position_y , AX

		callTakePowerupIfAny_Player2 DS:grid[DI]

		callDrawImage Player2.position_x , Player2.position_y , bomberManData
		callUpdateGrid Player2.position_x , Player2.position_y , P2

	_label_moveIfAvailable_P2_not_move:
	RET
moveIfAvailable_Player2 ENDP


putBomb_Player2 PROC

	CMP bomb2.counter , BOMB_TIME_TO_EXPLODE ; can only add a single bomb
	JB _label_putBomb_P2_finish
	
	MOV_MEMORY_WORD bomb2.bomb_x , Player2.position_x
	MOV_MEMORY_WORD bomb2.bomb_y , Player2.position_y

	MOV bomb2.to_be_drawn , true
	MOV bomb2.counter , 0

	callUpdateGrid Player2.position_x , Player2.position_y , P2_B2

	_label_putBomb_P2_finish:
	RET
putBomb_Player2 ENDP



END