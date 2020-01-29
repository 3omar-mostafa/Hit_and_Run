.MODEL SMALL
.STACK 2048
.386 ; sets the instruction set of 80386 processor

PUBLIC Chat

; These are variables are initialized by the caller
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

INCLUDE serial.inc
INCLUDE inout.inc
INCLUDE const.inc

.DATA

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

    cursorOne_X DB 0
    cursorOne_Y DB 0

    cursorTwo_X DB 40
    cursorTwo_Y DB 0


.CODE

; The screen is divided into two haves : WindowOne , WindowTwo
Chat PROC
    PUSHA

    CALL initializeCursors
    CALL initializeWindow

    callSetCursorPosition cursorOne_X , cursorOne_Y

    ChatLoop:

        _label_send:
            callIsKeyPressed
            JZ _label_receive

            callGetPressedKey
            callSendByte AL

            CMP AL , BACK_SPACE_ASCII
            JE _label_backspace_one

            CMP AL , ENTER_ASCII
            JE _label_enter_one

            JMP _label_normalChar_one

            _label_backspace_one:
                CALL printBackspaceOne
            JMP _label_receive

            _label_enter_one:
                CALL printEnterOne
            JMP _label_receive

            _label_normalChar_one:
                CALL incrementCursorOne ; Printing (printChar) increments the cursor by itself
                callPrintChar AL        ; But we increment it by ourselves to have more control on cursor position

        _label_receive:
            callCheckIfReceived
            JNC _label_check_exit

            callGetReceivedByte

            CMP receivedByte , BACK_SPACE_ASCII
            JE _label_backspace_two

            CMP receivedByte , ENTER_ASCII
            JE _label_enter_two

            JMP _label_normalChar_two

            _label_backspace_two:
                CALL printBackspaceTwo
            JMP _label_receive

            _label_enter_two:
                CALL printEnterTwo
            JMP _label_receive

            _label_normalChar_two:
                CALL incrementCursorTwo     ; Printing increments the cursor by itself
                callPrintChar receivedByte  ; But we increment it by ourselves to have more control on cursor position

        _label_check_exit:
            CMP AL , ESC_ASCII
            JE _label_Chat_finish

            CMP receivedByte , ESC_ASCII
            JE _label_Chat_finish

    JMP ChatLoop

    _label_Chat_finish:
    MOV receivedByte , 0
    POPA
    RET
Chat ENDP


initializeCursors PROC

    MOV_MEMORY_BYTE cursorOne_X , windowOneStartX
    MOV_MEMORY_BYTE cursorOne_Y , windowOneStartY
    MOV_MEMORY_BYTE cursorTwo_X , windowTwoStartX
    MOV_MEMORY_BYTE cursorTwo_Y , windowTwoStartY

    RET
initializeCursors ENDP


initializeWindow PROC
    PUSHA

    ; scrolls the window size up and down to color them

    MOV AH , 6 ; scroll down
    MOV AL , windowOneEndY ; scroll by height of the window line
    SUB AL , windowOneStartY ; height = end - start + 1
    ADD AL , 1
    MOV BH , WindowOneColor
    MOV CH , windowOneStartY
    MOV CL , windowOneStartX
    MOV DH , windowOneEndY
    MOV DL , windowOneEndX
    INT 10h

    MOV AH , 7 ; scroll up
    INT 10h



    MOV AH , 6 ; scroll down
    MOV AL , windowTwoEndY ; scroll by the height of the window
    SUB AL , windowTwoStartY ; height = end - start + 1
    ADD AL , 1
    MOV BH , WindowTwoColor
    MOV CH , windowTwoStartY
    MOV CL , windowTwoStartX
    MOV DH , windowTwoEndY
    MOV DL , windowTwoEndX
    INT 10h

    MOV AH , 7 ; scroll up
    INT 10h

    POPA
    RET
initializeWindow ENDP


scrollWindowOne PROC
    PUSHA

    MOV AH , 6 ; scroll down
    MOV AL , 1 ; scroll by 1 line
    MOV BH , WindowOneColor
    MOV CH , windowOneStartY
    MOV CL , windowOneStartX
    MOV DH , windowOneEndY
    MOV DL , windowOneEndX
    INT 10h

    DEC cursorOne_Y ; Scroll increments y so we decrement it to remain at the same line
    MOV_MEMORY_BYTE cursorOne_X , windowOneStartX
    callSetCursorPosition cursorOne_X , cursorOne_Y

    POPA
    RET
scrollWindowOne ENDP


