; multi-segment executable file template.
#start=LED_Display.exe#                   ;Inicia os devices
#start=Printer.exe#
#start=BLU3302.exe#

include "macros.inc"                       ;Adiciona os aiquivos externos.inc

data segment
    include "data.inc"
ends

stack segment                               ; Seleciona um espaco na memoria para Stack
    dw   128  dup(0)
ends

code segment
    call sys_setup
    init:
        clear_printer                       ;Limpa impressora e o display
        clear_display
        printerln header, 0
        
                                            ; Configura as interrupções
        push cx        
        mov cx, offset reset
        configInt 90h, cx
        mov cx, offset barcode_read
        configInt 91h, cx
        mov cx, offset finish
        configInt 92h, cx
        pop cx 
        
        sti    ; Since reset doesn't IRET 
   

    register_product
    
    
    mov barcode, 4                  ;Procedimentos que esperam a adicao de um produto e prepara a impressora
    get_product barcode
    add_total
    display_word total_price
    printline
    
    mov barcode, 1
    get_product barcode
    add_total
    display_word total_price
    printline
    main_loop: 
        mov cx, 2 
        loop main_loop
    jmp sys_exit
ends        
    
include "procedures.inc"
