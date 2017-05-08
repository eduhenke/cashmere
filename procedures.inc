sys_setup:
	; determina os registradores de segmento
	mov ax, data
	mov ds, ax
	mov es, ax

    ret
; end sys_setup

reset:
	jmp init

barcode_read:
	push ax

	; pega os valores do painel BLU_3302
	in al, 20h
	mov barcode, al

	; rotina para atualizar a nota impressa
	get_product barcode

	add_total

	display_word total_price

	printline

	pop ax
	iret

finish:
	printtotal
	push cx
	mov cx, offset do_nothing
	configInt 91h, cx
	mov cx, offset do_nothing
	configInt 92h, cx
	pop cx
	iret

do_nothing:
	iret

sys_exit: ; retorna para o sistema operacional
	mov ax, 4c00h
  int 21h

printerln_proc:
	push dx
	push cx
	push ax

	mov cx, 100		; limite do loop

	println:
		mov dl, [bx]
		cmp dl, '$'	; caractere '$' indica final da string
		je endprintln

		mov ah, 5
		int 21h		; interrupção que imprime

		inc bx		; pega próximo char
		loop println

	endprintln:
		mov dl, 10	; nova linha
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

	mov cx, 100		

	print:
		mov dl, [bx]
		cmp dl, '$'	
		je endprint

		mov ah, 5
		int 21h		

		inc bx		
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

	search_name:	; conta '$' no vetor de nomes de produtos para encontrar o produto de acordo com o índice
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

get_price_proc: ; retorna o preco do produto cujo ID é ax
	mov bx, 2
	mul bx
	mov si, ax
	mov ax, prices[si]
  mov item_price, ax
  ret


toString_proc:		; converte AX para string em price_string
	mov cx, 5
  xor dx, dx
  cwd
	cleanVars:	; limpa valores anteriores
		mov si, cx
		dec si
		mov price_string[si], ' '

		loop cleanVars

	mov cx, 5

	convert:	; converte de inteiro para string através de divisões por 10 e utilizando o resto da divisão
		div ten

		add dx, '0'
		mov si, cx
		dec si
		mov price_string[si], dl

		xor dx, dx

		cmp ax, 0
		je break

		loop convert
	break:

	; move de price_string para price_r e price_c para se ter controle dos caracteres
	mov al, price_string[0]
	mov price_r[0], al
	mov al, price_string[1]
	mov price_r[1], al
	mov al, price_string[2]
	mov price_r[2], al
	mov al, price_string[3]
	mov price_c[0], al
	mov al, price_string[4]
	mov price_c[1], al

	ret

printline_proc:		; procedimento de imprimir a linha na nota com nome e preço do produto
	pusha
	mov remaining_letters, 16	; faz o controle de caracteres para alinhar os valores
	mov si, item_name

	xor bx, bx
	mov cx, 0FFh
	count_letters:	; conta as letras do preço do produto
		cmp products[si+bx], '$'
		je printa

		inc bx
		loop count_letters

	printa:
		sub remaining_letters, bl	; subtrai a quantidade de caracteres da palavra dos espaços restantes
		printer products, item_name

	xor cx, cx
	mov cl, remaining_letters
	sub cx, 6	; número de caracteres máximo por preço + '.'


	push ax
	push dx
	print_spaces:	; imprime a quantidade de espaços necessários para que o preço fique alinhado à direita
		mov ah, 5
		mov dl, ' '
		int 21h

		loop print_spaces
	pop dx
	pop ax

	toString item_price	; converte o preço para string

	; imprime o preço formatado com um ponto para separar reais de centavos
	printer price_r, 0
	printer_char '.'
	printerln price_c, 0

	popa
	ret

printtotal_proc:	; imprime o preço total no momento de finalização da compra
			; bastante similar à print_line_proc
	pusha
	mov remaining_letters, 16

	xor bx, bx
	mov cx, 0FFh
	t_count_letters:
		cmp total[bx], '$'
		je t_printa

		inc bx
		loop t_count_letters

	t_printa:
		sub remaining_letters, bl
		printer total, 0

	xor cx, cx
	mov cl, remaining_letters
	sub cx, 6	; número de caracteres do preço + '.'


	push ax
	push dx
	t_print_spaces:
		mov ah, 5
		mov dl, ' '
		int 21h
		loop t_print_spaces
	pop dx
	pop ax

	toString total_price

	printer price_r, 0

	printer_char '.'

	printerln price_c, 0

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
      get_name_position ax, si ; pega a posicao na memoria do (ultimo produto+1)
      xor bx, bx
      xor ax, ax
      write_name_rp: ; escreve o nome do novo produto na lista de strings
          mov al, new_product_name[bx]
          inc bx
          mov products[si], al
          inc si
          cmp al, "$"
          jne write_name_rp
      xor ax, ax
      mov al, last_product_index
      mov si, ax ; si <= last_product_index
      mov ax, new_product_price
      mov bx, si ; bx <= last_product_index
      add bx, si ; bx <= 2*last_product_index, pois eh word
      mov prices[bx], ax ; prices[2*last_product_index] <= new_product_price
      popa
      ret

  buffer_to_name_proc: ; copia o que foi lido no console para new_product_name
      call set_buffer_registers_proc  ; setta alguns registradores
      loop_reg_name:
					mov al, [bx+si+1]  ; [bx+si+1] => bx eh a posicao na memoria do buffer, si um indice
          									 ; e +1 para ignorar o segundo byte, que n eh parte da string lida
          mov new_product_name[si], al
          inc si
          loop loop_reg_name
          mov new_product_name[si], "$" ; para terminar a string
      ret

  set_buffer_registers_proc: ; setta os registradores para auxiliar na lida do buffer
      lea dx, buffer
      mov ah, 0Ah
      int 21h
      xor ax, ax
      lea bx, buffer         ; primeiro byte do buffer diz seu tamanho, o segundo quantos chars foram lidos pelo console
      add bx, 1              ; segundo byte do buffer(num de chars lidos)
      mov al, [bx]           ; ax = num de chars lidos
      mov cx, ax             ; para loopar ax vezes(toda a string lida)
      xor si, si
      xor ax, ax
      ret

  clear_reg_name_proc: ; limpa new_product_name
      mov al, new_product_name[si]
      mov new_product_name[si], 0
      inc si
      cmp al, "$"
      jne clear_reg_name_proc
      ret

  buffer_to_price_proc: ; copia o que foi lido no console para new_product_price
      call set_buffer_registers_proc
      loop_int:
          xor dx, dx
          mov dl, [bx+si+1] ; +1 para ignorar o segundo byte, que n eh parte da string lida
          sub dl, "0" 			; converter o char lido para int
          add ax, dx				; move para ax para multiplicar(em baixo)
          inc si
          mul ten						; multiplica ax por 10 => string lida "120" => 1*10*10 + 2*10 + 0
          loop loop_int
      div ten ; divide ax por 10, pois eh realizada uma multiplicacao a mais no loop
      mov new_product_price, ax
      ret
