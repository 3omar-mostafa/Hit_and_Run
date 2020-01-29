; For more info about serial communication check: https://www.lammertbies.nl/comm/info/serial-uart 
; This file contains Procedures that handles Serial Communication Sending/Receiving

; The parameters for these Procedures are prepared by MACROs in serial.inc
; DO NOT CALL THESE Procedures DIRECTLY

.MODEL SMALL
.STACK 2048
.386 ; sets the instruction set of 80386 processor

PUBLIC initializeUART
PUBLIC sendByte
PUBLIC checkIfReceived
PUBLIC getReceivedByte

PUBLIC receivedByte

.DATA

    receivedByte DB ?

.CODE

initializeUART PROC

    ; Set Divisor Latch Access Bit
    MOV DX , 3FBh ; Line Control Register
    MOV AL , 10000000b ;Set Divisor Latch Access Bit
    OUT DX , AL ;Out it

    ; Baud rate is 19200
    ; For more info check: https://www.lookrs232.com/rs232/dlab.htm

    ; Set LSB byte of the Baud Rate Divisor Latch register.
    MOV DX , 3F8h
    MOV AL , 6
    OUT DX , AL

    ; Set MSB byte of the Baud Rate Divisor Latch register.
    MOV DX , 3F9h
    MOV AL , 0
    OUT DX , AL

    ; Set port configuration
    ; For more info check: https://www.lookrs232.com/rs232/lcr.htm
    ; 0:Access to Receiver buffer, Transmitter buffer
    ; 0:Set Break disabled
    ; 011:Even Parity
    ; 1:Two Stop Bits
    ; 11:8bits
    MOV DX , 3FBh ; Line Control Register
    MOV AL , 00011111b
    OUT DX , AL

    RET
initializeUART ENDP


sendByte PROC
    ; Parameters:
    ; AH -> toSendByte
    
    ; For more info check: https://www.lookrs232.com/rs232/lsr.htm
    ; Check that Transmitter Holding Register is Empty
    MOV DX , 3FDH ; Line Status Register
    _label_sendByte_check:
        IN AL , DX
        AND AL , 00100000b
    JZ _label_sendByte_check

    ; If empty put the toSendByte in Transmit data register
    MOV DX , 3F8H ; Data Register
    MOV AL , AH ; Move toSendValue to AL to OUT it (Must be AL or AX or EAX) 
    OUT DX , AL

    RET
sendByte ENDP


; @Return result in carry flag
; Carry = 1 -> true , Carry = 0 -> false 
; JC -> true , JNC -> false
checkIfReceived PROC

    ; For more info check: https://www.lookrs232.com/rs232/lsr.htm
    ; Check that Data is Ready
    MOV DX , 3FDH ; Line Status Register
    IN AL , DX
    SHR AL , 1 ; Move LSB (Least Significant Bit) into carry flag

    RET
checkIfReceived ENDP


; @Return value in receivedByte variable
getReceivedByte PROC

    ; Read the value in Receive data register
    MOV DX , 3F8H ; Data Register
    IN AL , DX
    MOV receivedByte , AL

    RET
getReceivedByte ENDP


END