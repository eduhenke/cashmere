; multi-segment executable file template.


#start=das5332_Temp.exe#

data segment
    ; add your data here!
    pkey db "press any key...$"
ends

stack segment
    db   128  dup(3)
ends

code segment
start:
; set segment registers:
    mov ax, stack
    mov ds, ax
    mov es, ax

    ; add your code here
    
    lea dx, pkey
    mov ah, 9
    int 21h        ; output string at ds:dx
    
    ; wait for any key....    
    mov ah, 1
    int 21h
    
    mov ax, 4c00h ; exit to operating system.
    int 21h    
ends

end start ; set entry point and stop the assembler.

