; Index 21 of the word table at $1234.
;
; Zero-extends the low nibble of rDIV ($FF04) into DE. The read is the
; 3-byte form. LookupWordAt1234 enters this with jp hl, so ret returns
; to its caller. B, C, H, and L are left alone.

LookupIndex21::
    ld a, [rDIV]
    and $0F
    ld e, a
    ld d, 0
    ret
