.model small
.stack 100h  

.data
enter1 db "Enter the first number: ", '$'
enter2 db "Enter the second number: ", '$'
indent db 0ah, 0dh, '$'
res_sum db "The sum: ", '$'
res_sub db "The remainder: ", '$'
res_mul db "The product: ", '$'
res_div db "The quotient: ", '$'

over db "Overflow", '$' 

max1_len db 4
length1 db 0    ;actual length
num1 db 5 dup('$')   

max2_len db 4
length2 db 0
num2 db 5 dup('$')

ten dw 10
minus dw ?

a dw ?
b dw ?  

.code
start:
    mov ax, @data
    mov ds, ax
    
input1:
    
    lea dx, enter1
    mov ah, 09h
    int 21h
    
    mov ah, 0ah    ;input of the string
    lea dx, max1_len
    int 21h
    
    lea dx, indent    ;moving to the next line
    mov ah, 09h
    int 21h
    
    lea si, num1    ;beginning of the string
    mov bl, length1    ;length of the string
    
string1_to_int:
    xor cx, cx    ;preparing cx for getting the converted number
    call stri
    
    mov a, cx
    
input2:

    lea dx, enter2
    mov ah, 09h
    int 21h
    
    mov ah, 0ah
    lea dx, max2_len
    int 21h
    
    lea dx, indent
    mov ah, 09h
    int 21h
    
    lea si, num2
    mov bl, length2
    
    lea dx, indent
    mov ah, 09h
    int 21h
    
string2_to_int:
    xor cx, cx
    call stri
    
    mov b, cx
    
op_sum:  
    lea dx, res_sum
    mov ah, 09h
    int 21h
    
    xor cx, cx
    
    add cx, a
    add cx, b
    jc overflow
    
    mov ax, cx
    call print
    
    lea dx, indent
    mov ah, 09h
    int 21h
    
op_sub:
    lea dx, res_sub
    mov ah, 09h
    int 21h
    
    xor cx, cx
    
    add cx, a
    sub cx, b
    jc overflow
    
    mov ax, cx
    call print
    
    lea dx, indent
    mov ah, 09h
    int 21h
    
op_mul:
    lea dx, res_mul
    mov ah, 09h
    int 21h
    
    xor ax, ax
    
    add ax, a
    imul b
    jc overflow
    
    call print
    
    lea dx, indent
    mov ah, 09h
    int 21h
    
op_div:
    lea dx, res_div
    mov ah, 09h
    int 21h
    
    xor ax, ax
    xor dx, dx
    
    add ax, a
    mov cx, b
    idiv b
    jc overflow 
    
    call print
    
    lea dx, indent
    mov ah, 09h
    int 21h
        
exit:        
    
    mov ax, 4c00h
    int 21h
    
    ret
    
overflow:
    lea dx, over
    mov ah, 09h
    int 21h
    
    jmp exit
    
stri proc near
push ax    ;preserve working registers
push bx
push dx
push si

mov minus, 0

next_char:
    cmp [si], '$'    ;if the end of the string is reached
    je done
    
    cmp [si], '-'
    je set_minus
    
    cmp [si], '0'    ;if char isn't a digit
    jb done
    cmp [si], '9'
    ja  done
    
    mov bl, [si]
     
    mov ax, cx    ;ex. 545. 0->cx; cx+=5
    mul ten    ;5*10->cx; cx+=4
    mov cx, ax    ;54*10->cx; cx+=5
    
    sub bl, 30h    ;converting char to int
             
    xor bh, bh
    add cx, bx    ;converted number is stored in cx   
    
    inc si    ;moving to the next char

jmp next_char

set_minus:
    mov minus, 1
    inc si
    jmp next_char

done:
cmp minus, 0
je  not_minus
neg cx 

not_minus:
   pop si    ;recover saved registers
   pop dx
   pop bx
   pop ax
   ret
   
stri endp

print proc near
    cmp ax, 0    ;if a quotient is 0
    jne not_zero
    add al, '0'    ;printing '0' out
    mov ah, 0eh
    int 10h
    ret
    
    not_zero:
    cmp ax, 0
    jns positive
    neg ax
    
    push ax

    mov al, '-'
    mov ah, 0eh
    int 10h
    
    pop ax
    
    positive:
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
end start