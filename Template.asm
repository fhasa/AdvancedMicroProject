.MODEL SMALL ; Memory configuration
.STACK 100H ; Stack size in bytes
.data ; Data section


;                       -----------------defining variables------------------------

list db 10,13, "           list:               "
     db 10,13, "		----------------		"
     db 10,13, "  1.Array Sorting           "
     db 10,13, "  2.Letters Counter         "
     db 10,13, "  3.EXIT               "
     db 10,13, "  "
     db 10,13, "Your choice: $"


sizeStatement DB "Enter array size to be from 2 to 9 : $"
ten DB 0AH  
two DB 02H 
num DB 0H
arr1 DB 5 DUP (0)    
prpt1 DB 0DH,0AH,"Enter  array elements without spaces: $"
prpt2 DB 0DH,0AH,"array after sorting: $"
mc6 db 10,13, "Exiting the program $"
mc7 db 10,13, "Invalid choice....try again $"
empty db 10,13, "   $"
rem DB 0H

          
wordCount DB 00H            ;word counter---------------55----------
prevChar DB ' '             ;store the previous character, used in SA variable
StringMessage DB "Enter a text then insert'*'- : ",10,"$"
NoWords DB "Number Of Words: $";
FourSpace DB"    $"
COLUMNSPACE DB" |$"
FOURDASH DB"----$"  
ThreeSpace DB"   $"
.code
; 					--------------------------		 macro used to print a character		-----------------------.


outChar MACRO ch
    PUSH AX
    PUSH DX
    MOV DL, ch
    MOV AH,02h
    INT 21h
    POP DX
    pop AX
    ENDM
; 					--------------------------		End of  macro used to print a character		-----------------------.


;                   ---------------------------    PROC to enter array dimension          -------------------------------

DIM PROC
LEA DX,sizeStatement   
MOV AH,09H ; Print  entering SIZE statement
INT 21H
MOV AH,01h ;Read 
INT 21h
SUB AL,30h ;From ASCII to actual value
MOV num,AL ;Add tens value to num
RET
DIM ENDP

;					--------------------------   End of PROC to enter array dimension  ---------------------------
;					--------------------------   PROC to read elements                ------------------------------

ARRY PROC
LEA DX,prpt1
MOV AH,09H ; Print  prompt
INT 21H
MOV CH,0H
MOV CL,num
MOV SI,0H
arrayRead:MOV AH,01H 
INT 21H ;
SUB AL,30H ;
MUL ten ; multiply with ten to get the tenth part
MOV arr1[SI],AL ;  add it to the array
MOV AH,01H ;
INT 21H ;
SUB AL,30H ;
ADD arr1[SI],AL
INC SI
LOOP arrayRead
RET
ARRY ENDP
;					---------------------------	End of PROC to read elements		 ------------------------------------

;					-------------------------- 		proc for sorting	        	   	----------------------------------
;
SORT PROC
MOV CH,0H
MOV CL,num ;set the cl to size of array
mov SI, 0 ; indexing for outerloop
mov DI, 0 ; indexing of the inner loop
mov AX, 1 ; this is done

DEC CX    ; to avoid the done comparison

Loop1:
        push CX  ; store the limit of outerLoop in stack 
        mov BL, arr1[SI]    ; store the element in bl pointed by si                                                  
        MOV CH,0H
        MOV CL,num  ; store the value of size in cx for innerLoop        
        sub CX, AX     ; this is done so that the value does not proceed the value of array elements.
Loop2:

             INC DI            
             CMP BL, arr1[DI]  ;compare the if BL is less than continueent of element pointed by DI if yes then continueinue otherwise swap the value by executing below statements  
             JG cont          
             MOV DL, arr1[DI]    ; get the element pointed by DI into DL
             MOV arr1[DI], BL   ; swap the
             MOV arr1[SI], DL   ; elements
             MOV BL, DL             ; store the smallest element in BL                              

     cont:
        loop Loop2
        INC AX                                                        
        POP CX  ; get the value of outerLoop
        INC SI  ; increment the index of outerLoop to point to the next element  
        MOV DI, SI ; point to the same index
        LOOP Loop1          

RET
SORT ENDP
;					-------------------------- 		End of proc for sorting	        	   	----------------------------------
;					--------------------------		proc for display array after sorting    ------------------------------

display PROC
LEA DX,prpt2
MOV AH,09H ; Print  prompt
INT 21H
MOV AH,0h
MOV SI,0H
MOV CH,0H
MOV CL,num
L4:
outChar 10
MOV AH,0h
MOV AL,arr1[SI]
DIV ten    ;Divide num into digits
MOV DL,AL
MOV rem,AH
ADD DL,30h
MOV AH,02h ;Display tens digit
INT 21h
MOV DL,rem
ADD DL,30h
MOV AH,02h ;Display ones digit
INT 21h
INC SI
LOOP L4
RET
display ENDP
;					--------------------------		End of proc for display array after sorting    ------------------------------
; 					--------------------------       procedure to initiate the memory from 500H to 500H + (52)10 to be zero  ---------
InitiateSI PROC
    MOV SI ,500H
    MOV CL, 52
    MOV AL, 00H
    MYLOOP:  MOV [SI], AL
             INC SI
             DEC CL
             JNZ MYLOOP     
