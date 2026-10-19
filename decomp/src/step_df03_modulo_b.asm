; Step the byte at $DF03, then return that byte modulo B.
;
; The step itself is still at $41A3: rotate the byte left through carry
; and XOR $E9 when the old high bit was clear. Carry on entry feeds that
; rotate. If the stepped byte is already below B it is returned as-is.
; Otherwise B is subtracted until the result is below B.

StepDf03ModuloB:
    call $41A3
    cp b
    ret c

.subtract
    sub b
    cp b
    jr nc, .subtract
    ret
