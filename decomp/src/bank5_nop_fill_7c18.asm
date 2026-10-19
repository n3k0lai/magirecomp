; Bank 5 at $7C18. From here through $7FFF the retail image is $00.
; Nothing calls this address. Each byte is a nop, and this window holds
; the last 1000 of them, through the end of the bank.

Bank5NopFill7C18::
    rept 1000
        nop
    endr
