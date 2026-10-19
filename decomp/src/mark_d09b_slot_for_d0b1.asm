; Bank 5 at $5A24. WaitForCca7Choice enters here through JumpHL when
; [$D0B0] is $0A. Selects WRAM bank 7, clears the ten bytes at $D09B,
; writes $01 at $D09B indexed by [$D0B1], and returns with D = 8.
;
; wCurrentWRAMBank and rSVBK are the names from timer_overflow.asm.

MarkD09BSlotForD0B1::
    ld a, $07
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld hl, $D09B
    xor a
    ld b, $0A
.clearTen:
    ld [hl+], a
    dec b
    jr nz, .clearTen
    ld a, [$D0B1]
    ld c, a
    ld b, $00
    ld hl, $D09B
    add hl, bc
    ld a, $01
    ld [hl], a
    ld d, $08
    ret
