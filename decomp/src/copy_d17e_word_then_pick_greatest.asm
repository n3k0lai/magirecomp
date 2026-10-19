; Bank 2 at $7162. Index 13 of D0F0JumpWords. JumpHL calls this from
; $6BBA when bit 6 of $D0EE is clear.
;
; $712F starts at $D17E + 7 and walks four records. It copies the two
; bytes there into $D3C4, then adds $35, so the stride is $37. Unlike
; $7101 it does not scale a second word.
; $700B then keeps the greatest nonzero word and writes its slot, 1
; through 4, to $D103. A tie keeps the earlier slot. All four zero
; leaves $D103 at 0.
;
; $712F and $700B are still INCBIN.

CopyD17EWordThenPickGreatest::
    ld hl, $D17E
    call $712F
    call $700B
    ret
