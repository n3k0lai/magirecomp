; Bank 5 at $405C. LoadD107EntryThenScript4AE0 calls this first.
;
; [$D103] is a 1-based slot. Shift $01 left by that index minus one and
; OR the bit into [$D075]. Then store $01 at $D091 plus the same index.
; The bank is left mapped. The next byte is a separate routine.

MarkD075BitAndD091::
    ld a, [$D103]
    ld b, $01
.shift:
    dec a
    jr z, .store
    sla b
    jr .shift
.store:
    ld hl, $D075
    ld a, b
    or [hl]
    ld [hl], a
    ld a, [$D103]
    ld c, a
    ld b, $00
    ld hl, $D091
    add hl, bc
    ld a, $01
    ld [hl], a
    ret

MarkD075BitAndD091End:
