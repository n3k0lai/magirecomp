; How many times a halved BC fits under DE after DE is shifted left four.
;
; wScaleCount starts at 0 and is returned in A. HL starts at 0. If E is
; nonzero and E >= C and D >= B, the count is set to $20 and that value
; is returned. DE == 0 returns 0. Otherwise BC shifts right once, DE shifts
; left four times, and HL takes that BC. While HL is still below DE, BC is
; added to HL and the count increments. The count is eight bits and wraps.
; A halved BC of zero never reaches the return.
;
; The one caller found is bank 2 at $7101. It passes two big-endian words
; and stores A.

DEF wScaleCount EQU $C930

ScaleCount::
    xor a
    ld h, a
    ld l, a
    ld [wScaleCount], a
    ld a, e
    and a
    jr z, .deLowZero
    cp c
    jr c, .halve
    ld a, d
    cp b
    jr c, .halve
    ld a, $20
    ld [wScaleCount], a
    ret

.deLowZero:
    cp d
    ret z

.halve:
    srl b
    rr c
    sla e
    rl d
    sla e
    rl d
    sla e
    rl d
    sla e
    rl d
    add hl, bc

.fit:
    ld a, h
    cp d
    jr nz, .compared
    ld a, l
    cp e

.compared:
    jr nc, .done
    add hl, bc
    ld a, [wScaleCount]
    inc a
    ld [wScaleCount], a
    jr .fit

.done:
    ld a, [wScaleCount]
    ret
