; Bank 2 at $458C. The $452A test jumps here when [$D071] is nonzero.
;
; A value of 2 skips the bank 5 call at $5A1A and joins $459B, which is
; the [$D016] test inside ContinueAfterC71BPlant. Any other value falls
; through into that routine at $4593.

Join459BIfD071IsTwo::
    ld a, [$D071]
    cp $02
    jr z, $459B
