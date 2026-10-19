; Bank 2 at $455C. FinishLowD103Refresh jumps here when [$D071] is zero
; and [$D073] is nonzero.
;
; Bank 5 at $5575 runs through CallBankedHL. A nonzero [$D016] joins
; ContinueAfterC71BPlant at $459B, past the $5A1A call. Otherwise
; StoreIndexedSlotRecord runs with D = $41 and BC = $7058 for slot
; [$D103], bank 5 at $4430 runs, $C722 is cleared, and FinishFrame repeats
; until [$C722] is nonzero. Control then joins $459B.
;
; CallBankedHL, StoreIndexedSlotRecord, and FinishFrame are already source.
; Bank 5 at $5575 is already listed. Bank 5 at $4430 is still INCBIN.
; The $458C test of [$D071] against 2 is the next entry and stays INCBIN.

FinishD073Slot7058::
    ld hl, $5575
    ld e, $05
    call CallBankedHL
    ld a, [$D016]
    and a
    jr nz, $459B
    ld a, [$D103]
    ld d, $41
    ld bc, $7058
    call StoreIndexedSlotRecord
    ld hl, $4430
    ld e, $05
    call CallBankedHL
    xor a
    ld [$C722], a
.waitC722:
    call FinishFrame
    ld a, [$C722]
    and a
    jr z, .waitC722
    jr $459B
