; Bank 7 at $6648. The first uncovered byte after
; ZeroNameCountScript416DOrMarkD125.
;
; [$D076] is set to 1 and [$D077] to 0, so WriteIndexedNamesAndCount
; prints a count of zero. [$D071] is set to 1. The five-byte script at
; $C71B takes its bank and pointer from [$CDAA], [$CDAB], and [$CDAC],
; then handler DispatchScriptOpcode ($0A66).
;
; The complement of [$D124] is stored at [$D125]. CallBankedHL runs
; bank 5 WriteIndexedNamesAndCount, then this returns.
;
; WriteIndexedNamesAndCount, CallBankedHL, and DispatchScriptOpcode
; are already source. The script bank and pointer are the bytes at
; $CDAA, so this routine does not name a fixed script address.

ZeroNameCountScriptFromCdaaAndComplementD124::
    ld a, $01
    ld [$D076], a
    xor a
    ld [$D077], a
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
    ld a, [$D124]
    cpl
    ld [$D125], a
    ld hl, WriteIndexedNamesAndCount
    ld e, $05
    call CallBankedHL
    ret

ZeroNameCountScriptFromCdaaAndComplementD124End:
