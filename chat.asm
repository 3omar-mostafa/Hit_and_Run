.Model SMALL
.386
.Stack 2048
.DATA
ESC_ASCII EQU 27
Enter_ASCII EQU 13
backSpace_ASCII EQU 8

windowOneStartX DB 0
windowOneEndX DB 39

windowOneStartY DB 0
windowOneEndY DB 24

WindowOneColor DB 4FH

windowTwoStartX DB 40
windowTwoEndX DB 79

windowTwoStartY DB 0
windowTwoEndY DB 24

WindowTwoColor DB 1FH

KeyValue DB ?

cursorOne_X DB 0
cursorOne_Y DB 0

cursorTwo_X DB 40
cursorTwo_Y DB 0

PUBLIC Chat
PUBLIC KeyValue
PUBLIC initializeUART
PUBLIC prepareSend
PUBLIC sendChar
PUBLIC checkReceived
PUBLIC receiveChar

; These are variables are initailized by the caller
PUBLIC windowOneStartX
PUBLIC windowOneEndX
PUBLIC windowOneStartY
PUBLIC windowOneEndY
PUBLIC WindowOneColor
PUBLIC windowTwoStartX
PUBLIC windowTwoEndX
PUBLIC windowTwoStartY
PUBLIC windowTwoEndY
PUBLIC WindowTwoColor

.CODE
; The screen is splited into two haves : WindowOne , WindowTwo

Chat PROC far

MOV AX , @DATA
MOV DS , AX

CALL initializeCursors
CALL initializeUART
CALL initializeWindow
CALL setCursorOne

mainLoop:
    MOV AL , 0
    CALL checkPressedKey
    CMP AL , 0
    JE receive

    CALL prepareSend
    CALL getPressedKey
    CALL sendChar

    CMP KeyValue , backSpace_ASCII
    JE _label_backspace_one

    CMP KeyValue , Enter_ASCII
    JE _label_enter_one

    JMP _label_normalChar_one

    _label_backspace_one:
        CALL printBackspaceOne
    JMP receive

    _label_enter_one:
        CALL printEnterOne
    JMP receive

    _label_normalChar_one:
    CALL incrementCursorOne  ;printing (printChar) increments the cursor by itself
    CALL printChar           ;But increment it by ourselves (incrementCursorOne) to handle the cusor in the two windows

    receive:
    CALL checkReceived
    CMP AL , 0
    JE endLoop

    CALL receiveChar
    CMP KeyValue , backSpace_ASCII
    JE _label_backspace_two

    CMP KeyValue , Enter_ASCII
    JE _label_enter_two

    JMP _label_normalChar_two

    _label_backspace_two:
        CALL printBackspaceTwo
    JMP receive

    _label_enter_two:
        CALL printEnterTwo
    JMP receive

    _label_normalChar_two:
    CALL incrementCursorTwo ;printing (printChar) increments the cursor by itself
    CALL printChar          ;But increment it by ourselves (incrementCursorTwo) to handle the cusor in the two windows

endLoop:
CMP KeyValue , ESC_ASCII
JNE mainLoop

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

initializeCursors PROC
PUSH AX

MOV AL , windowOneStartX
MOV cursorOne_X , AL

MOV AL , windowOneStartY
MOV cursorOne_Y , AL

MOV AL , windowTwoStartX
MOV cursorTwo_X , AL

MOV AL , windowTwoStartY
MOV cursorTwo_Y , AL

POP AX
RET
initializeCursors ENDP


initializeWindow PROC
PUSHA

    ; scrolls the window size up and down to color them

    MOV AH,6 ; scroll down
    MOV AL,windowOneEndY ; scroll by height of the window line
    SUB AL,windowOneStartY
    ADD AL,1
    MOV BH,WindowOneColor
    MOV CH,windowOneStartY ; oneper one Y
    MOV CL,windowOneStartX ; oneper one X
    MOV DH,windowOneEndY ; lower two Y
    MOV DL,windowOneEndX ; lower two X
    INT 10h

    MOV AH,7 ; scroll up
    INT 10h



    MOV AH,6 ; scroll down
    MOV AL,windowTwoEndY ; scroll by the height of the window
    SUB AL,windowTwoStartY
    ADD AL,1
    MOV BH,WindowTwoColor
    MOV CH,windowTwoStartY ; oneper one Y
    MOV CL,windowTwoStartX ; oneper one X
    MOV DH,windowTwoEndY ; lower two Y
    MOV DL,windowTwoEndX ; lower two X
    INT 10h

    MOV AH,7 ; scroll up
    INT 10h

POPA
RET
initializeWindow ENDP

scrollWindowOne PROC
PUSHA

    MOV AH,6 ; scroll down
    MOV AL,1 ; scroll by 1 line
    MOV BH,WindowOneColor
    MOV CH,windowOneStartY ; oneper one Y
    MOV CL,windowOneStartX ; oneper one X
    MOV DH,windowOneEndY ; lower two Y
    MOV DL,windowOneEndX ; lower two X
    INT 10h

    DEC cursorOne_Y ; Scroll increments y so we decrement it to remain at the same line
    MOV AL , windowOneStartX
    MOV cursorOne_X , AL
    CALL setCursorOne

POPA
RET
scrollWindowOne ENDP


