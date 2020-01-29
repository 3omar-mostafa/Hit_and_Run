EXTRN initializeUART:NEAR
EXTRN sendByte:NEAR
EXTRN checkIfReceived:NEAR
EXTRN getReceivedByte:NEAR

EXTRN receivedByte:BYTE


callInitializeUART MACRO
    PUSHA

    CALL initializeUART

    POPA
ENDM callInitializeUART


callSendByte MACRO toSendByte
    PUSHA
    
    MOV AH , toSendByte
    CALL sendByte

    POPA
ENDM callSendByte


; @Return result in carry flag
; Carry = 1 -> true , Carry = 0 -> false
; JC -> true , JNC -> false
callCheckIfReceived MACRO
    PUSHA

    CALL checkIfReceived

    POPA
ENDM callCheckIfReceived


; @Return value in receivedByte variable
callGetReceivedByte MACRO
    PUSHA

    CALL getReceivedByte

    POPA
ENDM callGetReceivedByte
