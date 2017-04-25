; multi-segment executable file template.

data segment
    ; add your data here!
    string db "print test$"
    pkey db "press any key...$"
ends

stack segment
    dw   128  dup(0)
ends

code segment
start:
; set segment registers:
    mov ax, data
    mov ds, ax
    mov es, ax

    ; add your code here
    
    mov si, offset string
    call println
    mov si, offset pkey
    call println
    
    ; end code
            
    lea dx, pkey
    mov ah, 9
    int 21h        ; output string at ds:dx
    
    ; wait for any key....    
    mov ah, 1
    int 21h
    
    mov ax, 4c00h ; exit to operating system.
    int 21h    
ends

println:
	push dx
	push cx
	push ax
	
	mov cx, 100		; loop limit
	
	print:
		mov dl, [si]
		cmp dl, '$'	; compare to string end
		je endprint
		
		mov ah, 5
		int 21h		; print interruption
		
		inc si		; get next char
		loop print
	
	endprint:
		mov dl, 10	; new line
		mov ah, 5
		int 21h
		
		pop ax
		pop cx
		pop dx
		
		ret


end start ; set entry point and stop the assembler.