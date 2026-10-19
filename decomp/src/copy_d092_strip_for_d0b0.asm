; Bank 5 at $58BD. WaitForCca7Choice enters here through JumpHL when
; [$D0B0] is $0E, $12, or $13.
;
; WRAM bank 7 is stored in wCurrentWRAMBank and selected with rSVBK.
; Both names come from timer_overflow.asm.
;
; [$D09B] is 0 when [$D0B0] is $0E, and 1 for $12 and $13. The next eight
; bytes, $D09C through $D0A3, are copied from $D092 through $D099. $D091
; is not copied. BC is left at $D09A.
;
; [$D0A4] is 0 when [$D09A] is 0. It is 1 when [$D0B0] is $13 and [$D09A]
; is nonzero. For $0E and $12, the four bytes at $D096 are scanned: any
; nonzero byte stores 0 at $D0A4, and four zeros store 1. The `xor a`
; before that scan is overwritten by the first load.
;
; Returns with D = 5. WaitForCca7Choice replaces any returned D other
; than 2, so this 5 is the caller's default.

CopyD092StripForD0B0::
    ld a, $07
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld bc, $D091
    ld hl, $D09B
    ld a, [$D0B0]
    cp $0E
    jr z, .zeroD09B
    ld a, $01
    jr .storeD09B
.zeroD09B:
    xor a
.storeD09B:
    ld [hl+], a
    inc bc
    ld d, $08
.copyEight:
    ld a, [bc]
    ld [hl+], a
    inc bc
    dec d
    jr nz, .copyEight
    ld a, [$D09A]
    cp $00
    jr z, .clearD0A4
    ld a, [$D0B0]
    cp $13
    jr z, .setD0A4
    ld hl, $D096
    ld d, $04
    xor a
.scanD096:
    ld a, [hl+]
    and a
    jr nz, .clearD0A4
    dec d
    jr nz, .scanD096
.setD0A4:
    ld a, $01
    ld [$D0A4], a
    jr .returnD
.clearD0A4:
    xor a
    ld [$D0A4], a
.returnD:
    ld d, $05
    ret
