; Bank 2 at $716C. Index 11 of D0F0JumpWords. JumpHL calls this from
; $6BBA when bit 6 of $D0EE is clear.
;
; $7101 starts at $D17E + 7 and walks four records, stride $37. Each
; record supplies two big-endian words. ScaleCount's result is stored at
; $D3C4 as a word whose high byte is that count and whose low byte is 0.
; $700B then keeps the greatest nonzero word and writes its slot, 1
; through 4, to $D103. A tie keeps the earlier slot. All four zero
; leaves $D103 at 0.
;
; $7101 and $700B are still INCBIN. ScaleCount is already source.

ScaleD17EThenPickGreatest::
    ld hl, $D17E
    call $7101
    call $700B
    ret
