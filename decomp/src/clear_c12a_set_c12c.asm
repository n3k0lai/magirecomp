; Bank 1 at $4EC2. ResumeHead01Record calls this when the map cell
; one column left is $00. The sibling at $4ECB is the inverse: it
; clears $C12C and stores $FF at $C12A.
;
; $C12A is the first byte of the eight-byte pattern written by
; WriteC12APattern (00 FF FF 00 …). $C12C is the third byte. This
; stores $00 at $C12A and $FF at $C12C.

ClearC12AAndSetC12C::
    xor a
    ld [$c12a], a
    cpl
    ld [$c12c], a
    ret
