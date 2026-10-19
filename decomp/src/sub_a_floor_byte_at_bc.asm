; SubAFloorByteAtBc. Bank 0 at $3886.
;
; HL is a base and BC is an offset. A is subtracted from the byte at
; HL+BC. A zero result and an underflow are both stored as $01, so the
; byte never lands on zero. A is the stored value. There is no call.
; What the byte counts is still unknown.

SubAFloorByteAtBc::
    add hl, bc
    ld c, a
    ld a, [hl]
    sub c
    jr z, .floor

    jr nc, .store

.floor:
    ld a, $01

.store:
    ld [hl], a
    ret
