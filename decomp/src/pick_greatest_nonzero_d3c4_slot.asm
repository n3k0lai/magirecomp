; Bank 2 at $700B. The four callers at $7162, $716C, $71A5, and $71B2
; fill four big-endian words at $D3C4, then call here.
;
; $D074 counts the four words down from 4. The first nonzero word is the
; champion. Its slot is 5 minus the count still left, so the first word
; is slot 1 and the fourth is slot 4. That slot is held in $D3CC.
;
; Each later nonzero word is subtracted from the champion by adding its
; two's complement. Carry means the champion is greater or equal, and
; that champion stays. No carry means the later word is greater, so it
; becomes the champion and its slot replaces $D3CC. A tie keeps the
; lower slot. A zero word is skipped. The surviving slot is written to
; $D103. All four words zero stores 0.

PickGreatestNonzeroD3C4Slot::
    ld de, $D3C4
    ld a, $04
    ld [$D074], a

.scan:
    ld a, [de]
    inc de
    ld h, a
    ld a, [de]
    inc de
    ld l, a
    or h
    jr nz, .found

    ld a, [$D074]
    dec a
    ld [$D074], a
    jr nz, .scan

    jr .none

.found:
    ld a, [$D074]
    ld b, a
    ld a, $05
    sub b
    ld [$D3CC], a

.next:
    ld a, [$D074]
    dec a
    ld [$D074], a
    jr z, .store

    ld a, [de]
    inc de
    ld b, a
    ld a, [de]
    inc de
    ld c, a
    or b
    jr z, .next

    ld a, c
    cpl
    ld c, a
    ld a, b
    cpl
    ld b, a
    inc bc
    push hl
    add hl, bc
    pop hl
    jr c, .next

    ld a, c
    cpl
    ld c, a
    ld a, b
    cpl
    ld b, a
    inc bc
    ld h, b
    ld l, c
    jr .found

.none:
    ld a, $00
    ld [$D103], a
    ret

.store:
    ld a, [$D3CC]
    ld [$D103], a
    ret
