; Bank 5 at $6C18. From here through $7FFF the retail image is $00.
; Nothing calls this address. Each byte is a nop, and this window holds
; 1024 of them. The same fill continues in the following INCBIN.

Bank5NopFill6C18::
    rept 1024
        nop
    endr
