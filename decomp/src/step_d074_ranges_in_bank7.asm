; Bank 5 at $407C. ClearMarksAndWalkSlots calls this through CallBankedHL.
;
; WRAM bank 7 is stored in wCurrentWRAMBank and selected with rSVBK, so
; the $D000 accesses below are in that bank. Both names come from
; timer_overflow.asm.
;
; [$D103] is copied to $D0B0, then $42B9 runs in this bank. A nonzero
; [$D019] clears $D103 and calls RefreshSlotForLowD103 in bank 2.
;
; $D074 is cleared, then incremented. While it stays below 5, that value
; is stored at $D018 and $4159 runs. Zero at $D019 repeats the increment.
; A nonzero value copies $D074 to $D103, calls RefreshSlotForLowD103, and
; repeats.
;
; When the count reaches 5, $D074 is set to 4 and the same shape runs
; until 9, calling $41E7 instead of $4159.
;
; At 9, $4275 runs. Zero at $D019 returns. Otherwise $D103 is set to 9,
; RefreshSlotForLowD103 runs, and this returns.
;
; CallBankedHL and RefreshSlotForLowD103 are already source.
; $42B9, $4159, $41E7, and $4275 are still INCBIN.

StepD074RangesInBank7::
    ld a, $07
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld a, [$D103]
    ld [$D0B0], a
    call $42B9
    ld a, [$D019]
    and a
    jr z, .clearCount
    xor a
    ld [$D103], a
    ld hl, RefreshSlotForLowD103
    ld e, $02
    call CallBankedHL
.clearCount:
    xor a
    ld [$D074], a
.lowRange:
    ld hl, $D074
    inc [hl]
    ld a, $05
    cp [hl]
    jr z, .setMid
    ld a, [hl]
    ld [$D018], a
    call $4159
    ld a, [$D019]
    and a
    jr z, .lowRange
    ld a, [$D074]
    ld [$D103], a
    ld hl, RefreshSlotForLowD103
    ld e, $02
    call CallBankedHL
    jr .lowRange
.setMid:
    ld a, $04
    ld [$D074], a
.highRange:
    ld hl, $D074
    inc [hl]
    ld a, $09
    cp [hl]
    jr z, .atNine
    ld a, [hl]
    ld [$D018], a
    call $41E7
    ld a, [$D019]
    and a
    jr z, .highRange
    ld a, [$D074]
    ld [$D103], a
    ld hl, RefreshSlotForLowD103
    ld e, $02
    call CallBankedHL
    jr .highRange
.atNine:
    call $4275
    ld a, [$D019]
    and a
    ret z
    ld a, $09
    ld [$D103], a
    ld hl, RefreshSlotForLowD103
    ld e, $02
    call CallBankedHL
    ret
