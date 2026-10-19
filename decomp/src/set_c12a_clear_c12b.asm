; Bank 1 at $56C0. Plant59A8WhenCellIs01 and the sibling
; planters call this, then drop their own return address and plant
; a script pointer.
;
; $C12A is the first byte of the eight-byte pattern written by
; WriteC12APattern (00 FF …). This stores $FF there and $00 at $C12B,
; the second byte. The inverse at $56B7 is still INCBIN.

SetC12AAndClearC12B::
    xor a
    ld [$c12b], a
    cpl
    ld [$c12a], a
    ret
