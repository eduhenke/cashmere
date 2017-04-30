; multi-segment executable file template.
#start=LED_Display.exe#
#start=Printer.exe#

include "macros.inc"

data segment
    ; add your data here!
    string db "print test$"
    pkey db "press any key...$"
    barcode db 0
    item_name dw 0      ; item's name offset
    item_price dw 0
    price_string db "     "
    price_r db "   $"  ; item price in reais
    price_c db "  $"	; itme price in centavos

    total_price dw 0
    test_string db "Teste...$"
    remaining_letters db 0
    header db " SEJA BEM VINDO $"
    total db "total$"
    
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
  		push cx
  		
  		mov cx, offset reset
  		configInt 90h, cx
		mov cx, offset barcode_read
		configInt 91h, cx
		mov cx, offset finish
		configInt 92h, cx
		
		pop cx
		
		sti		; Since reset doesn't IRET
	
	
	
	main_loop:
		mov cx, 2
		loop main_loop

	;

    jmp sys_exit
ends

include "procedures.inc"

