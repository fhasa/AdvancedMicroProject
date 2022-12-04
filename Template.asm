.MODEL SMALL ; Memory configuration
.STACK 100H ; Stack size in bytes
.data ; Data section

list db 10,13, "           list:               "
     db 10,13, "****************************** "
     db 10,13, "  1.Array sorter             "
     db 10,13, "  2.Text Statistics         "
     db 10,13, "  3.EXIT               "
     db 10,13, "  "
     db 10,13, "Your choice: $"
              ;CASE 1
sz DB "Enter the dimenSIon of array: $"
ten DB 0AH   
num DB 0H
arr1 DB 5 DUP (0)
prpt1 DB 0DH,0AH,"Enter  array elements: $"
prpt2 DB 0DH,0AH,"array after sorting: $"
mc6 db 10,13, "Exiting the program $"
mc7 db 10,13, "Invalid choice....try again $"
empty db 10,13, "   $"
rem DB 0H
;-------------------------------------------------------------------------------
               ;CASE 2
wordCount DB 00H            ;word counter
prevChar DB ' '             ;store the previous character, used in SA variable
StringMessage DB "Enter a text then insert'*'- : ",10,"$"
NoWords DB "Number Of Words: $";
FourSpace DB"    $"
COLUMNSPACE DB" |$"
FOURDASH DB"----$"  
ThreeSpace DB"   $"
.code
;-------------------------------------------------------------------------------
;PROC to enter dim
DIM PROC
LEA DX,sz
MOV AH,09H ; Print  SIZE
INT 21H
MOV AH,01h ;Read tens digit
INT 21h
SUB AL,30h ;From ASCII to actual value
MUL ten ;Add Ten weight (10d)
ADD num,AL ;Add tens value to num
MOV AH,01h ;Read ones digit
INT 21h
SUB AL,30h ;From ASCII to actual value
ADD num,AL ;Add tens value to num
RET
DIM ENDP
;-------------------------------------------------------------------------------
;PROC to read elements
ARRY PROC
LEA DX,prpt1
MOV AH,09H ; Print  prompt
INT 21H
MOV CH,0H
MOV CL,num
MOV SI,0H
l1:MOV AH,01H 
INT 21H ;
SUB AL,30H ;
MUL ten ;
MOV arr1[SI],AL ;  Read first number
MOV AH,01H ;
INT 21H ;
SUB AL,30H ;
ADD arr1[SI],AL
INC SI
LOOP L1
RET
ARRY ENDP
;-------------------------------------------------------------------------------
;proc for sorting
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
        sub CX, AX     ; this is done so that the limit does not proceed the limit of array elements.
Loop2:

             INC DI                  

             CMP BL, arr1[DI]  ; compare the if BL is not greater than  
             JG cont          ; content of element pointed by DI if yes then continue otherwise swap the value by executing below statements  

             MOV DL, arr1[DI]    ; get the element pointed by DI into DL
             MOV arr1[DI], BL   ; swap the
             MOV arr1[SI], DL   ; elements
             MOV BL, DL             ; store the smallest element in BL                              

     cont:

        loop Loop2

        INC AX                                                        

        POP CX  ; get the limit of outerLoop

        INC SI  ; increment the index of outerLoop to point to the next element  

        MOV DI, SI ; point to the same index

        LOOP Loop1          

RET
SORT ENDP
;-------------------------------------------------------------------------------
;proc for display array after sorting
display PROC
LEA DX,prpt2
MOV AH,09H ; Print  prompt
INT 21H
MOV AH,0h
MOV SI,0H
MOV CH,0H
MOV CL,num
L4:MOV AH,0h
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
;-------------------------------------------------------------------------------
;convert_display_words PROC to print a number stored in the AX, dynamically print
convert_display_words PROC
    PUSH AX
    PUSH CX
    PUSH DX
                        ;initilize count
    MOV CX, 0
    MOV DX, 0
                        ;this loop used to store the digit in the stack.
    STORE_DIGITS:  
        MOV BX,10       ;initilize bx to 10
        DIV BX          ;extract the last digit
        PUSH DX         ;push it in the stack
        INC CX          ;increment the count
        XOR DX,DX       ;set dx to 0
        CMP AX,0        ;if ax is zero
        JE PRINT_DIGITS      
        JMP STORE_DIGITS
    PRINT_DIGITS:
        CMP CX,0        ;check if count is greater than zero
        JE Ex
        POP DX          ;pop the top of stack
        ADD DX,'0'      ;add 0 to the value to convert the number to ascii value
                        ;interuppt to print a character
        MOV AH,02H
        INT 21H
        DEC CX          ;decrease the count
        JMP PRINT_DIGITS
    Ex:
        POP DX
        POP CX
        POP AX
        RET
