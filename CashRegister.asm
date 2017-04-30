; multi-segment executable file template.
#start=LED_Display.exe#
#start=Printer.exe#
#start=BLU3302.exe#

include "macros.inc"

data segment
    include "data.inc"
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
        sti    ; Since reset doesn't IRET 
   

    register_product
    
    
    mov barcode, 4
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