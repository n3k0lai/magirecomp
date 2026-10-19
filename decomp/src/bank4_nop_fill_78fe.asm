; Bank 4 at $78FE. From here through $7FFF the retail image is $00.
; Nothing calls this address. Each byte is a nop, and this window holds
; 1024 of them. The same fill continues in the following INCBIN.

Bank4NopFill78FE::
    rept 1024
        nop
    endr
