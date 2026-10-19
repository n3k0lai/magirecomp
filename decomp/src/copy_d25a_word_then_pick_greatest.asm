; Bank 2 at $71A5. Index 7 of D0F0JumpWords. JumpHL calls this from
; $6BBA when bit 6 of $D0EE is clear.
;
; $712F starts at $D25A + 7 and walks four records. It copies the two
; bytes there into $D3C4, then adds $35, so the stride is $37. Unlike
; $7101 it does not scale a second word.
; $700B then keeps the greatest nonzero word and writes its slot, 1
; through 4, to $D103. A tie keeps the earlier slot. All four zero
; leaves $D103 at 0.
; $6FF9 adds 4 to a nonzero $D103, so the slot becomes 5 through 8, and
; turns 0 into 9.
;
; $712F, $700B, and $6FF9 are still INCBIN.

CopyD25AWordThenPickGreatest::
    ld hl, $D25A
    call $712F
    call $700B
    call $6FF9
    ret
