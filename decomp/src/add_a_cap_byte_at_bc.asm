; AddACapByteAtBc. Bank 0 at $387E.
;
; HL is a base and BC is an offset. A is added to the byte at HL+BC.
; The unsigned sum is capped at E, then written back to that byte.
; A is the stored value. Carry from the add is discarded, so a wrapped
; sum is capped only when the low 8 bits are at least E.
;
; CapAStoreByteAtHl at $3880 is a second entry. HL already addresses the
; byte. A is capped at E and stored. There is no call. What the byte
; counts is still unknown.

AddACapByteAtBc::
    add hl, bc
    add [hl]

CapAStoreByteAtHl::
    cp e
    jr c, .store

    ld a, e

.store:
    ld [hl], a
    ret
