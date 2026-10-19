; Bank 1 at $56B7. ResumeUpIdleRecord and the down, left, and
; right record heads call this when the cell at HL is zero, then
; plant a script pointer and jump to PlantHandlerAndHeadWord.
;
; $C12A is the first byte of the eight-byte pattern written by
; WriteC12APattern (00 FF …). This stores $00 there and $FF at $C12B,
; the second byte. SetC12AAndClearC12B at $56C0 is the inverse.

ClearC12AAndSetC12B::
    xor a
    ld [$c12a], a
    cpl
    ld [$c12b], a
    ret