scrollWindowTwo PROC
PUSHA

    MOV AH,6 ; scroll down
    MOV AL,1 ; scroll by 1 line
    MOV BH,WindowTwoColor
    MOV CH,windowTwoStartY ; oneper one Y
    MOV CL,windowTwoStartX ; oneper one X
    MOV DH,windowTwoEndY ; lower two Y
    MOV DL,windowTwoEndX ; lower two X
    INT 10h

    DEC cursorTwo_Y ; Scroll increments y so we decrement it to remain at the same line
    MOV AL , windowTwoStartX
    MOV cursorTwo_X , AL
    CALL setCursorTwo

POPA
RET
scrollWindowTwo ENDP

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


printEnterOne PROC
PUSHA

    INC cursorOne_Y
    MOV AL , windowOneStartX
    MOV cursorOne_X , AL
    CALL setCursorOne

    MOV AL , cursorOne_Y
    CMP AL , windowOneEndY
    JNE _label_printEnterOne_skipScrolling
        ; scrolling one line one and set the new cursor
        CALL scrollWindowOne

_label_printEnterOne_skipScrolling:
POPA
RET
printEnterOne ENDP



printEnterTwo PROC
PUSHA

    INC cursorTwo_Y
    MOV AL , windowTwoStartX
    MOV cursorTwo_X , AL
    CALL setCursorTwo

    MOV AL , cursorTwo_Y
    CMP AL , windowTwoEndY
    JNE _label_printEnterTwo_skipScrolling
        ; scrolling one line one and set the new cursor
        CALL scrollWindowTwo

_label_printEnterTwo_skipScrolling:
POPA
RET
printEnterTwo ENDP

; Deleting is soneported till the beginning of the current line
printBackspaceOne PROC
PUSHA

    CALL decrementCursorOne
    MOV AH,2
    MOV DL,' ' ; printing empty space to delete whatever under it
    INT 21h
    CALL setCursorOne ; setting the cursor again because printing move the cursor

POPA
RET
printBackspaceOne ENDP

; Deleting is soneported till the beginning of the current line
printBackspaceTwo PROC
PUSHA

    CALL decrementCursorTwo
    MOV AH,2
    MOV DL,' ' ; printing empty space to delete whatever under it
    INT 21h
    CALL setCursorTwo ; setting the cursor again because printing move the cursor

POPA
RET
printBackspaceTwo ENDP

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



;Move the cursor to (cursorTwo_X,cursorTwo_Y)
setCursorTwo PROC
PUSHA

    MOV AH , 2
    MOV BH , 0 ; Page Number
    MOV DL , cursorTwo_X
    MOV DH , cursorTwo_Y
    INT 10h

POPA
RET
setCursorTwo ENDP


;Move the cursor to (cursorOne_X,cursorOne_Y)
setCursorOne PROC
PUSHA

    MOV AH , 2
    MOV BH , 0 ; Page Number
    MOV DL , cursorOne_X
    MOV DH , cursorOne_Y
    INT 10h

POPA
RET
setCursorOne ENDP



incrementCursorOne PROC
PUSHA

CALL setCursorOne

MOV AL , cursorOne_Y
CMP AL , windowOneEndY
JNE _label_incrementCursorOne_skipScrolling
    ; scrolling one line one and set the new cursor
    CALL scrollWindowOne

_label_incrementCursorOne_skipScrolling:
    MOV AL , cursorOne_X
    CMP AL , windowOneEndX
    JE _label_incrementCursorOne

    INC cursorOne_X
POPA
RET

_label_incrementCursorOne:
    MOV AL , windowOneStartX
    MOV cursorOne_X , AL
    INC cursorOne_Y

POPA
RET
incrementCursorOne ENDP


incrementCursorTwo PROC
PUSHA

CALL setCursorTwo

MOV AL , cursorTwo_Y
CMP AL , windowTwoEndY
JNE _label_incrementCursorTwo_skipScrolling
    ; scrolling one line one and set the new cursor
    CALL scrollWindowTwo

_label_incrementCursorTwo_skipScrolling:
    MOV AL , cursorTwo_X 
    CMP AL , windowTwoEndX
    JE _label_incrementCursorTwo

    INC cursorTwo_X
POPA
RET

_label_incrementCursorTwo:
    MOV AL , windowTwoStartX
    MOV cursorTwo_X , AL
    INC cursorTwo_Y

POPA
RET
incrementCursorTwo ENDP

; Decrements the oneper window cursor till it reaches the beginning of the  line
; It DOES NOT SUPPORT scrolling to oneper line
decrementCursorOne PROC
PUSHA
    MOV AL , cursorOne_X
    CMP AL , windowOneStartX
    JE _label_decrementCursorOne_doNotDecrement

    DEC cursorOne_X
    CALL setCursorOne

_label_decrementCursorOne_doNotDecrement:
POPA
RET
decrementCursorOne ENDP


; Decrements the lower window cursor till it reaches the beginning of the  line
; It DOES NOT SUPPORT scrolling to oneper line
decrementCursorTwo PROC
PUSHA

    MOV AL , cursorTwo_X
    CMP AL , windowTwoStartX
    JE _label_decrementCursorTwo_doNotDecrement

    DEC cursorTwo_X
    CALL setCursorTwo

_label_decrementCursorTwo_doNotDecrement:
POPA
RET
decrementCursorTwo ENDP

END