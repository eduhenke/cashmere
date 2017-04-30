string db "print test$"
pkey db "press any key...$"
new_line db 10,13,"$"
dos_intro db "Funcionalidades:",10,13,"'l'-listar produtos",10,13,"'r'-registrar produto",10,13,"'e'-excluir produto",new_line
dos_product_name db "Digite o nome do produto:",10,13,"$"
dos_product_price db "Digite o preco do produto(em centavos):",10,13,"$"
barcode db 2
item_name dw 0      ; item's name offset
item_price dw 0
item_price_string db "     "
item_price_r db "   $"  ; item price in reais
item_price_c db "  $"	; itme price in centavos

total_price dw 0
test_string db "Teste...$"
remaining_letters db 0

ten dw 10
buffer db 10, 10 dup(0)
new_product_name db 10 dup(0)
new_product_price dw 230
last_product_index db 3
;Estrutura dos dados
;IDs           0           1          2
products db "ERROR$", "macarrao$", "leite$", "quiboa$", 128 dup(0)
prices   dw 0FFFFh,   350,         1399,       299,     64 dup(0)
