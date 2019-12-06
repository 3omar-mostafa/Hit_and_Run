          .model small
.stack 64
.code
main proc far


			MOV AX , 143             ;J  Y
			MOV BX , 303             ;I  X

            INC AX
            INC BX

			shr ax , 1
			shr ax , 1
			shr ax , 1
			shr ax , 1
			
			shr  bx , 1
			shr  bx , 1
			shr  bx , 1
			shr  bx , 1
			             
			DEC AX
			   
			             
            mov cx , 20 ; 320/16
            mul cx
            add ax , bx;bx = y

            mov di , ax
			
			hlt
			

main endp

end main