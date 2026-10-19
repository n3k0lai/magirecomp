; Bank 5 at $41E7. StepD074RangesInBank7 stores $D074 (at least 5
; and still below 9) at $D018, then calls this in the same bank.
;
; WRAM bank 7 is stored in wCurrentWRAMBank and selected with rSVBK, so
; the $D000 accesses below are in that bank. Both names come from
; timer_overflow.asm.
;
; [$D091 + $D018] equal to zero clears [$D019].
;
; When [$D0B6] is at least $05, [$D0B0] of $17, $19, $1B, or $1D sets
; [$D019]. Ids $16, $18, $1A, and $1C set it only when [$D0B6] differs
; from [$D018]. Any other id clears it.
;
; When [$D0B6] is below $05, [$D0B0] of $14, $15, or at least $1A sets
; [$D019]. Any other id clears it.

FlagD019ForHighD018Slot::
    ld a, $07
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld a, [$D018]
    ld b, $00
    ld c, a
    ld hl, $D091
    add hl, bc
    ld a, [hl]
    cp $00
    jp z, .clearFlag
    ld a, [$D0B6]
    cp $05
    jr c, .lowBand
    ld a, [$D0B0]
    cp $17
    jr z, .setFlag
    cp $19
    jr z, .setFlag
    cp $1B
    jr z, .setFlag
    cp $1D
    jr z, .setFlag
    cp $16
    jr nz, .check18
    ld a, [$D018]
    ld b, a
    ld a, [$D0B6]
    cp b
    jr nz, .setFlag
.check18:
    ld a, [$D0B0]
    cp $18
    jr nz, .check1A
    ld a, [$D018]
    ld b, a
    ld a, [$D0B6]
    cp b
    jr nz, .setFlag
.check1A:
    ld a, [$D0B0]
    cp $1A
    jr nz, .check1C
    ld a, [$D018]
    ld b, a
    ld a, [$D0B6]
    cp b
    jr nz, .setFlag
.check1C:
    ld a, [$D0B0]
    cp $1C
    jr nz, .clearFlag
    ld a, [$D018]
    ld b, a
    ld a, [$D0B6]
    cp b
    jr nz, .setFlag
    jr .clearFlag
.lowBand:
    ld a, [$D0B0]
    cp $14
    jr z, .setFlag
    cp $15
    jr z, .setFlag
    cp $1A
    jr nc, .setFlag
.clearFlag:
    xor a
    ld [$D019], a
    ret
.setFlag:
    ld a, $01
    ld [$D019], a
    ret
