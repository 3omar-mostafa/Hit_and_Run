;;;;;;;;;;;;;;;;
;q DW ?
;;;;;;;;;;;;;;;;;;;;;;;;;;
;first player;;
;;;;;;;;;;;;;;;;;;;
checkkeypressed PROC 
                mov ah , 0
                int 16h
                cmp ah , 72
                jz isup
                cmp ah , 80
                jz isdown
                cmp ah , 77
                jz tempright
                cmp ah , 75
                jz temp
                ;cmp ah , 57
                ;call drawbomb
                jmp tempfinish1
                
isup:
mov ax , starty
mov q , ax
sub starty , 10
clearblock startx , q
call draw
jmp finish
tempright: jmp isright
isdown:
mov ax , starty
mov q , ax
add starty , 10
clearblock startx , q
call draw
jmp finish
tempfinish1: jmp tempfinish2
temp: jmp isleft
isright:
mov ax , startx
mov q , ax
 add startx , 10
clearblock q , starty
call draw
jmp finish
tempfinish2: jmp finish
isleft: 
mov ax , startx
mov q , ax
sub startx , 10
clearblock q , starty
call draw
finish:            RET
checkkeypressed ENDP
 

;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;second player;;;;;;
;;;;;;;;;;;;;;;;;;;;
checkkeypressed PROC 
                mov ah , 0
                int 16h
                cmp ah , 17
                jz isup
                cmp ah , 31
                jz isdown
                cmp ah , 32
                jz tempright
                cmp ah , 30
                jz temp
                ;cmp ah , 57
                ;call drawbomb
                jmp tempfinish1
                
isup:
mov ax , starty
mov q , ax
sub starty , 10
clearblock startx , q
call draw
jmp finish
tempright: jmp isright
isdown:
mov ax , starty
mov q , ax
add starty , 10
clearblock startx , q
call draw
jmp finish
tempfinish1: jmp tempfinish2
temp: jmp isleft
isright:
mov ax , startx
mov q , ax
 add startx , 10
clearblock q , starty
call draw
jmp finish
tempfinish2: jmp finish
isleft: 
mov ax , startx
mov q , ax
sub startx , 10
clearblock q , starty
call draw
finish:            RET
checkkeypressed ENDP
                

timeforbomp PROC 
            mov ah , 2ch
            int 21h
            mov bl , dh
            l: 
            int 21h
            sub dh , bl
            cmp dh , 3
            jnz l
            call updatesurronding
            RET
timeforbomp ENDP

find1Darray PROC
            ;sub al , 16  ;Y
            
            mov cx , 144
            mul cx
            add ax , bl
            mov di , ax        
            RET
find1Darray ENDP

checkfordrawhints PROC
                  cmp dx , 00000000b
                  call drawgreen
                  cmp dx , 00000010b
                  call drawheart
                  cmp dx , 00000100b
                  call bomb
                  cmp dx , 00001000b
                  call coin   
                  RET
checkfordrawhints ENDP

updatesurronding PROC
           mov al , x    ;positionx of bomb
           mov bl , y    ;positiony of bomb
           ;check right
           inc al
           call find1Darray
           mov dx , [si][di]
           shr dx , 1
           shl dx , 1
           call checkfordrawhints
           ;check left
           mov al , x    ;positionx of bomb
           mov bl , y    ;positiony of bomb
           ;check right
           dec al
           call find1Darray
           mov dx , [si][di]
           shr dx , 1
           shl dx , 1
           call checkfordrawhints
           ;check UP
           mov al , x    ;positionx of bomb
           mov bl , y    ;positiony of bomb
           ;check right
           inc bl
           call find1Darray
           mov dx , [si][di]
           shr dx , 1
           shl dx , 1
           call checkfordrawhints
           ;checl down
           mov al , x    ;positionx of bomb
           mov bl , y    ;positiony of bomb
           ;check right
           dec bl
           call find1Darray
           mov dx , [si][di]
           shr dx , 1
           shl dx , 1
           call checkfordrawhints  
           RET
checkblock ENDP

writescore PROC
           RET
writescore ENDP

increasescore PROC
              RET
increasescore ENDP

decreasescore PROC
              RET
decreasescore ENDP

increaseheart PROC
              
              RET
increaseheart ENDP

decreaseheart PROC
              RET
decreaseheart ENDP





