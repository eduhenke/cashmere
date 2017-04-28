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
	mov al, barcode
	call get_price_proc
	xor ax, ax
	mov al, barcode
	call get_name_proc
	
	popa
endm

add_total macro 
	mov ax, item_price
	add total_price, ax
endm

data segment
    ; add your data here!
    string db "print test$"
    pkey db "press any key...$"
    barcode db 0Ah
    item_name dw 0
    item_price dw 0
    total_price dw 0
    test_string db "Teste...$"
    
    ;Estrutura dos dados
    ;IDs           0           1          2
    products db "ERROR$", "macarrao$", "leite$", "quiboa$"
    prices   dw 0FFFFh,   350,         1399,       299 
ends

stack segment
    dw   128  dup(0)
ends

code segment
    call sys_setup
    
	; add your code here
	
	get_product 2
	add_total
	printerln products, item_name
	display_word total_price

	get_product 3
    add_total	
	printerln products, item_name
	display_word total_price
	
;	printerln products
;	
;    display_byte 200
;    printerln test_string
;	
;	; int 90h test
;	mov cx, 2
;    lop:
;    	inc cx
;    	display_byte barcode
;    	loop lop
;	
;    ; print test
;    printerln string
;    printerln pkey
    
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
		mov dl, [bx]
		cmp dl, '$'	; compare to string end
		je endprint
		
		mov ah, 5
		int 21h		; print interruption
		
		inc bx		; get next char
		loop print
	
	endprint:
		mov dl, 10	; new line
		mov ah, 5
		int 21h
		
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
	
get_price_proc:
	mov bx, 2
	mul bx
	mov si, ax
	mov ax, prices[si]
    mov item_price, ax
    ret
    