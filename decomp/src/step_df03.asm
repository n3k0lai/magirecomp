; Step the byte at $DF03.
;
; Rotate it left through carry. Carry on entry becomes the new low bit,
; and the old high bit becomes carry. When that high bit was clear, XOR
; $E9 into the result. The stepped byte is stored back and returned in A.

StepDf03:
    ld a, [$DF03]
    rla
    jr c, .store
    xor $E9

.store
    ld [$DF03], a
    ret
