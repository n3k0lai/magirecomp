; CopyThirtyTwoWordPairsAtIndex00. Bank 0 at $35E0.
;
; $C831 is cleared. CopyWordPairs doubles E and adds it to HL, then
; copies A words from BC. Here E is $00 and A is $20, so thirty-two
; word pairs land at the caller's HL. HL and BC are left as the caller
; set them. $C831 is set to $01 before the return.
;
; $C831 is still unnamed. CopyWordPairs is the name from
; copy_word_pairs.asm.

CopyThirtyTwoWordPairsAtIndex00::
    xor a
    ld [$C831], a
    ld e, $00
    ld a, $20
    call CopyWordPairs
    ld a, $01
    ld [$C831], a
    ret
