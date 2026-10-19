; Bank 2 at $71DE. Index 16 of D0F0JumpWords. JumpHL calls this from
; $7607 when [$D103] is below $14 and [$D395] is $18. That byte is the
; offset from $6FDF (index 4 of the same table) to this word.
;
; ORs the four bytes at $D092 through $D095. dec in the loop clears Z,
; so and a tests the OR. All zero jumps to ClearD103, which stores 0 in
; $D103. Any nonzero byte jumps to PickD092SlotPlus1.

OrFourD092ThenBranch::
    ld hl, $D092
    ld a, [hl+]
    ld d, $03
.orNext:
    or [hl]
    inc hl
    dec d
    jr nz, .orNext
    and a
    jr z, ClearD103
    jp PickD092SlotPlus1
