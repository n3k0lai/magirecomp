; Callback planted at $CCB2 by the start-press setup.
;
; $CD81 must be $1C or $1D. Anything else returns. The difference from
; $1C (0 or 1) is stored in $CCA0. A zero latch in $CCA1 jumps to $436B,
; which is still INCBIN. Otherwise SRAM is enabled on bank [$C727].
; The count at $A019 plus the latch is decremented. The byte at
; $A118 plus $CC4C is multiplied by $25 (MulCByB). That index, plus
; $CCA0, selects a byte in the next SRAM bank at $A022. The old byte
; is kept and the latch is written there. Back on bank [$C727], a
; nonzero old byte increments the count at $A019 plus that byte.
; SRAM is disabled, $CCA1 is cleared, $CC4B is set to 1, and this returns.
; rRAMG is the name from reset.asm. [$C727] is the SRAM bank. `add a, $00`
; is how this bank copies that bank number.

RetargetSramSlotCount::
    ld a, [$cd81]
    cp $1c
    jr z, .slotOk
    cp $1d
    ret nz

.slotOk:
    sub $1c
    ld [$cca0], a
    ld a, [$cca1]
    and a
    jr z, $436b
    ld c, a
    ld b, $00
    ld hl, $a019
    add hl, bc
    ld a, $0a
    ld [rRAMG], a
    ld a, [$c727]
    add a, $00
    ld [$4000], a
    dec [hl]
    ld a, [$cc4c]
    ld c, a
    ld b, $00
    ld hl, $a118
    add hl, bc
    ld a, [hl]
    ld c, a
    ld b, $25
    call MulCByB
    ld bc, $a022
    add hl, bc
    ld a, [$cca0]
    ld c, a
    ld b, $00
    add hl, bc
    ld a, [$c727]
    add a, $01
    ld [$4000], a
    ld c, [hl]
    ld a, [$cca1]
    ld [hl], a
    ld a, [$c727]
    add a, $00
    ld [$4000], a
    xor a
    cp c
    jr z, .sramOff
    ld b, $00
    ld hl, $a019
    add hl, bc
    inc [hl]

.sramOff:
    xor a
    ld [rRAMG], a
    xor a
    ld [$cca1], a
    ld a, $01
    ld [$cc4b], a
    ret
