.model small
.stack 100h
.data

input db "Your string: $"
string db "This string needs to be reversed$"
result db 0ah, 0dh, "Reversed string: $"

.code

mov ax, @data
mov ds, ax

start:      
    lea dx, input
    mov ah, 09h
    int 21h
            
    lea dx, string
    mov ah, 09h
    int 21h

    lea bx, string

    mov si, bx    ;moves address of the string in bx

next_byte:  
    cmp [si], '$'    ;unless the end of the string is reached
    je the_end
    inc si
jmp next_byte

the_end:             
    dec si           ;corrects the last position of the string

reverse: 
    cmp bx, si    ;bx points to the beginning and si points to the end of string
    jae each_word
    
    ;swapping symbols and moving to the middle of the string         
    mov al, [bx]
    mov ah, [si]
            
    mov [si], al
    mov [bx], ah
            
    inc bx
    dec si
jmp reverse

each_word:      
    lea bx, string

    mov si, bx
            
    jmp next_byte_of_the_word
            
shift:
mov bx, si    ;beginning of the next word 

next_byte_of_the_word:  
    cmp cx, 1h    ;if the last word is reversed
    je stop  

    cmp [si], ' '    ;another word is identified
    je the_end_of_the_word 
            
    cmp [si], '$'    ;the last word is reached
    je the_end_of_the_string  
            
    inc si 
            
jmp next_byte_of_the_word
            
the_end_of_the_string:    ;1h in cx indicates, that the whole string is processed 
    mov cx, 1h

the_end_of_the_word:  
    mov di, si    ;so as not to "spoil" si 
    dec di    ;correcting position of the end
    inc si    ;points to the next word

reverse_of_the_word: 
    cmp bx, di
    jae shift
            
    mov al, [bx]
    mov ah, [di]
            
    mov [di], al
    mov [bx], ah
            
    inc bx
    dec di
jmp reverse_of_the_word

stop:       
    lea dx, result
    mov ah, 09h
    int 21h

    lea dx, string
    mov ah, 09h
    int 21h
            
    mov ah, 4ch    ;the program ends
    int 21h

ret