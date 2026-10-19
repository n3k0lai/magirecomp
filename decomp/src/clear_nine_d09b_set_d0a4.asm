; Bank 5 at $5A03. WaitForCca7Choice enters here through JumpHL when
; [$D0B0] is $10 or $11. Selects WRAM bank 7, clears the nine bytes at
; $D09B through $D0A3, writes $01 at $D0A4, and returns with D = 3.
;
; wCurrentWRAMBank and rSVBK are the names from timer_overflow.asm.

ClearNineD09BSetD0A4::
    ld a, $07
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld hl, $D09B
    xor a
    ld b, $09
.clearNine:
    ld [hl+], a
    dec b
    jr nz, .clearNine
    ld a, $01
    ld [hl+], a
    ld d, $03
    ret
