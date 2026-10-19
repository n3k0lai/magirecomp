; Bank 2 at $72E2. Indexes 1 and 2 of D0F0JumpWords. JumpHL calls this
; from $6BBA when bit 6 of $D0EE is clear.
;
; WRAM bank 7 is stored in wCurrentWRAMBank and selected with rSVBK.
; Both names are from timer_overflow.asm. $CCA7 is cleared, so
; LoadSelectedRecordToD100 takes its $CCA7 = 0 path and copies the
; record chosen from [$D0B1]. That call is bank 5 through CallBankedHL.
; Both routines are already source.
;
; [$D103] is then set to $09. The jr lands on the ret.

LoadZeroSelectionMarkD103Nine::
    ld a, $07
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    xor a
    ld [$CCA7], a
    ld hl, LoadSelectedRecordToD100
    ld e, $05
    call CallBankedHL
    ld a, $09
    ld [$D103], a
    jr .return
.return:
    ret
