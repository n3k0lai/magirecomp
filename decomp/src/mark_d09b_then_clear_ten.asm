; Bank 5 at $58A6. WaitForCca7Choice enters here through JumpHL when
; [$D0B0] is $0F. This bank stays mapped.
;
; Selects WRAM bank 7, writes $01 at $D09B, then clears the next ten
; bytes, $D09C through $D0A5. Returns with D = 3.
;
; wCurrentWRAMBank and rSVBK are the names from timer_overflow.asm.
; WaitForCca7Choice replaces any returned D other than 2, so this 3 is
; the caller's default.

MarkD09BThenClearTen::
    ld a, $07
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld hl, $D09B
    ld a, $01
    ld [hl+], a
    xor a
    ld b, $0A
.clearTen:
    ld [hl+], a
    dec b
    jr nz, .clearTen
    ld d, $03
    ret
