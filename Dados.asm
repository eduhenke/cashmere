; multi-segment executable file template.


#start=wxBLU3302.exe#

data segment
    produtos db "macarrao$", "leite$", "quiboa$"
    precos   db 3, 50      , 3, 99   , 2, 99 
ends

stack segment
    db 128 dup(0)
ends

code segment
start:
; setta onde ta o stack
    mov ax, stack
    mov ds, ax
    mov es, ax
; codigo
    

    jmp exit
ends

exit:
    mov ax, 4c00h ; exit to operating system.
    int 21h

end start ; set entry point and stop the assembler.
