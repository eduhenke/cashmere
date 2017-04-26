; multi-segment executable file template.
#start=LED_Display.exe#
#start=Printer.exe#

printerln macro str
    push si
    mov si, offset str
    call printerln_proc
    pop si
endm

display macro val   ; mostra em decimal
    push ax
    mov ax, val
    out 199, ax
    pop ax
endm

data segment
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
    call sys_start
    
    display 200
    printerln test_string
    
    jmp sys_exit   
ends

sys_start: ;set segment registers:
    mov ax, data
    mov ds, ax
    mov es, ax
    ret
; end sys_start

sys_exit: ;exit to operating system.
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
