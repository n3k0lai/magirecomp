; Bank 2 at $71CC. Index 4 of D0F0JumpWords. JumpHL calls this from
; $6BBA when bit 6 of $D0EE is clear.
;
; $7101 starts at $D25A + 7 and walks four records, stride $37. Each
; record supplies two big-endian words. ScaleCount's result is stored at
; $D3C4 as a word whose high byte is that count and whose low byte is 0.
; $7067 then keeps the greatest nonzero word and writes its slot, 1
; through 4, to $D103. All four zero leaves $D103 at 0.
; $6FF9 adds 4 to a nonzero $D103, so the slot becomes 5 through 8, and
; turns 0 into 9.
;
; $7101, $7067, and $6FF9 are still INCBIN. ScaleCount is already source.

ScaleD25AThenPickMax::
    ld hl, $D25A
    call $7101
    call $7067
    call $6FF9
    ret
