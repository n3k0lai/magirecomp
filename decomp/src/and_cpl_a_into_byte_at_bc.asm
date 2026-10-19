; AndCplAIntoByteAtBc. Bank 0 at $38C2.
;
; HL is a base and BC is an offset. A is complemented, then ANDed into
; the byte at HL+BC, which clears every bit that was set in A. A is the
; stored value. There is no call.
;
; AndAIntoHl at $38C4 skips the add and the complement: A is already the
; mask and HL already points at the byte. StoreAAtHl at $38C5 only
; writes A.
;
; One caller loads A from B, HL from $D110, and BC from $0015, so the
; clear lands on the byte at $D125. What the bits mean is still unknown.

AndCplAIntoByteAtBc::
    add hl, bc
    cpl

AndAIntoHl::
    and [hl]

StoreAAtHl::
    ld [hl], a
    ret
