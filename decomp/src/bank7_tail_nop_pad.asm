; File $01FCC2 ($7CC2) through $01FFFF is the unused tail of bank 7.
; Each byte is $00. The last live instruction before this fill is the
; ret at $74CB. Nothing branches here.

Bank7TailNopPad::
    rept $8000 - $7CC2
        nop
    endr
