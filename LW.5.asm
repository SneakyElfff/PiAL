.model small
.stack 100h

.data
file db "c:\lw5\strings.txt", 0  
handle dw ?

result db 10, 13, 10, 13, "The number of blank lines in the file: ", '$'

buffer db ?
counter dw ?

ten dw 10

.code
start:
    mov ax, @data
    mov ds, ax

open_file:
    mov ah, 3dh    ;open the existing file 
    mov al, 0    ;open for reading
    mov dx, offset file
    int 21h
    jc error    ;if CF=1
    mov handle, ax
    
read_the_byte:
    mov bx, handle
    mov ah, 3fh    ;read sth from file
    mov cx, 1h
    mov dx, offset buffer
    int 21h

print_the_byte:    
    push ax
    mov dl, buffer
    mov ah, 02h
    int 21h
    pop ax
    
    cmp ax, 0    ;if the end of the file is reached
    je print_the_result
    
    cmp buffer, 0ah    ;if '\n' is met
    je possible
    
    jmp read_the_byte

possible:
    mov bx, handle
    mov ah, 3fh
    mov cx, 1h
    mov dx, offset buffer    ;check, whether the next line is blank
    int 21h
    
    mov ah, 42h    ;fseek
    mov al, 1    ;from current position
    mov cx, 0
    mov dx, -1
    int 21h
    
    cmp buffer, 0dh
    jne read_the_byte
    
found:
    inc counter
    jmp read_the_byte
    
print_the_result:
    mov ah, 9h
    lea dx, result
    int 21h
    
    mov ax, counter
    call print        
    
close_file:
    mov ah, 3eh
    mov bx, handle
    int 21h
    
exit:
    mov ax, 4c00h
    int 21h
    ret
    
error:
    nop
        
print proc near
    cmp ax, 0    ;if a quotient is 0
    jne not_zero
    add al, '0'    ;printing '0' out
    mov ah, 0eh
    int 10h
    ret
    
    not_zero:
    push ax
    push bx
    push cx
    push dx
    
    mov bx, 10000
    
    begin:
        cmp bx, 0    ;if devider equals zero
        jz end
        
        cmp cx, 0    ;avoid printing zeros before numbers
        je calc
        
        cmp ax, bx    ;if ax<bx, the result is 0
        jb skip
        
        calc:
            xor cx, cx
            
            xor dx, dx    ;remainder
            div bx
            
            add al, 30h    ;printing the last digit
            mov ah, 0eh
            int 10h
            
            mov ax, dx    ;remainder is stored in ax
            
            skip:    ;bx/=10
                push ax
                xor dx, dx
                mov ax, bx
                div ten
                mov bx, ax
                pop ax
                
                jmp begin
        
        end:
            pop dx
            pop cx
            pop bx
            pop ax
    
            ret   
    
print endp