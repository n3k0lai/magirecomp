; Taken from RetargetSramSlotCount when the latch in $CCA1 is already zero.
;
; SRAM is enabled on bank [$C727]. The byte at $A118 plus $CC4C is
; multiplied by $25 (MulCByB). That index, plus $CCA0, selects a byte
; in the next SRAM bank at $A022. A zero byte only turns SRAM off.
; A nonzero byte is cleared, stored in $CCA1, and used to increment
; the count at $A019 plus that byte on bank [$C727]. $CC4B is set to 1,
; SRAM is disabled, and this returns.
; rRAMG is the name from reset.asm. [$C727] is the SRAM bank. `add a, $00`
; is how this bank copies that bank number.

TakeSramSlotIntoLatch::
    ld a, $0a
    ld [rRAMG], a
    ld a, [$c727]
    add a, $00
    ld [$4000], a
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
    ld a, [hl]
    and a
    jr z, .sramOff
    ld [hl], $00
    ld [$cca1], a
    ld c, a
    ld b, $00
    ld hl, $a019
    add hl, bc
    ld a, [$c727]
    add a, $00
    ld [$4000], a
    inc [hl]
    ld a, $01
    ld [$cc4b], a

.sramOff:
    xor a
    ld [rRAMG], a
    ret
