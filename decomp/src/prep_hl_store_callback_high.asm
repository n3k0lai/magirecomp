; Bank 0 at $397E. No absolute call or jump to this address is in the ROM.
; What reaches it, and what the pointer in HL is for, are still unknown.
;
; B keeps the incoming H. H and L are both set to the incoming L, so the
; first [HL] read uses that doubled address and is then thrown away: the
; next instruction writes L back into H. The second [HL] read keeps that
; byte in L, with H still the incoming L. `ld h, h` does not change H.
; `inc c` / `dec c` leaves C as it was and sets the flags from that value.
; `add hl, hl` doubles the rebuilt pointer. A is not modified. It is stored
; at wCallback+1, the high byte of the callback pointer from
; default_state.asm. Then the routine returns.

PrepHlStoreCallbackHigh::
    ld b, h
    ld h, l
    ld h, [hl]
    ld h, l
    ld l, [hl]
    ld h, h
    inc c
    dec c
    add hl, hl
    ld [wCallback + 1], a
    ret
