; Bank 5 at $57FE. WaitForCca7Choice enters here through JumpHL when
; [$D0B0] is $14 through $1D. This bank stays mapped.
;
; WRAM bank 7 is stored in wCurrentWRAMBank and selected with rSVBK.
; Both names come from timer_overflow.asm.
;
; [$D09B] is 1 when [$D0B0] is $18, $19, $1C, or $1D, and 0 otherwise.
; $D09C-$D09F come from $D092-$D095, cleared when [$D0B0] is $14 or $15
; and copied otherwise. $D0A0-$D0A3 come from $D096-$D099, cleared when
; [$D0B0] is $16, $17, $18, or $19 and copied otherwise. The AND with D
; is the gate: D is $00 to clear a half and $FF to copy it. $D091 is
; skipped. The second half does not advance BC after its last store, so
; BC is left at $D099 and HL at $D0A4.
;
; [$D0A4] is 1 when [$D0B0] is $15, $1C, or $1D, and 0 otherwise. When
; [$D0B0] is $16, $18, $1A, or $1C, the byte at $D09B + [$D0B1] is
; cleared. Returns with D = 0. WaitForCca7Choice replaces any returned
; D other than 2, so this 0 is the caller's default.

MaskD092HalvesForD0B0::
    ld a, $07
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld bc, $D091
    ld hl, $D09B
    ld a, [$D0B0]
    cp $18
    jr z, .markD09B
    cp $19
    jr z, .markD09B
    cp $1C
    jr z, .markD09B
    cp $1D
    jr z, .markD09B
    xor a
    jr .storeD09B
.markD09B:
    ld a, $01
.storeD09B:
    ld [hl+], a
    inc bc
    ld d, $FF
    ld a, [$D0B0]
    cp $14
    jr z, .clearLowHalf
    cp $15
    jr z, .clearLowHalf
    jr .copyLowHalf
.clearLowHalf:
    ld d, $00
.copyLowHalf:
    ld a, [bc]
    and d
    ld [hl+], a
    inc bc
    ld a, [bc]
    and d
    ld [hl+], a
    inc bc
    ld a, [bc]
    and d
    ld [hl+], a
    inc bc
    ld a, [bc]
    and d
    ld [hl+], a
    inc bc
    ld d, $FF
    ld a, [$D0B0]
    cp $16
    jr z, .clearHighHalf
    cp $17
    jr z, .clearHighHalf
    cp $18
    jr z, .clearHighHalf
    cp $19
    jr z, .clearHighHalf
    jr .copyHighHalf
.clearHighHalf:
    ld d, $00
.copyHighHalf:
    ld a, [bc]
    and d
    ld [hl+], a
    inc bc
    ld a, [bc]
    and d
    ld [hl+], a
    inc bc
    ld a, [bc]
    and d
    ld [hl+], a
    inc bc
    ld a, [bc]
    and d
    ld [hl+], a
    ld a, [$D0B0]
    cp $15
    jr z, .markD0A4
    cp $1C
    jr z, .markD0A4
    cp $1D
    jr z, .markD0A4
    xor a
    jr .storeD0A4
.markD0A4:
    ld a, $01
.storeD0A4:
    ld [hl], a
    ld a, [$D0B0]
    cp $16
    jr z, .clearD09BIndex
    cp $18
    jr z, .clearD09BIndex
    cp $1A
    jr z, .clearD09BIndex
    cp $1C
    jr z, .clearD09BIndex
    jr .returnD
.clearD09BIndex:
    ld hl, $D09B
    ld a, [$D0B1]
    ld c, a
    ld b, $00
    add hl, bc
    ld [hl], b
.returnD:
    ld d, $00
    ret
