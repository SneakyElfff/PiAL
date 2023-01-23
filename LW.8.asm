//
//  LW.8.s
//  ASM.LW.8
//
//  Created by Нина Альхимович on 10.12.22.
//

.model tiny  
org 100h

.data
file_name db "file.txt", 0
handler dw 0000h

new_file_name db "print.txt", 0
new_handler dw 0000h

num_of_bytes dw 0000h
size_of_string dw 0000h

invite db ": $"
farewell db "The End.$"

;buffers                
empty_line db 0ah, 0dh, "$"
string db 50, 52 dup ('$')
file_buffer db 202 dup ('$')
screen_buffer db 202 dup ('$')

old_int dd 0
old_int_offset dw 0    ;the address of the old interrupter
old_int_segment dw 0

.code
start:

    call saveOldInt
    call installNewInt

open_file:
    mov ah, 3Dh    ;3Dh opens a file
    mov al, 02h    ;for reading and writing
    lea dx, file_name
    int 21h

    mov handler, ax    ;get the file handler

    mov dx, offset invite
    mov ah, 09h
    int 21h

    mov dx, offset string
    mov ah, 0Ah
    int 21h
    
    mov dx, offset empty_line
    mov ah, 09h
    int 21h

read_from_file:
    mov bx, handler

    mov ah, 3Fh    ;3Fh-function reads sth from the file
    mov cx, 00C8h    ;00C8h = 200 bytes
    mov dx, offset file_buffer
    int 21h

    mov num_of_bytes, ax

    mov ax, num_of_bytes
    cmp ax, 0000h    ;if everything's been read

je done_reading

print_on_the_screen:
    mov si, offset file_buffer
    mov dx, offset file_buffer
    mov ah, 09h
    int 21h

jmp read_from_file

done_reading:
    mov dx, offset empty_line
    mov ah, 09h
    int 21h
    
    lea dx, farewell
    mov ah, 09h
    int 21h
    
    mov dx, offset empty_line
    mov ah, 09h
    int 21h

close_file:
    mov bx, handler
    xor ax, ax
    mov ah, 3Eh    ;3Eh-function closes the file
    int 21h
    
check_Prt_Scr:
    mov ah, 00h    ;if key pressed, compare it with the code of PrintScreen
    int 16h        
    cmp al, 2ch    ;PrintScreen - 2ch

int 05h

call setOldInt

exit:

    int 20h


saveOldInt proc
    push es
    push ax
    push bx

    mov ah, 35h    ;35h-function gets the address of the interrupter
    mov al, 05h    ;number of the interruption
    int 21h

    mov word ptr old_int, bx
    mov word ptr old_int + 2, es

    mov old_int_offset, bx
    mov old_int_segment, es

    pop bx
    pop ax
    pop es
    ret
saveOldInt endp

installNewInt proc
    cli    ;interruptions are forbidden

    push ax
    push dx
    push es
    push ds
    pop es

    mov dx, offset newInt
    mov ah, 25h    ;25h-function sets the address of the new interrupter
    mov al, 05h    ;number of the interruption
    int 21h

    pop es
    pop ax
    pop dx

    sti    ;interruptions are allowed

    ret
installNewInt endp

setOldInt proc
    cli    ;interruptions are forbidden

    push bx
    push es
    push ax
    push ds
    pop es

    mov dx, old_int_offset
    mov ds, old_int_segment
    mov ah, 25h    ;25h-function installs the address of the interruption
    mov al, 05h    ;number of the interruption
    int 21h

    pop ax
    pop es
    pop bx

    sti    ;interruptions are allowed

    ret
setOldInt endp

newInt proc
    cli    ;interruptions are forbidden

    pushf
    pusha
    push ds
    push es
    push cs
    pop ds

    mov ah, 3Dh    ;3Dh opens a file
    mov al, 02h    ;for reading and writing
    lea dx, new_file_name
    int 21h

    mov new_handler, ax

    push 0B800h    ;the segment of display in videomode
    pop es
    mov cx, 0000h

    mov di, offset screen_buffer
    xor ax, ax

get_the_contents:
    cmp ax, 200
    jae screen_to_file    ;if 200 >= ax

    cmp cx, 047FFh    ;size of the screen buffer
    jae done

    mov bx, cx
    push es:[bx]
    pop cs:[di]

    inc cx
    inc cx
    inc di
    inc ax

jmp get_the_contents

screen_to_file:
    mov ax, 200

    pusha
    lea dx, screen_buffer
    mov bx, new_handler
    mov cx, ax    ;number of bytes to write
    mov ah, 40h    ;40h-function writes sth to the file
    int 21h
    popa

    xor ax, ax
    mov di, offset screen_buffer

jmp get_the_contents

done:
    mov ax, 200
    
    pusha
    lea dx, screen_buffer
    mov bx, new_handler
    mov cx, ax    ;number of bytes to write
    mov ah, 40h    ;40h-function writes sth to the file
    int 21h
    popa

    pop es
    pop ds
    popa
    popf

    sti    ;interruptions are allowed

    push ax
    mov al, 20h
    out 20h, al    ;indicates that interruption is over
    pop ax

    iret
newInt endp
