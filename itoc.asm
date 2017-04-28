
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h

mov ax, 350

mov bl, 10
mov cx, 3
lop:
div bl

add ah, '0'

mov si, cx
dec si
mov string[si], ah

xor ah, ah
loop lop

ret


string db '   '

