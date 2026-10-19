; Bank 2 at $71BF. Index 6 of D0F0JumpWords. JumpHL calls this from
; $6BBA when bit 6 of $D0EE is clear.
;
; $712F starts at $D25A + 7 and walks four records, stride $37. Each
; record's first word is copied raw into $D3C4. Unlike $7101, the pair
; is not passed through ScaleCount.
; $7067 then keeps the greatest nonzero word and writes its slot, 1
; through 4, to $D103. All four zero leaves $D103 at 0.
; $6FF9 adds 4 to a nonzero $D103, so the slot becomes 5 through 8, and
; turns 0 into 9.
;
; $712F, $7067, and $6FF9 are still INCBIN.

CopyD25AWordThenPickMax::
    ld hl, $D25A
    call $712F
    call $7067
    call $6FF9
    ret
