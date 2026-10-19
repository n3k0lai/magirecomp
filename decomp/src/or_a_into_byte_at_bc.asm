; OrAIntoByteAtBc. Bank 0 at $38BE.
;
; HL is a base and BC is an offset. A is ORed into the byte at HL+BC
; and the result is written back. A is the stored value. There is no
; call. What the bits mean is still unknown.
;
; One caller loads A from [$CD93], HL from $D110, and BC from $0015,
; so the OR lands on the byte at $D125.

OrAIntoByteAtBc::
    add hl, bc
    or [hl]
    ld [hl], a
    ret
