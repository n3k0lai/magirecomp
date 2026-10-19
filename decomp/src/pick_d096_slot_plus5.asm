; Bank 2 at $7191. Index 8 of D0F0JumpWords. JumpHL calls this from
; $6BBA when bit 6 of $D0EE is clear.
;
; $70C3 starts at the low two bits of the value from $054F and walks the
; four bytes at HL. Bit 7 of that value picks the direction. It returns
; the index of the first nonzero byte, or $FF when all four are zero.
; A found index is 0 through 3. Adding 5 stores 5 through 8 in $D103.
; $FF becomes 9.
;
; $70C3 is still INCBIN.

PickD096SlotPlus5::
    ld hl, $D096
    call $70C3
    cp $FF
    jr z, .none

    add $05
    jr .store

.none:
    ld a, $09

.store:
    ld [$D103], a
    ret
