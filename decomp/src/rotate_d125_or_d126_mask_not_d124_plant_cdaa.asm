; Bank 7 at $67E3. The first uncovered byte after
; AddTwoToFiveNextSramThenPlantCdaa.
;
; [$D076] is set to 1 and [$D077] to 0, so WriteIndexedNamesAndCount
; prints a count of zero. [$D125] is rotated left. That byte is then
; ORed with [$D126] and ANDed with the complement of [$D124], and the
; result is stored back at [$D125]. [$D111] is set to $33 and [$D071]
; to 1.
;
; CallBankedHL runs bank 5 WriteIndexedNamesAndCount. The five-byte
; script at $C71B takes its bank and pointer from [$CDAA], [$CDAB],
; and [$CDAC], then handler DispatchScriptOpcode ($0A66). This returns.
;
; WriteIndexedNamesAndCount, CallBankedHL, and DispatchScriptOpcode
; are already source. The script bank and pointer are the bytes at
; $CDAA, so this routine does not name a fixed script address.

RotateD125OrD126MaskNotD124ThenPlantCdaa::
    ld a, $01
    ld [$D076], a
    xor a
    ld [$D077], a
    ld hl, $D125
    rlc [hl]
    ld a, [$D126]
    or [hl]
    ld [hl], a
    ld a, [$D124]
    cpl
    and [hl]
    ld [hl], a
    ld a, $33
    ld [$D111], a
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
