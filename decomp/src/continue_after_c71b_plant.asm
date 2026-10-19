; Bank 2 at $4593. PlantScript47FD joins here after planting
; $4C $FD $47 $66 $0A at $C71B. The path at $458C also falls in when
; [$D071] is not 2. That earlier test is still INCBIN.
;
; Bank 5 at $5A1A runs through CallBankedHL. A nonzero [$D016] skips the
; two setups that follow. Otherwise [$D338] is copied to $D0C2 with
; $D0C0 = 0 and $D0C1 = $0C, bank 5 at $57BA runs, then $D0C2 = $58,
; $D0C0 = 0, $D0C1 = $0B, and $57BA runs again.
;
; A zero [$D0B2] returns. Otherwise StoreIndexedSlotRecord runs with
; D = $41 and BC = $6F5E for slot [$D103]. That index minus one is stored
; at $C9D9 with $F0 at $C9D8, bank 4 at $61EB runs, and FinishFrame repeats
; until [$C722] is nonzero, then once more. $D076 is cleared. A zero
; [$D0D2] returns. Otherwise that byte is copied to $D073, bank 5 at $5575
; runs, $49 $C9 is planted at $C93D, $4C $84 $48 $66 $0A is planted at
; $C71B, and bank 5 at $5A1A runs again.
;
; CallBankedHL, StoreIndexedSlotRecord, and FinishFrame are already source.
; Bank 5's $5A1A, $57BA, and $5575 are already listed. Bank 4's $61EB is
; still INCBIN.

ContinueAfterC71BPlant::
    ld hl, $5A1A
    ld e, $05
    call CallBankedHL
    ld a, [$D016]
    and a
    jr nz, .afterD016Setups
    ld a, [$D338]
    ld [$D0C2], a
    ld a, $00
    ld [$D0C0], a
    ld a, $0C
    ld [$D0C1], a
    ld hl, $57BA
    ld e, $05
    call CallBankedHL
    ld a, $58
    ld [$D0C2], a
    ld a, $00
    ld [$D0C0], a
    ld a, $0B
    ld [$D0C1], a
    ld hl, $57BA
    ld e, $05
    call CallBankedHL
.afterD016Setups:
    ld a, [$D0B2]
    and a
    ret z
    ld a, [$D103]
    ld d, $41
    ld bc, $6F5E
    call StoreIndexedSlotRecord
    ld a, [$D103]
    dec a
    ld b, a
    ld a, $F0
    ld [$C9D8], a
    ld a, b
    ld [$C9D9], a
    ld hl, $61EB
    ld e, $04
    call CallBankedHL
    xor a
    ld [$C722], a
.waitC722:
    call FinishFrame
    ld a, [$C722]
    and a
    jr z, .waitC722
    call FinishFrame
    xor a
    ld [$D076], a
    ld a, [$D0D2]
    and a
    ret z
    ld [$D073], a
    ld hl, $5575
    ld e, $05
    call CallBankedHL
    ld a, $49
    ld [$C93D], a
    ld a, $C9
    ld [$C93E], a
    ld hl, $C71B
    ld a, $4C
    ld [hl+], a
    ld a, $84
    ld [hl+], a
    ld a, $48
    ld [hl+], a
    ld a, $66
    ld [hl+], a
    ld a, $0A
    ld [hl+], a
    ld hl, $5A1A
    ld e, $05
    call CallBankedHL
    ret
