; Nine-byte status names at file $01E475 (bank 7, $6475), then
; SubCd93FromD110PlusTenOrNameCount at $64B5.
;
; One space separates these names from the eight-byte list that ends
; at this address. Each name is nine bytes, space-padded. The routine
; that follows is the subtract twin of AddCd93IntoD110PlusTenOrNameCount.
;
; When [$CD94] is zero, [$D077] (wNameCountAlt) becomes [$CD93] and
; [$D076] (wNameCountFlag) is set to 1. [$D070] is left alone.
;
; When [$CD94] is nonzero, [$CD93] is subtracted from the byte at
; $D110 + $0A + [$CD94], and that byte floors at 0. wNameCountAlt
; becomes the amount removed, and wNameCountFlag is set to 2.
;
; Both paths store 1 at [$D071]. The five-byte script at $C71B takes
; its bank and pointer from [$CDAA], [$CDAB], and [$CDAC], and its
; handler is DispatchScriptOpcode. Bank 5 WriteIndexedNamesAndCount
; then runs through CallBankedHL, and this returns.
;
; wNameCountFlag and wNameCountAlt are the names from
; write_indexed_names_and_count.asm. WriteIndexedNamesAndCount,
; CallBankedHL, and DispatchScriptOpcode are already source.

NineByteStatusNames::
    INCBIN "roms/magination.gbc", $1E475, $40

SubCd93FromD110PlusTenOrNameCount::
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
    sub [hl]
    jr nc, .storeFloored

    xor a

.storeFloored:
    pop hl
    ld [hl], a
    pop bc
    sub b
    cpl
    inc a
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
