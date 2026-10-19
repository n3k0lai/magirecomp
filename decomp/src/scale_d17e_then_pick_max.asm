; Bank 2 at $7180. Index 10 of D0F0JumpWords. JumpHL calls this from
; $6BBA when bit 6 of $D0EE is clear.
;
; $7101 starts at $D17E + 7 and walks four records, stride $37. Each
; record supplies two big-endian words. ScaleCount's result is stored at
; $D3C4 as a word whose high byte is that count and whose low byte is 0.
; $7067 then keeps the greatest nonzero word and writes its slot, 1
; through 4, to $D103. All four zero leaves $D103 at 0.
;
; $7101 and $7067 are still INCBIN. ScaleCount is already source.

ScaleD17EThenPickMax::
    ld hl, $D17E
    call $7101
    call $7067
    ret

ScaleD17EThenPickMaxEnd:
