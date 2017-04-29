printerln macro str, offs
    push bx
    mov bx, offset str
    add bx, offs
    call printerln_proc
    pop bx
endm

clear_display macro
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
