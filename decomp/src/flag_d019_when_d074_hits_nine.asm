; Bank 5 at $4275. StepD074RangesInBank7 calls this when $D074 reaches 9.
;
; WRAM bank 7 is stored in wCurrentWRAMBank and selected with rSVBK, so
; the $D000 accesses below are in that bank. Both names come from
; timer_overflow.asm.
;
; [$D09A] equal to zero clears [$D019].
;
; When [$D0B6] is at least $05, [$D0B0] of $18, $19, $1C, or $1D sets
; [$D019]. Any other id clears it.
;
; When [$D0B6] is below $05, [$D0B0] of $15, $1C, or $1D sets [$D019].
; Any other id clears it. The caller reads that flag next.

FlagD019WhenD074HitsNine::
    ld a, $07
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld a, [$D09A]
    cp $00
    jr z, .clearFlag
    ld a, [$D0B6]
    cp $05
    jr c, .lowBand
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
.lowBand:
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
