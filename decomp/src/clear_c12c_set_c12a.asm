; Bank 1 at $4ECB. ResumeHead01Record calls this, then reads the
; pressed-button copy at $C9A4. The sibling at $4EC2 is the inverse:
; it clears $C12A and stores $FF at $C12C.
;
; $C12A is the first byte of the eight-byte pattern written by
; WriteC12APattern (00 FF FF 00 …). $C12C is the third byte. This
; stores $00 there and $FF at $C12A.

ClearC12CAndSetC12A::
    xor a
    ld [$c12c], a
    cpl
    ld [$c12a], a
    ret
