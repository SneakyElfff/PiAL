.model tiny                   ;code and data are located in a single segment
.code                         ;beginning of the code segment
ORG 100h                      ;code must start only after PSP
begin:     
    mov ah, 09h               ;9h-function prints a string out
    mov dx, offset input     
    int 21h                   ;interruption, which calls a DOS fucntion, located in ah  
    mov ah, 0ah               ;0Ah-function reads sth from stdin, moves the cursor to the next line
    mov dx, offset string     ;address of the input string
    int 21h    
    
    mov string+1, 0ah         ;specifying a line break
    
    mov ah, 09h
    mov dx, offset string+1
    int 21h
    
    ret     
input db "Enter your string: $" 
string db 100 dup ('$')
    end begin  