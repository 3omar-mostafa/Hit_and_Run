INCLUDE draw.INC

; This file contains MACROs to display certain alphabet letters
; in diffeerent position and sizes

; Each letter is a grid of points
; The grid is 8 rows , 5 columns
; Example on letter A
;1	.XXX.
;2	X...X
;3	X...X
;4	XْْْْْْْْْXXXX
;5	X...X
;6	X...X
;7	X...X
;8	X...X
;	12345

; WARNING: DO NOT PUT SAPCES BETWEEN ANY OPERAND IN THE SAME PARAMETER
; IT WILL TREAT IT AS TWO PARAMETES AND GIVE ERRORS
; EX: start_x1+6*lineWidthM -> start_x1 + 6 * lineWidthM
	

draw_A MACRO color , start_x , start_y , lineWidth
    LOCAL end_y
    end_y EQU start_y + 8*lineWidth
    
    callDrawColumnDown  color lineWidth start_x  		      start_y+lineWidth          			end_y
    callDrawRowLeft     color lineWidth start_x+lineWidth     start_y                       		start_x+4*lineWidth
    callDrawColumnUp    color lineWidth start_x+4*lineWidth   start_y+lineWidth                     end_y
    callDrawRowLeft     color lineWidth start_x+lineWidth     start_y+(end_y-start_y-lineWidth)/2   start_x+4*lineWidth

ENDM draw_A


draw_C MACRO color , start_x , start_y , lineWidth
    LOCAL end_y
    end_y EQU start_y + 8*lineWidth
	
    callDrawRowRight    color lineWidth	start_x+lineWidth  	start_y    			start_x+5*lineWidth
    callDrawColumnUp    color lineWidth	start_x    			start_y+lineWidth  	end_y-lineWidth
    callDrawRowLeft     color lineWidth	start_x+lineWidth  	end_y-lineWidth  	start_x+5*lineWidth


ENDM draw_C

   

draw_D MACRO color , start_x , start_y , lineWidth
    LOCAL end_y
    end_y EQU start_y + 8*lineWidth
    
    callDrawColumnDown  color lineWidth start_x       			start_y       		 end_y
    callDrawRowLeft     color lineWidth start_x+lineWidth     	start_y       		 start_x+3*lineWidth
    callDrawColumnUp    color lineWidth start_x+3*lineWidth   	start_y+lineWidth    start_y+2*lineWidth
    callDrawColumnUp    color lineWidth start_x+4*lineWidth   	start_y+2*lineWidth  start_y+6*lineWidth
    callDrawColumnUp    color lineWidth start_x+3*lineWidth   	start_y+6*lineWidth  end_y-lineWidth
    callDrawRowRight    color lineWidth start_x+lineWidth     	end_y-lineWidth      start_x+3*lineWidth



ENDM draw_D


draw_E MACRO color , start_x , start_y , lineWidth
    LOCAL end_y
    end_y EQU start_y + 8*lineWidth
    
    callDrawRowRight    color lineWidth start_x       		start_y                       		 start_x+5*lineWidth
    callDrawColumnUp    color lineWidth start_x       		start_y+lineWidth                    end_y
    callDrawRowLeft     color lineWidth start_x       		end_y-lineWidth                      start_x+5*lineWidth
    callDrawRowLeft     color lineWidth start_x+lineWidth  	start_y+(end_y-start_y-lineWidth)/2  start_x+4*lineWidth

ENDM draw_E
    


draw_H MACRO color , start_x , start_y , lineWidth
    LOCAL end_y
    end_y EQU start_y + 8*lineWidth
    
    callDrawColumnUp   color lineWidth start_x       	  	start_y                       			end_y
    callDrawRowLeft    color lineWidth start_x+lineWidth    start_y+(end_y-start_y-lineWidth)/2    	start_x+4*lineWidth
    callDrawColumnUp   color lineWidth start_x+4*lineWidth  start_y                       			end_y
    
ENDM draw_H


draw_I MACRO color , start_x , start_y , lineWidth
    LOCAL end_y
    end_y EQU start_y + 8*lineWidth
    
    callDrawRowLeft    color lineWidth start_x		  		 start_y  			start_x+5*lineWidth
    callDrawColumnUp   color lineWidth start_x+2*lineWidth   start_y  			end_y
    callDrawRowLeft    color lineWidth start_x       	  	 end_y-lineWidth  	start_x+5*lineWidth
ENDM draw_I


draw_L MACRO color , start_x , start_y , lineWidth
    LOCAL end_y
    end_y EQU start_y + 8*lineWidth

    callDrawColumnUp   color lineWidth start_x    			start_y  		 end_y
    callDrawRowLeft    color lineWidth start_x+lineWidth   	end_y-lineWidth  start_x+5*lineWidth
