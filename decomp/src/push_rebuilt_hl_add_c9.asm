; Bank 0 at $398B. What reaches this byte, and what the pointer is for,
; are still unknown. The 266 nops that follow are padding up to MapRomBank
; at $3AB0. Nothing here returns or jumps.
;
; Each eight-byte block matches the start of PrepHlStoreCallbackHigh and
; stops before `add hl, hl`. B keeps the incoming H. H and L are both set
; to the incoming L, so the first [HL] read uses that doubled address and
; is then thrown away: the next instruction writes L back into H. The
; second [HL] read keeps that byte in L, with H still the incoming L.
; `ld h, h` does not change H. `inc c` / `dec c` leaves C as it was and
; sets the flags from that value.
;
; The block runs twice, so the second pass rebuilds HL from the first
; result. `push hl` saves that pointer. `add a, $C9` changes only A.
; The block then runs a third time on the pointer that was just pushed,
; so HL is rebuilt again and the saved value stays on the stack.

PushRebuiltHlAddC9::
    ld b, h
    ld h, l
    ld h, [hl]
    ld h, l
    ld l, [hl]
    ld h, h
    inc c
    dec c
    ld b, h
    ld h, l
    ld h, [hl]
    ld h, l
    ld l, [hl]
    ld h, h
    inc c
    dec c
    push hl
    add a, $c9
    ld b, h
    ld h, l
    ld h, [hl]
    ld h, l
    ld l, [hl]
    ld h, h
    inc c
    dec c
REPT 266
    nop
ENDR
