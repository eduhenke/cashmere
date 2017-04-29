; multi-segment executable file template.
#start=LED_Display.exe#
#start=Printer.exe#

include "macros.inc"

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
    header db " SEJA BEM VINDO $"
    
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
    
    init:
		clear_printer
		clear_display
		
		printerln header, 0
  	
  		; config int 90h
		push es
		mov ax, 0h
		mov es, ax
		mov es:[4*90h+1], 0000h
		mov es:[4*90h], offset reset
		mov es:[4*90h + 2], cs
		pop es
	
	
	main_loop:
		mov cx, 2
		loop main_loop

	;

    jmp sys_exit
ends

include "procedures.inc"