scrollWindowTwo PROC
    PUSHA

    MOV AH , 6 ; scroll down
    MOV AL , 1 ; scroll by 1 line
    MOV BH , WindowTwoColor
    MOV CH , windowTwoStartY
    MOV CL , windowTwoStartX
    MOV DH , windowTwoEndY
    MOV DL , windowTwoEndX
    INT 10h

    DEC cursorTwo_Y ; Scroll increments y so we decrement it to remain at the same line
    MOV_MEMORY_BYTE cursorTwo_X , windowTwoStartX
    callSetCursorPosition cursorTwo_X , cursorTwo_Y

    POPA
    RET
scrollWindowTwo ENDP


printEnterOne PROC
    PUSHA

    INC cursorOne_Y
    MOV_MEMORY_BYTE cursorOne_X , windowOneStartX
    callSetCursorPosition cursorOne_X , cursorOne_Y

    CMP_MEMORY cursorOne_Y , windowOneEndY
    JB _label_printEnterOne_skipScrolling
        ; scrolling one line one and set the new cursor
        CALL scrollWindowOne

    _label_printEnterOne_skipScrolling:
    POPA
    RET
printEnterOne ENDP



printEnterTwo PROC
    PUSHA

    INC cursorTwo_Y
    MOV_MEMORY_BYTE cursorTwo_X , windowTwoStartX
    callSetCursorPosition cursorTwo_X , cursorTwo_Y

    CMP_MEMORY cursorTwo_Y , windowTwoEndY
    JB _label_printEnterTwo_skipScrolling
        ; scrolling one line one and set the new cursor
        CALL scrollWindowTwo

    _label_printEnterTwo_skipScrolling:
    POPA
    RET
printEnterTwo ENDP

; Deleting is supported till the beginning of the current line
printBackspaceOne PROC
    PUSHA

    CALL decrementCursorOne
    callPrintChar " "
    callSetCursorPosition cursorOne_X , cursorOne_Y ; setting the cursor again because printing move the cursor

    POPA
    RET
printBackspaceOne ENDP


; Deleting is supported till the beginning of the current line
printBackspaceTwo PROC
    PUSHA

    CALL decrementCursorTwo
    callPrintChar " "
    callSetCursorPosition cursorTwo_X , cursorTwo_Y ; setting the cursor again because printing move the cursor

    POPA
    RET
printBackspaceTwo ENDP


incrementCursorOne PROC
    PUSHA

    callSetCursorPosition cursorOne_X , cursorOne_Y

    CMP_MEMORY cursorOne_Y , windowOneEndY
    JNE _label_incrementCursorOne_skipScrolling
        ; scrolling one line one and set the new cursor
        CALL scrollWindowOne

    _label_incrementCursorOne_skipScrolling:

        CMP_MEMORY cursorOne_X , windowOneEndX
        JE _label_incrementCursorOne

        INC cursorOne_X
    POPA
    RET

    _label_incrementCursorOne:
        MOV_MEMORY_BYTE cursorOne_X , windowOneStartX
        INC cursorOne_Y

    POPA
    RET
incrementCursorOne ENDP


incrementCursorTwo PROC
    PUSHA

    callSetCursorPosition cursorTwo_X , cursorTwo_Y

    CMP_MEMORY cursorTwo_Y , windowTwoEndY
    JNE _label_incrementCursorTwo_skipScrolling
        ; scrolling one line one and set the new cursor
        CALL scrollWindowTwo

    _label_incrementCursorTwo_skipScrolling:

        CMP_MEMORY cursorTwo_X , windowTwoEndX
        JE _label_incrementCursorTwo

        INC cursorTwo_X
    POPA
    RET

    _label_incrementCursorTwo:
        MOV_MEMORY_BYTE cursorTwo_X , windowTwoStartX
        INC cursorTwo_Y

    POPA
    RET
incrementCursorTwo ENDP

; Decrements window one cursor till it reaches the beginning of the  line
; It DOES NOT SUPPORT scrolling to upper line
decrementCursorOne PROC
    PUSHA

    CMP_MEMORY cursorOne_X , windowOneStartX
    JE _label_decrementCursorOne_doNotDecrement

    DEC cursorOne_X
    callSetCursorPosition cursorOne_X , cursorOne_Y

    _label_decrementCursorOne_doNotDecrement:
    POPA
    RET
decrementCursorOne ENDP


; Decrements the window two cursor till it reaches the beginning of the  line
; It DOES NOT SUPPORT scrolling to upper line
decrementCursorTwo PROC
    PUSHA

    CMP_MEMORY cursorTwo_X , windowTwoStartX
    JE _label_decrementCursorTwo_doNotDecrement

    DEC cursorTwo_X
    callSetCursorPosition cursorTwo_X , cursorTwo_Y

    _label_decrementCursorTwo_doNotDecrement:
    POPA
    RET
decrementCursorTwo ENDP

END