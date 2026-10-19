; Bank 7 at $65F1. The first uncovered byte after AddCd93IntoNextSramByte.
;
; [$D076] is set to 1 and [$D077] to 0, so WriteIndexedNamesAndCount
; prints a count of zero. [$CD93] is tested against [$D124].
;
; If any of those bits are set, the five-byte script at $C71B is
; $4C $6D $41 $66 $0A: bank $4C, pointer $416D, handler
; DispatchScriptOpcode.
;
; If none are set, [$CD93] is ORed into the byte at $D110+$15 ($D125)
; through OrAIntoByteAtBc. The script at $C71B then takes its bank and
; pointer from [$CDAA], [$CDAB], and [$CDAC], and the same handler.
;
; Both paths call bank 5 WriteIndexedNamesAndCount through CallBankedHL,
; then CopyRecordForLowestSetBit, then store 1 at [$D071] and return.
;
; WriteIndexedNamesAndCount, CallBankedHL, OrAIntoByteAtBc,
; CopyRecordForLowestSetBit, and DispatchScriptOpcode are already source.
; Bank $4C at $416D is still INCBIN (file $013016D).

ZeroNameCountScript416DOrMarkD125::
    ld a, $01
    ld [$D076], a
    xor a
    ld [$D077], a
    ld a, [$CD93]
    ld b, a
    ld a, [$D124]
    and b
    jr z, .markD125

    ld hl, $C71B
    ld a, $4C
    ld [hl+], a
    ld a, $6D
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
    call OrAIntoByteAtBc
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

ZeroNameCountScript416DOrMarkD125End:
