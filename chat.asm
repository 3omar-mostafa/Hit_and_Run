.Model Small
.386
.Stack 1024
.DATA
ESC_ASCII EQU 27
Enter_ASCII EQU 13
backSpace_ASCII EQU 8

windowWidth EQU 79
windowHeight EQU 12

windowUpStartY EQU 0
windowUpEndY EQU 12

windowDownStartY EQU 13
windowDownEndY EQU 24

KeyValue DB ?

cursorX_Up DB 0
cursorY_Up DB 0

cursorX_Down DB 0
cursorY_Down DB 13


.CODE
; The screen is splited into two haves : WindowUp , WindowDown

PUBLIC Chat
PUBLIC KeyValue
PUBLIC initializeUART
PUBLIC prepareSend
PUBLIC sendChar
PUBLIC checkReceived
PUBLIC receiveChar



Chat PROC

MOV AX , @DATA
MOV DS , AX

CALL switchToTextMode ; To clear the screen
CALL initializeUART
CALL initializeWindow
CALL setCursorUp

mainLoop:
    MOV AL , 0
    CALL checkPressedKey
    CMP AL , 0
    JE receive

    CALL prepareSend
    CALL getPressedKey
    CALL sendChar

    CMP KeyValue , backSpace_ASCII
    JE _label_backspace_up

    CMP KeyValue , Enter_ASCII
    JE _label_enter_up

    JMP _label_normalChar_up

    _label_backspace_up:
        CALL printBackspaceUp
    JMP receive

    _label_enter_up:
        CALL printEnterUp
    JMP receive

    _label_normalChar_up:
    CALL incrementCursorUp  ;printing (printChar) increments the cursor by itself
    CALL printChar          ;But increment it by ourselves (incrementCursorUp) to handle the cusor in the two windows

    receive:
    CALL checkReceived
    CMP AL , 0
    JE endLoop

    CALL receiveChar
    CMP KeyValue , backSpace_ASCII
    JE _label_backspace_down

    CMP KeyValue , Enter_ASCII
    JE _label_enter_down

    JMP _label_normalChar_down

    _label_backspace_down:
        CALL printBackspaceDown
    JMP receive

    _label_enter_down:
        CALL printEnterDown
    JMP receive

    _label_normalChar_down:
    CALL incrementCursorDown ;printing (printRecievedChar) increments the cursor by itself
    CALL printRecievedChar   ;But increment it by ourselves (incrementCursorDown) to handle the cusor in the two windows

endLoop:
CMP KeyValue , ESC_ASCII
JNE mainLoop

CALL switchToTextMode ; To clear the screen

RET
Chat ENDP


initializeUART PROC
PUSHA

    ; Set Divisor Latch Access Bit
    MOV DX,3fbh ; Line Control Register
    MOV AL,10000000b ;Set Divisor Latch Access Bit
    OUT DX,AL ;Out it

    ;Set LSB byte of the Baud Rate Divisor Latch register.
    MOV DX,3f8h
    MOV AL,0ch
    OUT DX,AL

    ;Set MSB byte of the Baud Rate Divisor Latch register.
    MOV DX,3f9h
    MOV AL,00h
    OUT DX,AL

    ; Baud rate is 9600

    ;Set port configuration
    MOV DX,3fbh
    MOV AL,00011011b
    ;0:Access to Receiver buffer, Transmitter buffer
    ;0:Set Break disabled
    ;011:Even Parity
    ;0:One Stop Bit
    ;11:8bits
    OUT DX,AL

POPA
RET
initializeUART ENDP


scrollWindowUp PROC
PUSHA

    MOV AH,6 ; function 6
    MOV AL,1 ; scroll by 1 line
    MOV BH , 01FH ; White Text on Blue Background , 1 is blue , F is white
    MOV CH,0 ; upper left Y
    MOV CL,0 ; upper left X
    MOV DH,windowUpEndY ; lower right Y
    MOV DL,windowWidth ; lower right X
    INT 10h

    DEC cursorY_Up ; Scroll increments y so we decrement it to remain at the same line
    MOV cursorX_Up , 0
    CALL setCursorUp

POPA
RET
scrollWindowUp ENDP


scrollWindowDown PROC
PUSHA

    MOV AH,6 ; function 6
    MOV AL,1 ; scroll by 1 line
    MOV BH , 04FH ; White Text on Red Background , 4 is red , F is white
    MOV CH,13 ; upper left Y
    MOV CL,0 ; upper left X
    MOV DH,windowDownEndY ; lower right Y
    MOV DL,windowWidth ; lower right X
    INT 10h

    DEC cursorY_Down ; Scroll increments y so we decrement it to remain at the same line
    MOV cursorX_Down , 0
    CALL setCursorDown

POPA
RET
scrollWindowDown ENDP

switchToTextMode PROC
PUSHA

    MOV AH,0          
    MOV AL,03h
    INT 10h

POPA
RET
switchToTextMode ENDP

initializeWindow PROC
PUSHA

    CALL setCursorUp

    MOV AH,9 ;Display
    MOV BH,0 ;Page 0
    MOV AL,' '
    MOV CX,1040 ;1040 = 13*80
    MOV BL,01Fh ;White Text on Blue background , 1 is blue , F is white
    INT 10h

    CALL setCursorDown

    MOV AH,9 ;Display
    MOV BH,0 ;Page 0
    MOV AL,' '
    MOV CX,960 ;960 = 12*80
    MOV BL,04Fh ;White text on Red background , 4 is red , F is white
    INT 10h
POPA
RET
initializeWindow ENDP


; return AH -> scancode , AL -> ASCII code
getPressedKey PROC
PUSHA

    MOV AH , 0
    INT 16H
    MOV KeyValue , AL

POPA
RET
getPressedKey ENDP

; return AH -> scancode , AL -> ASCII code
checkPressedKey PROC

    MOV AH , 1
    INT 16H

RET
checkPressedKey ENDP


printEnterUp PROC
PUSHA

    INC cursorY_Up
    MOV cursorX_Up , 0
    CALL setCursorUp

    CMP cursorY_Up , windowUpEndY
    JNE _label_printEnterUp_skipScrolling
        ; scrolling one line up and set the new cursor
        CALL scrollWindowUp

_label_printEnterUp_skipScrolling:
POPA
RET
printEnterUp ENDP



printEnterDown PROC
PUSHA

    INC cursorY_Down
    MOV cursorX_Down , 0
    CALL setCursorDown

    CMP cursorY_Down , windowDownEndY
    JNE _label_printEnterDown_skipScrolling
        ; scrolling one line up and set the new cursor
        CALL scrollWindowDown

_label_printEnterDown_skipScrolling:
POPA
RET
printEnterDown ENDP

; Deleting is supported till the beginning of the current line
printBackspaceUp PROC
PUSHA

    CALL decrementCursorUp
    MOV AH,2
    MOV DL,' ' ; printing empty space to delete whatever under it
    INT 21h
    CALL setCursorUp ; setting the cursor again because printing move the cursor

POPA
RET
printBackspaceUp ENDP

; Deleting is supported till the beginning of the current line
printBackspaceDown PROC
PUSHA

    CALL decrementCursorDown
    MOV AH,2
    MOV DL,' ' ; printing empty space to delete whatever under it
    INT 21h
    CALL setCursorDown ; setting the cursor again because printing move the cursor

POPA
RET
printBackspaceDown ENDP

printChar PROC
PUSHA

    MOV AH,2
    MOV DL,KeyValue
    INT 21h

POPA
RET
printChar ENDP


printRecievedChar PROC
PUSHA

    MOV AH,2
    MOV DL,KeyValue
    INT 21h

POPA
RET
printRecievedChar ENDP


;@return result in AL
prepareSend PROC

    ;Check that Transmitter Holding Register is Empty
    MOV DX , 3FDH ; Line Status Register
    _label_prepareSend_check:
    IN AL , DX
    TEST AL , 00100000b
    JZ _label_prepareSend_check

RET
prepareSend ENDP

sendChar PROC
PUSHA

    ;If empty put the KeyValue IN Transmit data register
    MOV DX , 3F8H ; Transmit data register
    MOV AL,KeyValue
    OUT DX , AL

POPA
RET
sendChar ENDP

;@return result in AL
checkReceived PROC

    ;Check that Data is Ready
    MOV DX , 3FDH ; Line Status Register
    IN AL , DX
    AND AL , 1

RET
checkReceived ENDP


receiveChar PROC
PUSHA

    ;If Ready read the KeyValue IN Receive data register
    MOV DX , 03F8H
    IN AL , DX
    MOV KeyValue , AL

POPA
RET
receiveChar ENDP



;Move the cursor to (cursorX_Down,cursorY_Down)
setCursorDown PROC
PUSHA

    MOV AH , 2
    MOV BH , 0 ; Page Number
    MOV DL , cursorX_Down
    MOV DH , cursorY_Down
    INT 10h

POPA
RET
setCursorDown ENDP


;Move the cursor to (cursorX_Up,cursorY_Up)
setCursorUp PROC
PUSHA

    MOV AH , 2
    MOV BH , 0 ; Page Number
    MOV DL , cursorX_Up
    MOV DH , cursorY_Up
    INT 10h

POPA
RET
setCursorUp ENDP



incrementCursorUp PROC
PUSHA

CALL setCursorUp

CMP cursorY_Up , windowUpEndY
JNE _label_incrementCursorUp_skipScrolling
    ; scrolling one line up and set the new cursor
    CALL scrollWindowUp

_label_incrementCursorUp_skipScrolling:
    CMP cursorX_Up , windowWidth
    JE _label_incrementCursorUp

    INC cursorX_Up
POPA
RET

_label_incrementCursorUp:
    MOV cursorX_Up , 0
    INC cursorY_Up

POPA
RET
incrementCursorUp ENDP


incrementCursorDown PROC
PUSHA

CALL setCursorDown

CMP cursorY_Down , windowDownEndY
JNE _label_incrementCursorDown_skipScrolling
    ; scrolling one line up and set the new cursor
    CALL scrollWindowDown

_label_incrementCursorDown_skipScrolling:
    CMP cursorX_Down , windowWidth
    JE _label_incrementCursorDown

    INC cursorX_Down
POPA
RET

_label_incrementCursorDown:
    MOV cursorX_Down , 0
    INC cursorY_Down

POPA
RET
incrementCursorDown ENDP

; Decrements the upper window cursor till it reaches the beginning of the  line
; It DOES NOT SUPPORT scrolling to upper line
decrementCursorUp PROC
PUSHA

    CMP cursorX_Up , 0
    JE _label_decrementCursorUp_doNotDecrement

    DEC cursorX_Up
    CALL setCursorUp

_label_decrementCursorUp_doNotDecrement:
POPA
RET
decrementCursorUp ENDP


; Decrements the lower window cursor till it reaches the beginning of the  line
; It DOES NOT SUPPORT scrolling to upper line
decrementCursorDown PROC
PUSHA

    CMP cursorX_Down , 0
    JE _label_decrementCursorDown_doNotDecrement

    DEC cursorX_Down
    CALL setCursorDown

_label_decrementCursorDown_doNotDecrement:
POPA
RET
decrementCursorDown ENDP

END