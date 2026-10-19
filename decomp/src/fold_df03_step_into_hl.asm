; Step the byte at $DF03 and fold it into the nonzero half of HL.
; BC is preserved. Carry on entry feeds the rotate inside the step.
;
; The step is the same rotate-and-xor as $41A3: rotate the byte left
; through carry, and XOR $E9 when the old high bit was clear. $41AF
; then reduces that byte modulo B.
;
; When H is nonzero, H becomes that stepped byte modulo the original H.
; A second step is taken. If the folded byte is below the original H,
; L receives the raw second step. Otherwise L receives that second step
; modulo the original L, and H still holds the first folded byte.
;
; When H is zero and L is zero, HL is left alone.
; When H is zero and L is not, L becomes one step modulo the A that
; was passed in, and H stays zero.

FoldDf03StepIntoHl:
    push bc
    inc h
    dec h
    jr z, .highZero

    ld b, h
    call $41AF
    cp h
    ld h, a
    jr nc, .foldLow

    ld a, [$DF03]
    rla
    jr c, .storeRaw

    xor $E9

.storeRaw
    ld [$DF03], a
    ld l, a
    pop bc
    ret

.foldLow
    ld b, l
    call $41AF
    ld l, a
    pop bc
    ret

.highZero
    inc l
    dec l
    jr nz, .foldIncoming

    pop bc
    ret

.foldIncoming
    ld b, a
    call $41AF
    ld l, a
    pop bc
    ret
