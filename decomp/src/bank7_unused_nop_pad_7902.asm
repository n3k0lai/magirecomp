; File $01F902 (CPU $7902) through $01FCC1 is unused zero fill in bank 7.
; Each byte is $00. The last live instruction before this fill is the
; ret at $74CB. The pad from $7CC2 to the end of the bank is separate.
; Nothing in this bank branches here.

Bank7UnusedNopPadAt7902::
    rept $7CC2 - $7902
        nop
    endr
