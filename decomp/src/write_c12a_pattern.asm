; Bank 5's copy of the pattern writer that SetupDefaultState calls.
; $0832 maps the bank in A first, so another bank can supply its own $6C08.
;
; Stores 00 FF FF 00 FF FF FF FF at $C12A. xor a / cpl flips between those
; two values: one zero, two $FF, one zero, then four $FF. Nothing else is
; changed.

WriteC12APatternBank5::
    ld hl, $c12a
    xor a
    ld [hl+], a
    cpl
    ld [hl+], a
    ld [hl+], a
    cpl
    ld [hl+], a
    cpl
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ret
