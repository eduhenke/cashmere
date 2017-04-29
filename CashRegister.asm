; multi-segment executable file template.
#start=LED_Display.exe#
#start=Printer.exe#

printerln macro str, offs
    push bx
    mov bx, offset str
    add bx, offs
    call printerln_proc
    pop bx
endm

printer macro str, offs
	push bx
	mov bx, offset str
	add bx, offs
	call printer_proc
	pop bx
endm

printer_char macro char
	pusha
	
	mov ah, 5
	mov dl, char
	int 21h
	
	popa
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

get_product macro code
	pusha
	
	xor ax, ax
	mov al, code
	mov bx, 2
	mul bx
	mov si, ax
	mov ax, prices[si]
    mov item_price, ax
	display_word item_price
	xor ax, ax
	mov al, code
	call get_name_proc
	
	popa
endm

toString macro price
	pusha
	
	mov ax, price
	call toString_proc
	
	popa
endm

printline macro
	call printline_proc
endm


data segment
    ; add your data here!
    string db "print test$"
    pkey db "press any key...$"
    barcode db 2
    item_name dw 0      ; item's name offset
    item_price dw 0
    item_price_string db "     "
    item_price_r db "   $"  ; item price in reais
    item_price_c db "  $"	; itme price in centavos
    test_string db "Teste...$"
    remaining_letters db 0
    
    ;Estrutura dos dados
    ;IDs           0           1          2
    products db "ERROR$", "macarrao$", "leite$", "quiboa$"
    prices   dw 0FFFFh,   350,         399,       299 
ends

stack segment
    dw   128  dup(0)
ends

code segment
    call sys_setup
    
	; add your code here
	printer_char 12
	
	get_product barcode
	
	printline
	
	

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
	
	println:
		mov dl, [bx]
		cmp dl, '$'	; compare to string end
		je endprintln
		
		mov ah, 5
		int 21h		; print interruption
		
		inc bx		; get next char
		loop println
	
	endprintln:
		mov dl, 10	; new line
		mov ah, 5
		int 21h
		
		pop ax
		pop cx
		pop dx	
        ret

printer_proc:
	push dx
	push cx
	push ax
	
	mov cx, 100		; loop limit
	
	print:
		mov dl, [bx]
		cmp dl, '$'	; compare to string end
		je endprint
		
		mov ah, 5
		int 21h		; print interruption
		
		inc bx		; get next char
		loop print
	
	endprint:
		pop ax
		pop cx
		pop dx	
        ret


get_name_proc:
    xor si, si
	xor bx, bx
	cmp ax, bx
	jbe ret_name
	
	mov cx, 100
	
	search_name:
		cmp products[si], "$"
		jne continue
		
		new_word:
		inc bx
		cmp ax, bx
		je ret_name
		
		continue:
		inc si
		loop search_name
	
	
	ret_name:
		inc si
		mov item_name, si
	ret
	
toString_proc:		; convert AX to string @ item_price_string
	mov bx, 10
	mov cx, 5
	
	convert:
		div bx
		
		add dx, '0'
		mov si, cx
		dec si
		mov item_price_string[si], dl
		
		xor dx, dx
		
		cmp ax, 0
		je break
		
		loop convert
	break:
	
	mov al, item_price_string[0]
	mov item_price_r[0], al
	mov al, item_price_string[1]
	mov item_price_r[1], al
	mov al, item_price_string[2]
	mov item_price_r[2], al
	mov al, item_price_string[3]
	mov item_price_c[0], al
	mov al, item_price_string[4]
	mov item_price_c[1], al
	
	ret
	
printline_proc:
	pusha
	mov remaining_letters, 16
	mov si, item_name
	
	xor bx, bx
	mov cx, 0FFh
	count_letters:
		cmp products[si+bx], '$'
		je printa
		
		inc bx
		loop count_letters
	
	printa:
		dec remaining_letters, bx
		printer products, item_name
	
	xor cx, cx
	mov cl, remaining_letters
	sub cx, 5	; number of chars for price
	
	
	push ax
	push dx
	print_spaces:
		mov ah, 5
		mov dl, ' '
		int 21h
		
		loop print_spaces
	pop dx
	pop ax
	
	toString item_price
	
	printer item_price_r, 0
	
	printer_char '.'
	
	printerln item_price_c, 0
		
	popa
	ret