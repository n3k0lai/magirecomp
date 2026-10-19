; Bank 5 at $59B0. WaitForCca7Choice enters here through JumpHL when
; [$D0B0] is $0C or $0D. This bank stays mapped. The routine does not
; switch WRAM banks.
;
; $D09B is cleared. When [$D0B0] is $0C, $D09C-$D09F receive bit 0 of
; $D092-$D095 flipped, and $D0A0-$D0A4 are cleared. Otherwise $D09C-$D09F
; are cleared, $D0A0-$D0A3 receive bit 0 of $D096-$D099 flipped, and
; $D0A4 is cleared.
;
; DE is then saved. E is the caller's E. D is 2 in the $0C case and 5
; otherwise. Eight gates at $D085 down through $D07E are tested against
; the eight bytes at $D0A3 down through $D09C. Each nonzero gate replaces
; A with that paired byte, so the lowest such gate wins. A zero gate
; leaves A alone. A starts at 0, so it stays 0 when every gate is zero.
; The `xor a` under a nonzero gate is overwritten by the following load.
; DE is restored and the routine returns.

FillD09BStripForD0B0::
    ld bc, $D091
    ld hl, $D09B
    xor a
    ld [hl+], a
    inc bc
    ld a, [$D0B0]
    cp $0C
    jr z, .case0C
    xor a
    ld d, $04
.zeroBeforeFlip:
    ld [hl+], a
    inc bc
    dec d
    jr nz, .zeroBeforeFlip
    ld d, $04
.flipHigh:
    ld a, [bc]
    xor $01
    ld [hl+], a
    inc bc
    dec d
    jr nz, .flipHigh
    ld d, $05
    xor a
    jr .storeTail
.case0C:
    ld d, $04
.flipLow:
    ld a, [bc]
    xor $01
    ld [hl+], a
    inc bc
    dec d
    jr nz, .flipLow
    xor a
    ld d, $04
.zeroAfterFlip:
    ld [hl+], a
    inc bc
    dec d
    jr nz, .zeroAfterFlip
    ld d, $02
.storeTail:
    ld [hl], a
    push de
    ld de, $0008
    ld bc, $D085
.pickGated:
    ld hl, $D09B
    add hl, de
    ld a, [bc]
    and a
    jr z, .nextGate
    xor a
    ld a, [hl]
.nextGate:
    dec bc
    dec e
    jr nz, .pickGated
    pop de
    ret
