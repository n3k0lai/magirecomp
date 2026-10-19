; Bank 2 at $7176. Index 12 of D0F0JumpWords. JumpHL calls this from
; $6BBA when bit 6 of $D0EE is clear.
;
; $712F starts at $D17E + 7 and walks four records, stride $37. Each
; record's first word is copied raw into $D3C4. Unlike $7101, the pair
; is not passed through ScaleCount.
; $7067 then keeps the greatest nonzero word and writes its slot, 1
; through 4, to $D103. All four zero leaves $D103 at 0.
;
; $712F and $7067 are still INCBIN.

CopyD17EWordThenPickMax::
    ld hl, $D17E
    call $712F
    call $7067
    ret
