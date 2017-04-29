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