ENDM draw_L


draw_M MACRO color , start_x , start_y , lineWidth
    LOCAL end_y
    end_y EQU start_y + 8*lineWidth

    callDrawColumnDown   color lineWidth start_x       			start_y      		 end_y
    callDrawRowLeft      color lineWidth start_x+lineWidth     	start_y+lineWidth    start_x+2*lineWidth
    callDrawColumnUp     color lineWidth start_x+2*lineWidth   	start_y+2*lineWidth  start_y+3*lineWidth
    callDrawRowLeft      color lineWidth start_x+3*lineWidth   	start_y+lineWidth    start_x+5*lineWidth
    callDrawColumnUp     color lineWidth start_x+4*lineWidth   	start_y      		 end_y
ENDM draw_M


draw_N MACRO color , start_x , start_y , lineWidth
    LOCAL end_y
    end_y EQU start_y + 8*lineWidth

    callDrawColumnDown   color lineWidth start_x       			start_y      		 end_y
    callDrawColumnUp     color lineWidth start_x+lineWidth     	start_y+lineWidth    start_y+2*lineWidth
    callDrawColumnUp     color lineWidth start_x+2*lineWidth   	start_y+2*lineWidth  start_y+6*lineWidth
    callDrawColumnUp     color lineWidth start_x+3*lineWidth   	start_y+6*lineWidth  start_y+7*lineWidth
    callDrawColumnDown   color lineWidth start_x+4*lineWidth   	start_y      	 	 end_y
	
ENDM draw_N



draw_O MACRO color , start_x , start_y , lineWidth
    LOCAL end_y
    end_y EQU start_y + 8*lineWidth


	callDrawRowRight    color lineWidth start_x+lineWidth   	start_y    			start_x+4*lineWidth
    callDrawColumnUp    color lineWidth start_x      	  		start_y+lineWidth  	end_y-lineWidth
    callDrawRowLeft     color lineWidth start_x+lineWidth   	end_y-lineWidth    	start_x+4*lineWidth
    callDrawColumnDown  color lineWidth start_x+4*lineWidth 	start_y+lineWidth  	end_y-lineWidth


ENDM draw_O



draw_R MACRO color , start_x , start_y , lineWidth
    LOCAL end_y
    end_y EQU start_y + 8*lineWidth
    
    callDrawColumnDown  color lineWidth start_x          	  start_y+lineWidth     end_y
    callDrawRowLeft     color lineWidth start_x+lineWidth     start_y       		start_x+4*lineWidth
    callDrawColumnUp    color lineWidth start_x+4*lineWidth   start_y+lineWidth     start_y+3*lineWidth
    callDrawRowRight    color lineWidth start_x+lineWidth     start_y+3*lineWidth   start_x+4*lineWidth
    callDrawRowLeft     color lineWidth start_x+2*lineWidth   start_y+4*lineWidth   start_x+3*lineWidth
    callDrawRowLeft     color lineWidth start_x+3*lineWidth   start_y+5*lineWidth   start_x+4*lineWidth
    callDrawColumnUp    color lineWidth start_x+4*lineWidth   start_y+6*lineWidth   end_y

ENDM draw_R



draw_T MACRO color , start_x , start_y , lineWidth
    LOCAL end_y
    end_y EQU start_y + 8*lineWidth
    
    callDrawRowLeft    color lineWidth start_x       	  	 start_y  start_x+5*lineWidth
    callDrawColumnUp   color lineWidth start_x+2*lineWidth   start_y  end_y

ENDM draw_T



draw_U MACRO color , start_x , start_y , lineWidth
    LOCAL end_y
    end_y EQU start_y + 8*lineWidth
    
    callDrawColumnUp    color lineWidth start_x          	  start_y   		end_y
    callDrawRowLeft     color lineWidth start_x+lineWidth     end_y-lineWidth   start_x+4*lineWidth
    callDrawColumnDown  color lineWidth start_x+4*lineWidth   start_y   		end_y

ENDM draw_U


draw_W MACRO color , start_x , start_y , lineWidth
    LOCAL end_y
    end_y EQU start_y + 8*lineWidth
	
    callDrawColumnUp    color lineWidth start_x          	  start_y      			end_y
    callDrawRowLeft     color lineWidth start_x+lineWidth     start_y+6*lineWidth  	start_x+2*lineWidth
    callDrawColumnDown  color lineWidth start_x+2*lineWidth   start_y+5*lineWidth  	start_y+6*lineWidth
    callDrawRowLeft     color lineWidth start_x+3*lineWidth   start_y+6*lineWidth  	start_x+5*lineWidth
    callDrawColumnDown  color lineWidth start_x+4*lineWidth   start_y      			end_y

ENDM draw_W
