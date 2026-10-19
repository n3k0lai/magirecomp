; RunFlaggedMeasureScript. Bank 2 at $58FF.
;
; SpendMeasureHundred calls this after $5657. Unless bit 1 of $D389 is set,
; this returns. Otherwise $56C7, $56E8, $570A, $5734, $5756, $5778, $579A,
; and $57BC run in that order.
;
; Bit 7 of $D389 picks the five-byte script at $C71B. Clear writes
; $4C $84 $46 $66 $0A. Set clears that bit, calls $57DE, and writes
; $4C $FC $46 $66 $0A. Both paths store $49 $C9 at $C93D so that word
; points at $C949, then CallBankedHL runs bank 5 at $5A1A
; (WaitUntilC71DClears).
;
; The nine bank 2 calls are still INCBIN. CallBankedHL and
; WaitUntilC71DClears are already source.

RunFlaggedMeasureScript::
    ld a, [$D389]
    bit 1, a
    ret z
    call $56C7
    call $56E8
    call $570A
    call $5734
    call $5756
    call $5778
    call $579A
    call $57BC
    ld a, [$D389]
    bit 7, a
    jr nz, .clearBit7
    ld a, $49
    ld [$C93D], a
    ld a, $C9
    ld [$C93E], a
    ld hl, $C71B
    ld a, $4C
    ld [hl+], a
    ld a, $84
    ld [hl+], a
    ld a, $46
    ld [hl+], a
    ld a, $66
    ld [hl+], a
    ld a, $0A
    ld [hl+], a
    jr .waitScript
.clearBit7:
    res 7, a
    ld [$D389], a
    call $57DE
    ld a, $49
    ld [$C93D], a
    ld a, $C9
    ld [$C93E], a
    ld hl, $C71B
    ld a, $4C
    ld [hl+], a
    ld a, $FC
    ld [hl+], a
    ld a, $46
    ld [hl+], a
    ld a, $66
    ld [hl+], a
    ld a, $0A
    ld [hl+], a
.waitScript:
    ld hl, WaitUntilC71DClears
    ld e, $05
    call CallBankedHL
    ret

RunFlaggedMeasureScriptEnd:
