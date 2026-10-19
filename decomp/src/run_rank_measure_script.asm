; RunRankMeasureScript. Bank 2 at $596F.
;
; AdjustA000RecordOnce calls this after the rank-band step at $3821.
; Unless bit 1 of $D389 is set, this returns. That caller sets the bit,
; so the three setup calls run: $56C7, $56E8, and $570A.
;
; The five-byte script at $C71B is $4C $8D $47 $66 $0A. $49 $C9 is stored
; at $C93D so that word points at $C949. CallBankedHL then runs bank 5
; at $5A1A (WaitUntilC71DClears).
;
; The three bank 2 calls are still INCBIN. CallBankedHL and
; WaitUntilC71DClears are already source.

RunRankMeasureScript::
    ld a, [$D389]
    bit 1, a
    ret z
    call $56C7
    call $56E8
    call $570A
    ld a, $49
    ld [$C93D], a
    ld a, $C9
    ld [$C93E], a
    ld hl, $C71B
    ld a, $4C
    ld [hl+], a
    ld a, $8D
    ld [hl+], a
    ld a, $47
    ld [hl+], a
    ld a, $66
    ld [hl+], a
    ld a, $0A
    ld [hl+], a
    ld hl, WaitUntilC71DClears
    ld e, $05
    call CallBankedHL
    ret

RunRankMeasureScriptEnd:
