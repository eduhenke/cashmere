; multi-segment executable file template.
#start=LED_Display.exe#
#start=Printer.exe#

include "macros.inc"

get_name_position macro index, mem_pos
    mov si, index
    call get_name_position_proc
    mov mem_pos, si
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
    
    new_product_name db "arroz$"
    new_product_price dw 230
    last_product_index db 3
    ;Estrutura dos dados
    ;IDs           0           1          2
    products db "ERROR$", "macarrao$", "leite$", "quiboa$", 128 dup(0)
    prices   dw 0FFFFh,   350,         1399,       299,     64 dup(0)
ends

stack segment
    dw   128  dup(0)
ends

code segment
    call init
    
    call register_product_proc
	
	get_product barcode
	add_total
	printline
	display_word total_price
	
	mov barcode, 4
	get_product barcode
	add_total
	printline
	display_word total_price


    jmp sys_exit
ends

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
include "procedures.inc"