convert_display_words ENDP
;-------------------------------------------------------------------------------
; procesdure to initiate the memory from 500H to 500H + (26)10 to be zero
InitiateSI PROC
    MOV SI ,500H
    MOV CL,26
    MOV AL, 00H
    MYLOOP:  MOV [SI], AL
             INC SI
             DEC CL
             JNZ MYLOOP     
RET
InitiateSI ENDP
;-------------------------------------------------------------------------------
; macro used to print a string.
outStr MACRO msg
    PUSH AX
    PUSH DX
    LEA DX,msg
    MOV AH,09H
    INT 21H
    POP DX
    POP AX
ENDM
;-------------------------------------------------------------------------------
; micro used to print a character.
outChar MACRO ch
    PUSH AX
    PUSH DX
    MOV DL, ch
    MOV AH,02h
    INT 21h
    POP DX
    pop AX
    ENDM
;-------------------------------------------------------------------------------
; micro used to read the choice.
choice MACRO
    MOV AH ,01H
    INT 21H
ENDM
;-------------------------------------------------------------------------------
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
        CALL HIST
        jmp again


case3: cmp bl,"3"    ;check for case 6
       jne case4   ;if not equal,default to case 7 and print the error message
       outStr mc6
       jmp exit
         
case4: outStr mc7   ;print error message
       jmp again   ;display the list again
   
exit:

MOV AH,4CH ; End of program    
INT 21H
;-------------------------------------------------------------------------------
;Text Statistics procesdure
HIST PROC

   MOV wordCount, 1            ;initially there is at least one word
    MOV prevChar, ' '           ;previous is the space character
    CALL InitiateSI             ;initilize the memory 26 locations to zero
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
            JA NOT_ALPHA        ;if the input is not a letter don't count.
            CMP AL, 'a';
            JNAE NOT_ALPHA      ;if the input is not a letter don't count.
            SUB AL,61H;
            ADD SI ,AX;
            MOV CL,01H;
            ADD  [SI], CL       ;Now add one  the letter location if the input is a letter [a-z];
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
            ADD BL,'a'          ;convert to a ascii value
            outChar BL          ;print the value.
            outStr COLUMNSPACE  ;print the " |" string
            MOV BL, [SI]
            FREQ:   outChar '*' ;print stars for its occuerence number.
                    DEC BL
                    JNZ FREQ
                    outChar 10;
            ENDLOOP:    INC SI
                        INC CL
                        MOV BL,26;
                        CMP CL,BL;
    JNE PRINTS
                                ;Print the statistical bars
    outStr ThreeSpace;
    outStr FOURDASH;
    outChar '|';
    outStr FOURDASH;
    outChar '|';
    outStr FOURDASH;
    outChar '|';
    outStr FOURDASH;
    outChar '|';
    outChar 10;
    outStr ThreeSpace;
    outStr FourSpace;
    outChar '5';
    outStr FourSpace;
    outChar '1';
    outChar '0';
    outStr ThreeSpace;
    outChar '1';
    outChar '5';
    outStr ThreeSpace;
    outChar '2';
    outChar '0';
    outChar 10;
                              ;end Print the statistical bars
    outStr NoWords
                              ;if the string end by new line or ' ' decrease the number of words by 1
    MOV BL, ' '
    MOV AL, wordCount
    CMP prevChar,BL           ;check the last entered character.
    JNE SHARP_CASE            ;' ' so decrease by one.
    DEC AL
    SHARP_CASE:  
     CALL convert_display_words
      outStr empty

 RET
HIST ENDP


end start
end