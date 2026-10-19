; Bank 2 at $472E. Callers pass a bank in A and a pointer in BC, and
; they return first when Z is already set.
;
; [$D0B6] is compared with [$D103]. A match returns here. Otherwise the
; saved bank is stored at $C9CC and BC is stored little-endian at $C9CA.
; $C9C5 and $C9C6 are set to 1. The byte at $C9E4 is read and written
; back unchanged. [$D0DB] is copied to $C9E0 and [$D112] to $C9E1.
;
; CallBankedHL runs bank 4 at $71ED, still INCBIN (file $0131ED).
;
; wScriptRecord ($C706) is then $4C $00 $40 $66 $0A: bank $4C, pointer
; $4000, handler INITIAL_SCRIPT_HANDLER. CallBankedHL runs LcdOffSetup
; in bank 4.
;
; CallBankedHL, wScriptRecord, and INITIAL_SCRIPT_HANDLER are already
; source. LcdOffSetup is the bank 4 routine at $6346.

StagePointerUnlessD0B6Matches::
    ld d, a
    ld a, [$D0B6]
    ld hl, $D103
    cp [hl]
    ret z

    ld a, d
    ld [$C9CC], a
    ld hl, $C9CA
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld a, $01
    ld [$C9C5], a
    ld [$C9C6], a
    ld a, [$C9E4]
    ld [$C9E4], a
    ld a, [$D0DB]
    ld [$C9E0], a
    ld a, [$D112]
    ld [$C9E1], a
    ld hl, $71ED
    ld e, $04
    call CallBankedHL
    ld hl, wScriptRecord
    ld a, $4C
    ld [hl+], a
    ld a, LOW($4000)
    ld [hl+], a
    ld a, HIGH($4000)
    ld [hl+], a
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ld [hl+], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ld [hl+], a
    ld hl, LcdOffSetup
    ld e, $04
    call CallBankedHL
    ret
