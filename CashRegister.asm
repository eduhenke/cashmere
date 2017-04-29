; multi-segment executable file template.
#start=LED_Display.exe#
#start=Printer.exe#

include "macros.inc"

data segment
    ; add your data here!
    string db "print test$"
    pkey db "press any key...$"
    barcode db 0Ah
    item_name dw 0
    item_price dw 0
    total_price dw 0
    test_string db "Teste...$"

    ;Estrutura dos dados
    ;IDs           0           1          2
    products db "ERROR$", "macarrao$", "leite$", "quiboa$"
    prices   dw 0FFFFh,   350,         1399,       299
ends

stack segment
    dw   128  dup(0)
ends

code segment
    call init

	; add your code here
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