RET
InitiateSI ENDP
; 					--------------------------      End of procedure to initiate the memory from 500H to 500H + (52)10 to be zero  ---------
; 					--------------------------		macro used to print a string		-----------------------.
outStr MACRO msg
    PUSH AX
    PUSH DX
    LEA DX,msg
    MOV AH,09H
    INT 21H
    POP DX
    POP AX
ENDM
; 					--------------------------		End of macro used to print a string		-----------------------.
; 					--------------------------		macro used to read the choice		-----------------------.

choice MACRO
    MOV AH ,01H
    INT 21H
ENDM
; 					--------------------------		End of macro used to read the choice	-----------------------.


;					--------------------------		Start of program 						----------------------------------
start:
MOV AX,@DATA ; Initialize DS
MOV DS,AX

again:
outStr list
choice  ;accept user choice

mov bl,al


case1:

        cmp bl,"1"    ;compare user choice with '1'
        jne case2
        CALL DIM
        CALL ARRY
        CALL SORT
        CALL display
        jmp again

case2:  cmp bl,"2"         ;checking user choice for case 2
        jne case3          ;if not equal,check for case 3
        CALL lett
        jmp again


case3: cmp bl,"3"    ;check for case 3
       jne case4   ;if not equal,default to case 4 and print the error message
       outStr mc6
       jmp exit
         
case4: outStr mc7   ;print error message
       jmp again   ;display the list again
   
exit:

MOV AH,4CH ; End of program    
INT 21H
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
;Letters Counter procedure
lett PROC

   MOV wordCount, 1            ;initially there is at least one word
    MOV prevChar, ' '           ;previous is the space character
    CALL InitiateSI             ;initilize the memory 52 locations to zero
    outStr StringMessage

    READ:
        MOV SI ,500H
            choice    ;read a character
            MOV AH, 00H         ;clear AH
            CMP AL ,2AH         ;compare with *
            JE END_READ         ;if input == * stop
                                ;COUNT THE NUMBER OF WORDS
            CMP AL ,13          ;compare with enter key
            JNE SKIP
            MOV AL, ' '         ;enter key is like ' '
    SKIP:
            CMP AL, ' '
            JNE CONTINUE
            CMP AL,prevChar
            JE CONTINUE         ;if two consecutive ' ' then ignore .
            INC wordCount       ;if there is a charater after the ' ' count a word
    CONTINUE:  
            CMP AL, 'z'
            JA CAPITAL        ;if the input is not a letter don't count.
            CMP AL, 'a';
            JNAE CAPITAL      ;if the input is not a letter don't count.
            SUB AL,61H;
            ADD SI ,AX;
            MOV CL,01H;
            ADD  [SI], CL       ;Now add one  the letter location if the input is a letter [a-z];
    CAPITAL:
            CMP AL, 'Z'
            JA NOT_ALPHA 
            CMP AL, 'A';
            JNAE NOT_ALPHA      ;if the input is not a letter don't count.
            SUB AL,41H;
			ADD AL ,26;
            ADD SI ,AX;
            MOV CL,01H;
            ADD  [SI], CL       ;Now add one  the letter location if the input is a letter [A-Z];			
	NOT_ALPHA:  
            MOV prevChar, AL    ;set this character to be previus character  
            JMP READ;
    END_READ:
            MOV SI ,500H
            outChar 10          ;PRINT END LINE
            MOV CL,00H
    PRINTS:
            MOV AX,0;
            MOV AL,[SI]
            CMP AL, 00H         ;compare the occuerance of the letter with 00
            JZ ENDLOOP          ;not appears -> Yes -> ignore.
            MOV BL,CL
			CMP BL, 25;
			JA capit2			
            ADD BL,'a'          ;convert to a ascii value
			JMP pr
	 capit2:ADD BL,'A'
			SUB BL,26			
		pr:	outChar BL          ;print the value.
            outStr COLUMNSPACE  ;print the " |" string
            MOV BL, [SI]
            ADD BL,30H
			MOV DL,BL
			MOV AH,02h ;Display ones digit
			INT 21h
			outChar 10
                    ;
            ENDLOOP:    INC SI
                        INC CL
                        MOV BL,52;
                        CMP CL,BL;
    JNE PRINTS
                                ;Print the statistical bars
   RET
lett ENDP


end start
end
