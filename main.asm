.Model Small
.386 ; sets the instruction set of 80386 prosessor
.Stack 2048
.Data
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;nn
INDATAP1 DB 13,?, 13 DUP('$')
INDATAP2 DB 13,?, 13 DUP('$')
ERRORMSG DB 'PLEASE ENTER YOUR NAME WITHOUT SPECIAL CHARACTERS OR NUMBERS AT FIRST','$'
ENTERMSG DB 'PLEASE ENTER YOUR NAME','$'
TRICKYMSG DB '                        ','$'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;nn
INCLUDE inout.inc

; This is an external PROC that is defined in welcome.asm
; The linker will join them
EXTRN displayWelcomeScreen:NEAR
EXTRN MenuScreen:NEAR
EXTRN music:NEAR
PUBLIC INDATAP1
PUBLIC INDATAP2
.Code
MAIN PROC FAR

	CALL initializeDataSegment
	
	callSwitchToGraphicsMode
    call music
	CALL displayWelcomeScreen
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;N
	callSwitchToTextMode
	CALL GETP1NAME
	CALL GETP2NAME
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;N
	CALL MenuScreen
	
	; Press any key to exit
	callSwitchToTextMode
	CALL exit
    
MAIN ENDP


initializeDataSegment PROC

    MOV AX , @DATA
    MOV DS , AX
	
	RET
initializeDataSegment ENDP


exit PROC
    ; return control to operating system
    MOV AH , 4ch
    INT 21H
exit ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;N
GETP1NAME PROC
 
 pusha   
          MOV AH,2
		  MOV DL,10
		  MOV DH,10
		  INT 10H
          MOV AH,9
		  MOV DX,OFFSET ENTERMSG
		  INT 21H
 LABLE:
          MOV AH,2
		  MOV DL,10
		  MOV DH,12
		  INT 10H
          MOV AH,9
		  MOV DX,OFFSET TRICKYMSG
		  INT 21H
		  
		  
          MOV AH,2
		  MOV DL,10
		  MOV DH,12
		  INT 10H
          MOV AH,0AH
          MOV DX,OFFSET INDATAP1	 
          INT 21H
		  
		  MOV BX,OFFSET INDATAP1
		  MOV AL,'A'
          CMP [BX+2],AL
          JAE CHECK
          JMP CHECK1

		  
CHECK:   
          MOV AL ,'Z'
          CMP [BX+2],AL
		  JBE  DONE
		  
CHECK1:
         MOV AL,'a'	
         CMP [BX+2],AL		 
		 JAE CHECK2
         JMP REPEATE
CHECK2:
		  MOV AL ,'z'
          CMP [BX+2],AL
		  JBE  DONE
          
REPEATE:		  
          MOV AH,2
		  MOV DL,4
		  MOV DH,24
		  INT 10H
          MOV AH,9
		  MOV DX,OFFSET ERRORMSG
		  INT 21H
		  JMP LABLE
		  
		  
          


DONE:	  	  
          POPA

            RET
GETP1NAME     ENDP			
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;N
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;N
GETP2NAME PROC
 
 pusha    
          MOV AH,2
		  MOV DL,50
		  MOV DH,10
		  INT 10H
          MOV AH,9
		  MOV DX,OFFSET ENTERMSG
		  INT 21H
 LABLE2:  
          

		  MOV AH,2
		  MOV DL,50
		  MOV DH,12
		  INT 10H
          MOV AH,9
		  MOV DX,OFFSET TRICKYMSG
		  INT 21H
		  
          MOV AH,2
		  MOV DL,50
		  MOV DH,12
		  INT 10H
          MOV AH,0AH
          MOV DX,OFFSET INDATAP2	 
          INT 21H
		  
		  MOV BX,OFFSET INDATAP2
		  MOV AL,'A'
          CMP [BX+2],AL
          JAE CHECK_2
          JMP CHECK1_2

		  
CHECK_2:   
          MOV AL ,'Z'
          CMP [BX+2],AL
		  JBE  DONE2
		  
CHECK1_2:
         MOV AL,'a'	
         CMP [BX+2],AL		 
		 JAE CHECK2_2
         JMP REPEATE2
CHECK2_2:
		  MOV AL ,'z'
          CMP [BX+2],AL
		  JBE  DONE2
          
REPEATE2:
          
		  		  
          MOV AH,2
		  MOV DL,4
		  MOV DH,24
		  INT 10H
          MOV AH,9
		  MOV DX,OFFSET ERRORMSG
		  INT 21H
		  JMP LABLE2
		  
		  
          


DONE2:	  	  
          POPA

            RET
GETP2NAME     ENDP			
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;N


END MAIN