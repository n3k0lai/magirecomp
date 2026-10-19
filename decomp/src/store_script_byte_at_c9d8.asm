; Script helper at $19D3. Copies the next script byte at BC into
; wUnknownC9D8 and advances BC past it.
;
; wUnknownC9D8 is the name from indexed_tail_07.asm. What the stored
; byte selects is still unknown. Nothing here calls or jumps into an
; INCBIN.

StoreScriptByteAtC9D8::
    ld a, [bc]
    ld [wUnknownC9D8], a
    inc bc
    ret
