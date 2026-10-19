; Divide HL by BC and return the quotient in HL.
; DE is saved across the call. The divider itself is still at $40B0.

DivideHlByBc:
    push de
    call $40B0
    pop de
    ret
