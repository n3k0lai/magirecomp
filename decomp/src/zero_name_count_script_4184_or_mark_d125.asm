; Bank 7 at $667B. The first uncovered byte after
; ZeroNameCountScriptFromCdaaAndComplementD124.
;
; [$D076] is set to 1 and [$D077] to 0, so WriteIndexedNamesAndCount
; prints a count of zero. [$CD93] is tested against [$D126].
;
; If any of those bits are set, the five-byte script at $C71B is
; $4C $84 $41 $66 $0A: bank $4C, pointer $4184, handler
; DispatchScriptOpcode.
;
; If none are set, the bits of [$CD93] are cleared in the byte at
; $D110+$15 ($D125) through AndCplAIntoByteAtBc. The script at $C71B
; then takes its bank and pointer from [$CDAA], [$CDAB], and [$CDAC],
; and the same handler.
;
; Both paths call bank 5 WriteIndexedNamesAndCount through CallBankedHL,
; then CopyRecordForLowestSetBit, then store 1 at [$D071] and return.
;
; WriteIndexedNamesAndCount, CallBankedHL, AndCplAIntoByteAtBc,
; CopyRecordForLowestSetBit, and DispatchScriptOpcode are already source.
; Bank $4C at $4184 is still INCBIN (file $0130184).

ZeroNameCountScript4184OrMarkD125::
    ld a, $01
    ld [$D076], a
    xor a
    ld [$D077], a
    ld a, [$CD93]
    ld b, a
    ld a, [$D126]
    and b
    jr z, .markD125

    ld hl, $C71B
    ld a, $4C
    ld [hl+], a
    ld a, $84
    ld [hl+], a
    ld a, $41
    ld [hl+], a
    ld a, LOW(DispatchScriptOpcode)
    ld [hl+], a
    ld a, HIGH(DispatchScriptOpcode)
    ld [hl+], a
    jr .callNames

.markD125:
    ld a, b
    ld hl, $D110
    ld bc, $0015
    call AndCplAIntoByteAtBc
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

.callNames:
    ld hl, WriteIndexedNamesAndCount
    ld e, $05
    call CallBankedHL
    call CopyRecordForLowestSetBit
    ld a, $01
    ld [$D071], a
    ret

ZeroNameCountScript4184OrMarkD125End:
