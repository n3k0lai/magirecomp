; Bank 7 at $6701. The first uncovered byte after
; CountZeroNamesAndPlantScript4A4E.
;
; [$D076] is set to 1 and [$D077] to 0, so WriteIndexedNamesAndCount
; prints a count of zero. The word at $D119 is copied onto $D117, and
; BC is left at $D119. [$D071] is set to 1. Bank 5
; WriteIndexedNamesAndCount runs through CallBankedHL.
;
; The five-byte script at $C71B then takes its bank and pointer from
; [$CDAA], [$CDAB], and [$CDAC], and its handler from
; DispatchScriptOpcode. This returns.
;
; WriteIndexedNamesAndCount, CallBankedHL, and DispatchScriptOpcode
; are already source.

CopyD119WordZeroCountThenPlantCdaaScript::
    ld a, $01
    ld [$D076], a
    xor a
    ld [$D077], a
    ld hl, $D119
    ld bc, $D117
    ld a, [hl+]
    ld [bc], a
    inc bc
    ld a, [hl+]
    ld [bc], a
    inc bc
    ld a, $01
    ld [$D071], a
    ld hl, WriteIndexedNamesAndCount
    ld e, $05
    call CallBankedHL
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
    ret
