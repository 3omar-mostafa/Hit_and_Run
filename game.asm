.MODEL SMALL
.STACK 2048
.386 ; sets the instruction set of 80386 processor

PUBLIC Game
INCLUDE inout.inc
INCLUDE draw.inc
	BLOCK_WIDTH EQU 16
	BLOCK_HEIGHT EQU 16

	IMAGE_WIDTH EQU BLOCK_WIDTH
	IMAGE_HEIGHT EQU BLOCK_HEIGHT

	true EQU 1
	false EQU 0
	PLAYER_1_BOMB EQU 1
	PLAYER_2_BOMB EQU 2
	BOMB_TIME_TO_EXPLODE EQU 2
	exitFlag DB false

	bomberManFilename DB "images\bomber.img", 0
	bomberManFileHandle DW ?
	bomberManData DB IMAGE_WIDTH*IMAGE_HEIGHT dup(?)
	
	bombFilename DB "images\bomb.img", 0
	bombFileHandle DW ?
	bombData DB IMAGE_WIDTH*IMAGE_HEIGHT dup(?)
	
	bomb STRUC
		bomb_x DW 0
		bomb_y DW 0

		to_be_drawn DB false
		counter DB BOMB_TIME_TO_EXPLODE + 1 ; count seconds passed after putting the bomb (used to know when to explode)
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
	     DB  X  ,  G  ,  G  ,  B  ,  B  ,  B  ,  B  ,  B  ,  B  ,  B  ,  B  ,  B  ,  B  ,  B  ,  B  ,  B  ,  B  ,  B  ,  B  ,  X ; 1
	     DB  X  ,  G  ,  X  ,  B  ,  X  ,  G  ,  X  ,  B  ,  X  ,  G  ,  G  ,  X  ,  B  ,  X  ,  G  ,  X  ,  B  ,  X  ,  G  ,  X ; 2
	     DB  X  ,  B  ,  B  ,  B  ,  B  ,  B  ,  B  ,  B  ,  B  ,  B  ,  B  ,  B  ,  B  ,  B  ,  B  ,  B  ,  B  ,  B  ,  B  ,  X ; 3
	     DB  X  ,  G  ,  X  ,  B  ,  X  ,  G  ,  X  ,  B  ,  X  ,  G  ,  G  ,  X  ,  B  ,  X  ,  G  ,  X  ,  B  ,  X  ,  G  ,  X ; 4
	     DB  X  ,  B  ,  B  ,  B  ,  B  ,  B  ,  B  ,  B  ,  B  ,  B  ,  B  ,  B  ,  B  ,  B  ,  B  ,  B  ,  B  ,  B  ,  B  ,  X ; 5
	     DB  X  ,  G  ,  X  ,  B  ,  X  ,  G  ,  X  ,  B  ,  X  ,  G  ,  G  ,  X  ,  B  ,  X  ,  G  ,  X  ,  B  ,  X  ,  G  ,  X ; 6
	     DB  X  ,  B  ,  B  ,  B  ,  B  ,  B  ,  B  ,  B  ,  B  ,  B  ,  B  ,  B  ,  B  ,  B  ,  B  ,  B  ,  B  ,  G  ,  G  ,  X ; 7
	     DB  X  ,  X  ,  X  ,  X  ,  X  ,  X  ,  X  ,  X  ,  X  ,  X  ,  X  ,  X  ,  X  ,  X  ,  X  ,  X  ,  X  ,  X  ,  X  ,  X ; 8
 

.CODE

Game PROC
	CALL loadImages
	
	callSwitchToGraphicsMode

	callOpenFile gridFilename , gridFileHandle
	callDrawLargeImage gridFileHandle , 0 , 16 , 320 , 144
	callCloseFile gridFileHandle
	GameLoop:
	_label_Game_loop_end:
	CMP exitFlag , true
	JNE GameLoop
	_label_exit:
		RET
Game ENDP


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

	RET
loadImages ENDP
END