; multi-segment executable file template.

data segment
    ; add your data here!
    string db "print test$"
    pkey db "press any key...$"
    barcode db 00h
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
    
    ; config int 90h
    push es
    mov ax, 0h
    mov es, ax
    mov es:[4*90h+1], 0000h
	mov es:[4*90h], offset barcode_read
	mov es:[4*90h + 2], cs
	pop es
	
	
	; int 90h test
	mov cx, 2
    lop:
    	inc cx
    	mov al, barcode
    	out 22h, al
    	loop lop
	
    ; print test
    mov si, offset string
    call printerln
    mov si, offset pkey
    call printerln
    
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

barcode_read:
	push ax
	
	in al, 20h
	mov barcode, al
	
	pop ax
	iret

printerln:
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