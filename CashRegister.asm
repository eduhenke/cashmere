; multi-segment executable file template.
#start=LED_Display.exe#
#start=Printer.exe#

include "macros.inc"

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

    total_price dw 0
    test_string db "Teste...$"
    remaining_letters db 0
    
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
	printer_char 12
	
	get_product barcode
	
	printline
	
	
	mov barcode, 2
	get_product barcode
	add_total
	printerln products, item_name
	display_word total_price

	mov barcode, 3
	get_product barcode
    add_total	
	printerln products, item_name
	display_word total_price

    jmp sys_exit   
ends


include "procedures.inc"