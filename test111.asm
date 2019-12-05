.model small
.stack 64
.code
main proc far


			mov ax , 320
			mov bx , 160

            sub bx , 16

			shr ax , 1
			shr ax , 1
			shr ax , 1
			shr ax , 1
			
			shr  bx , 1
			shr  bx , 1
			shr  bx , 1
			shr  bx , 1
			
            mov cx , 20 ; 320/16
            mul cx
            add ax , bx;bx = y

            mov di , ax
			
			hlt
			

main endp

end main