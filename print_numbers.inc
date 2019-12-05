num MACRO inputdata ; inputdata is assumed as Word variable
    LOCAL start , print ; MUST be at the 2nd line , DO NOT LEAVE EMPTY LINE
 
    MOV AX , inputdata
    MOV CX , 0
    MOV DX , 0
    MOV BX , 10

    start:        
        DIV BX         ; Divides the input every iteration by 10 to extract one digit from it
        ADD DL , '0'   ; Adds '0' to convert the digit to its ascii value
        PUSH DX        ; Push it to the stack because we extract values from right and we want to print it from the left
        MOV DX , 0     ; resets the DX register in order not to have division overflow (div treats the number as DX:AX)
        INC CX         ; count the number of digits to pop them from the stack and print

    CMP AX , 0
    JNE start

    print:
        POP DX
        MOV AH , 2
        INT 21h
    LOOP print

ENDM num