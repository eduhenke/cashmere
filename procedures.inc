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
	mov cx, 5
  xor dx, dx
  cwd
	cleanVars:
		mov si, cx
		dec si
		mov item_price_string[si], ' '

		loop cleanVars

	mov cx, 5

	convert:
		div ten

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
  get_name_position_proc:
      xor bx, bx
      xor ax, ax
      mov dx, si
      xor si, si
      search_name_pos:
      mov al, products[si]
      cmp ax, "$"
      jne continue_name
      inc bx
      cmp bx, dx
      je ret_si
      continue_name:
          inc si
          jmp search_name_pos
      ret_si:
          inc si
          ret

  register_product_proc:
      pusha
      inc last_product_index
      xor ax, ax
      mov al, last_product_index
      get_name_position ax, si
      xor bx, bx
      xor ax, ax
      write_name_rp:
          mov al, new_product_name[bx]
          inc bx
          mov products[si], al
          inc si
          cmp al, "$"
          jne write_name_rp
      ; add price
      xor ax, ax
      mov al, last_product_index
      mov si, ax
      mov ax, new_product_price
      mov bx, si
      add bx, si
      mov prices[bx], ax
      popa
      ret

  buffer_to_name_proc:
      call set_buffer_registers_proc
      loop_reg_name:
          mov al, [bx+si+1]   ; +1 to ignore second byte
          mov new_product_name[si], al
          inc si
          loop loop_reg_name
          mov new_product_name[si], "$"
      ret

  set_buffer_registers_proc:
      lea dx, buffer
      mov ah, 0Ah
      int 21h
      xor ax, ax
      lea bx, buffer         ; buffer first byte tells its size, second byte how many chars read
      add bx, 1              ; buffer second byte
      mov al, [bx]           ; ax = number of chars read
      mov cx, ax             ; will loop ax times
      xor si, si
      xor ax, ax
      ret

  clear_reg_name_proc:
      mov al, new_product_name[si]
      mov new_product_name[si], 0
      inc si
      cmp al, "$"
      jne clear_reg_name_proc
      ret

  buffer_to_price_proc:
      call set_buffer_registers_proc
      loop_int:
          xor dx, dx
          mov dl, [bx+si+1]   ; +1 to ignore second byte
          sub dl, "0"
          add ax, dx
          inc si
          mul ten
          loop loop_int
      div ten
      mov new_product_price, ax
      ret
