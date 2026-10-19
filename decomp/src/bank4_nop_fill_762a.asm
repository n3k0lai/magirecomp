; Bank 4 at $762A. Opcode5ECountedVramLists ends here, and the retail
; image is $00 through $78FD. Nothing calls this address. Each byte is
; a nop. Bank4NopFill78FE continues the same fill at $78FE.

Bank4NopFill762A::
    rept 724
        nop
    endr
