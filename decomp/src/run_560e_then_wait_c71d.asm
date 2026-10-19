; Bank 2 at $477E. Callers plant a five-byte script record at $C71B and
; then call here.
;
; CallBankedHL runs bank 5 at $560E. $C93D and $C93E are then written as
; $49 $C9, so that word points at $C949. CallBankedHL runs
; WaitUntilC71DClears, which returns when the high byte of the pointer in
; the $C71B record is zero.
;
; Bank 5 at $560E is still INCBIN. Its file address is $01560E.
; CallBankedHL and WaitUntilC71DClears are already source.

Run560EThenWaitC71D::
    ld hl, $560E
    ld e, $05
    call CallBankedHL
    ld a, LOW($C949)
    ld [$C93D], a
    ld a, HIGH($C949)
    ld [$C93E], a
    ld hl, WaitUntilC71DClears
    ld e, $05
    call CallBankedHL
    ret
