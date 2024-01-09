bits  16

mov ax, 0x7C0 ; to set up a data segment move a segment value to DS. (0x7C00/0x10)
mov ds, ax
mov ax, 0x7E0 ; stack starts after the bootloader which ends at 0x7E00
mov ss, ax
mov sp, 0x2000 ; stack starts at 0x7E00 + 0x2000

call clearscreen

push 0x0000
call movecursor
add sp, 2

push msg
call print
add sp, 2

cli
hlt

clearscreen:
    push bp
    mov bp, sp
    pusha

    mov ah, 0x07  ; BIOS video service code for scrolling down the window 
    mov al, 0x00 ; clear the entire window
    mov bh, 0x07 ; white text on black background
    mov cx, 0x0000 ; specifies top left of the screen as (0,0)
    mov dh, 0x18 ; 24 rows of characters
    mov dl, 0x4f ; 79 columns of characters
    int 0x10 ; call BIOS video interupt 

    popa
    mov sp, bp
    pop bp
    ret 


movecursor:
    push bp
    mov bp, sp
    pusha

    mov dx, [bp+4] ; get the argument from the stack. |bp| = 2 , |arg| = 2
    mov ah, 0x02 ; set cursor position
    mov bh, 0x00 ; page 0
    int 0x10

    popa
    mov sp, bp
    pop bp
    ret

print:
    push bp
    mov bp, sp
    pusha
    mov si, [bp+4] ; grap the pointer to the data
    mov bh, 0x00 ; page number, 0 again
    mov bl, 0x00 ; foreground color, 
    mov ah, 0x0E ; print character to TTY
.char:
    mov al, [si] ; grab the pointer to the data
    add si, 1 ; keep incrementing si until we see a null char
    or al, 0 
    je .return ; end if the string is done
    int 0x10 ; print the character if not done
    jmp .char ; keep looping
.return: 
    popa 
    mov sp, bp
    pop bp
    ret

msg: db "Assembly is fun mate!!!", 0

times 510-($-$$) db 0
dw 0xAA55

