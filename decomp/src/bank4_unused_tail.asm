; Bank 4 from $7CFE through $7FFF. The counted VRAM lists end at $7629
; (file $013629). Every byte from there to the end of the bank is $00,
; so this tail is unused padding. Opcode $00 is nop.

Bank4UnusedTail::
    REPT $14000 - $13CFE
        nop
    ENDR
