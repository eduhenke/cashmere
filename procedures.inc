init:
  clear_display
  clear_printer
  call sys_setup
  ret

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

get_price_proc:
	mov bx, 2
	mul bx
	mov si, ax
	mov ax, prices[si]
  mov item_price, ax
  ret


toString_proc:		; convert AX to string @ item_price_string
	mov bx, 10
	mov cx, 5

	cleanVars:
		mov si, cx
		dec si
		mov item_price_string[si], ' '

		loop cleanVars

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
		sub remaining_letters, bl
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
