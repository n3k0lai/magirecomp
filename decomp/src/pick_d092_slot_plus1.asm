; Bank 2 at $714F. Index 14 of D0F0JumpWords. JumpHL calls this from
; $6BBA when bit 6 of $D0EE is clear. $71DE also jumps here when any of
; the four $D092 bytes is nonzero.
;
; $70C3 starts at the low two bits of the value from $054F and walks the
; four bytes at HL. Bit 7 of that value picks the direction. It returns
; the index of the first nonzero byte, or $FF when all four are zero.
; A found index is 0 through 3. Adding 1 stores 1 through 4 in $D103.
; $FF becomes 0.
;
; $70C3 is still INCBIN.

PickD092SlotPlus1::
    ld hl, $D092
    call $70C3
    cp $FF
    jr z, .none

    add $01
    jr .store

.none:
    xor a

.store:
    ld [$D103], a
    ret
