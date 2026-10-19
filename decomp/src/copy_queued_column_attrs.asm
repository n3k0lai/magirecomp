; Attribute half of the queued map column. CopyQueuedColumn jumps here when
; the countdown at $C891 is neither 0 nor 2, with ROM bank 7 still mapped.
; A is that countdown and is saved at $C892.
;
; $C893 is the metatile sub-column already chosen by the tile pass (0 or 1).
; $C894 bit 3 still means the screen starts halfway through the first
; metatile, so that metatile's top attribute byte is left out.
;
; WRAM bank 2 holds the attribute definitions at $D400. Each queued id in
; $C895-$C89E becomes $D400 + id * 4 + sub-column. The two bytes of that
; column are the top and bottom tile attributes; the other column is
; skipped. They are written at $C116, over the buffer the tile pass used.
; D stays 0 and is the high byte carried through id * 4.
;
; The first id uses sla a / adc $D4. The other nine use sla l / rla / add $D4.
; Those sequences assemble to different bytes and both yield the same address
; while D is 0. wCurrentWRAMBank and rSVBK are the names from timer_overflow.asm.

CopyQueuedColumnAttrs::
    ld [$c892], a
    ld d, $00
    ld a, [$c893]
    ld e, a
    ld a, $02
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld bc, $c116
    ld a, [$c895]
    ld l, a
    xor a
    sla l
    adc d
    sla a
    sla l
    adc $d4
    ld h, a
    ld a, l
    add e
    ld l, a
    ld a, [$c894]
    bit 3, a
    jr nz, .skip_top

    ld a, [hl]
    ld [bc], a
    inc bc

.skip_top:
    inc hl
    inc hl
    ld a, [hl]
    ld [bc], a
    inc bc

FOR metatile, $C896, $C89F
    ld a, [metatile]
    ld l, a
    xor a
    sla l
    adc d
    sla l
    rla
    add $d4
    ld h, a
    ld a, l
    add e
    ld l, a
    ld a, [hl+]
    ld [bc], a
    inc bc
    inc hl
    ld a, [hl]
    ld [bc], a
    inc bc
ENDR

    ret
