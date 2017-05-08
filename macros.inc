get_name_position macro index, mem_pos ; a partir de um indice(ID), retorna a posicao na memoria
    mov si, index                      ; do nome do produto
    call get_name_position_proc
    mov mem_pos, si
endm

register_product macro
    ; printa no console
    lea dx, dos_product_name
    mov ah, 9
    int 21h
    ; copia o que foi lido no console para new_product_name
    call buffer_to_name_proc

    ; printa no console
    lea dx, new_line
    mov ah, 9
    int 21h
    lea dx, dos_product_price
    mov ah, 9
    int 21h

    ; copia o que foi lido no console para new_product_price
    call buffer_to_price_proc

    ; printa no console
    lea dx, new_line
    mov ah, 9
    int 21h

    call register_product_proc ; usa new_product_name e new_product_price
endm

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

clear_display macro ; limpa o display de precos
  push ax
  mov ax, 0
  out 199, ax
  pop ax
endm

clear_printer macro
  push ax
  mov ax, 12
  out 130, ax
  pop ax
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

get_product macro code ; setta item_name e item_price para onde comeca o nome do produto na memoria
                       ; e o preco do produto cujo ID eh o barcode
  pusha

	xor ax, ax
	mov al, barcode
	call get_price_proc
	xor ax, ax
	mov al, barcode
	call get_name_proc

	popa
endm

add_total macro ; incrementa total_price com item_price
	mov ax, item_price
	add total_price, ax
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

printtotal macro
	call printtotal_proc
endm

configInt macro vector, procedure_offset
	pusha
	mov ax, 0
	mov es, ax
	mov al, vector
	mov bl, 4
	mul bl
	mov si, ax
	mov es:[si +1], 0000h
	mov es:[si], procedure_offset
	mov es:[si + 2], cs
	popa
endm
