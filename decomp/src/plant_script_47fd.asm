; Bank 2 at $4540. FinishLowD103Refresh falls in here with A = $49,
; after the bank 5 call at $5575 on the path where both $D071 and $D073
; are zero.
;
; $49 $C9 is planted at $C93D, the same two bytes the other tails of that
; routine write. $C71B then receives $4C $FD $47 $66 $0A, the five-byte
; sequence those tails use with the address word changed to $47FD.
;
; Control joins $4593, the `ld hl, $5A1A` that the $D071 != 2 path also
; reaches. That tail is still INCBIN.

PlantScript47FD::
    ld [$C93D], a
    ld a, $C9
    ld [$C93E], a
    ld hl, $C71B
    ld a, $4C
    ld [hl+], a
    ld a, $FD
    ld [hl+], a
    ld a, $47
    ld [hl+], a
    ld a, $66
    ld [hl+], a
    ld a, $0A
    ld [hl+], a
    jr $4593
