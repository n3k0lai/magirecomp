; Script helper at $19B9. Copies the next two script bytes at BC onto
; wUnknownC9DA (low) and wUnknownC9DB (high), then advances BC past them.
;
; If bit 7 of the high byte is set, that word is replaced with the word
; at $C9E5 (low) and $C9E6 (high). Bit 7 clear returns with the script
; word left in place. $19C3 is the fall-through that tests A, which still
; holds the high byte.
;
; wUnknownC9DA and wUnknownC9DB are the names from
; dispatch_nonzero_d016.asm. $C9E5 and $C9E6 are still unnamed. Nothing
; here calls or jumps into an INCBIN.

CopyNextScriptWordOrC9E5::
    ld a, [bc]
    inc bc
    ld [wUnknownC9DA], a
    ld a, [bc]
    inc bc
    ld [wUnknownC9DB], a

.bit7::
    bit 7, a
    ret z

    ld a, [$C9E5]
    ld [wUnknownC9DA], a
    ld a, [$C9E6]
    ld [wUnknownC9DB], a
    ret
