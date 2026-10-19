; File $01F54C (CPU $754C) through $01F8C1 is unused zero fill in bank 7.
; Each byte is $00, so each one is a nop. The last live instruction
; before this fill is the ret at $74CB. The pad from $78C2 onward is
; a separate slice. Nothing in this bank branches here.

Bank7UnusedNopPadAt754C::
    rept $78C2 - $754C
        nop
    endr
