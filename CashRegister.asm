; multi-segment executable file template.
#start=LED_Display.exe#
#start=Printer.exe#

printerln macro str
    push si
    mov si, offset str
    call printerln_proc
    pop si
endm

display_word macro val   ; mostra word no display
    push ax
    mov ax, val
    out 199, ax
    pop ax
endm

display_byte macro val   ; mostra byte/char no display
    push ax
    xor ax, ax	; limpa AX
    mov al, val
    out 199, al
    pop ax
endm

data segment
    ; add your data here!
    string db "print test$"
    pkey db "press any key...$"
    barcode db 00h
    test_string db "Teste...$"
    
    ;Estrutura dos dados
    ;IDs         01h           02h       03h...
    produtos db "macarrao$", "leite$", "quiboa$"
    precos   db 3, 50      , 3, 99   , 2, 99 
ends

stack segment
    dw   128  dup(0)
ends

code segment
    call sys_setup
    
	; add your code here
	
    display_byte 200
    printerln test_string
	
	; int 90h test
	mov cx, 2
    lop:
    	inc cx
    	display_byte barcode
    	loop lop
	
    ; print test
    printerln string
    printerln pkey
    
    ; end code

    jmp sys_exit   
ends

sys_setup: ;set segment registers:
    mov ax, data
    mov ds, ax
    mov es, ax
	
	; config int 90h
    push es
    mov ax, 0h
    mov es, ax
    mov es:[4*90h+1], 0000h
	mov es:[4*90h], offset barcode_read
	mov es:[4*90h + 2], cs
	pop es
	
    ret
; end sys_setup

barcode_read:
	push ax
	
	in al, 20h
	mov barcode, al
	
	pop ax
	iret


sys_exit: ;exit to operating system.
    lea dx, pkey
    mov ah, 9
    int 21h        ; output string at ds:dx
    
    ; wait for any key....    
    mov ah, 1
    int 21h
	
	mov ax, 4c00h
    int 21h
    
printerln_proc:
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
;end printerln_proc
