; Bank 7 at $6551. AddCd93IntoIndexedSramBelowFive calls this first.
;
; When [$CD94] is zero, [$D077] (wNameCountAlt) becomes [$CD93], and
; [$D076] (wNameCountFlag) and [$D070] are both set to 1.
;
; When [$CD94] is nonzero, the byte at $D110 + $0A + [$CD94] gains
; [$CD93], capped at $63. wNameCountAlt becomes the amount that fit,
; and wNameCountFlag is set to 2. [$D070] is left alone.
;
; Both paths store 1 at [$D071]. The five-byte script at $C71B takes
; its bank and pointer from [$CDAA], [$CDAB], and [$CDAC], and its
; handler is DispatchScriptOpcode. Bank 5 WriteIndexedNamesAndCount
; then runs through CallBankedHL, and this returns.
;
; wNameCountFlag and wNameCountAlt are the names from
; write_indexed_names_and_count.asm. WriteIndexedNamesAndCount,
; CallBankedHL, and DispatchScriptOpcode are already source. The
; script bank and pointer are the bytes at $CDAA, so this routine
; does not name a fixed script address.

AddCd93IntoD110PlusTenOrNameCount::
    ld hl, $CD94
    ld a, [hl]
    and a
    jr z, .cd94Zero

    ld b, $0A
    add b
    ld c, a
    ld b, $00
    ld hl, $D110
    add hl, bc
    ld a, [hl]
    push af
    push hl
    ld hl, $CD93
    add [hl]
    ld b, $63
    cp b
    jr c, .storeCapped

    ld a, b

.storeCapped:
    pop hl
    ld [hl], a
    pop bc
    sub b
    ld [wNameCountAlt], a
    ld a, $02
    ld [wNameCountFlag], a
    jr .plantScript

.cd94Zero:
    ld hl, $CD93
    ld a, [hl]
    ld [wNameCountAlt], a
    ld a, $01
    ld [wNameCountFlag], a
    ld [$D070], a

.plantScript:
    ld a, $01
    ld [$D071], a
    ld hl, $C71B
    ld a, [$CDAA]
    ld [hl+], a
    ld a, [$CDAB]
    ld [hl+], a
    ld a, [$CDAC]
    ld [hl+], a
    ld a, LOW(DispatchScriptOpcode)
    ld [hl+], a
    ld a, HIGH(DispatchScriptOpcode)
    ld [hl+], a
    ld hl, WriteIndexedNamesAndCount
    ld e, $05
    call CallBankedHL
    ret
