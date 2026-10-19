; Bank 5 at $42B9. StepD074RangesInBank7 copies [$D103] to $D0B0, then
; calls this in the same bank.
;
; WRAM bank 7 is stored in wCurrentWRAMBank and selected with rSVBK, so
; the $D000 accesses below are in that bank. Both names come from
; timer_overflow.asm.
;
; [$D0B6] below $05 sets [$D019] when [$D0B0] is $18, $19, $1C, or $1D.
; [$D0B6] at least $05 sets it when [$D0B0] is $15, $1C, or $1D.
; Any other value clears [$D019]. The caller reads that flag next.

FlagD019ForCopiedD0B0::
    ld a, $07
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld a, [$D0B6]
    cp $05
    jr nc, .highBand
    ld a, [$D0B0]
    cp $18
    jr z, .setFlag
    cp $19
    jr z, .setFlag
    cp $1C
    jr z, .setFlag
    cp $1D
    jr z, .setFlag
    jr .clearFlag
.highBand:
    ld a, [$D0B0]
    cp $15
    jr z, .setFlag
    cp $1C
    jr z, .setFlag
    cp $1D
    jr z, .setFlag
.clearFlag:
    xor a
    ld [$D019], a
    ret
.setFlag:
    ld a, $01
    ld [$D019], a
    ret
