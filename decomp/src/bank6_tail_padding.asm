; Unused tail of bank 6. Each byte is $00, a nop, from $7F8A through $7FFF.
Bank6TailPadding::
    rept $76
        nop
    endr
