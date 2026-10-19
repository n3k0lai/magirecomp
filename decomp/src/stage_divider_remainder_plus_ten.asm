; Bank 7 at $72B1. The first uncovered byte after StageCd93AsNameCount.
;
; [$D076] (wNameCountFlag) is set to 1. AddDividerStep returns the new
; byte at $FFA9 in A. DivideCByB divides that byte by $1E, and the
; remainder in L plus $0A is stored at [$D077] (wNameCountAlt), so
; WriteIndexedNamesAndCount prints a count from 10 through 39.
;
; CallBankedHL runs bank 5 WriteIndexedNamesAndCount. [$D071] is then
; set to 1. The five-byte script at $C71B takes its bank and pointer
; from [$CDAA], [$CDAB], and [$CDAC], then handler DispatchScriptOpcode
; ($0A66). WriteIndexedNamesAndCount runs again, and this returns.
;
; wNameCountFlag and wNameCountAlt are the names from
; write_indexed_names_and_count.asm. AddDividerStep, DivideCByB,
; WriteIndexedNamesAndCount, CallBankedHL, and DispatchScriptOpcode
; are already source. The script bank and pointer are the bytes at
; $CDAA, so this routine does not name a fixed script address.

StageDividerRemainderPlusTen::
    ld a, $01
    ld [wNameCountFlag], a
    call AddDividerStep
    ld c, a
    ld b, $1E
    call DivideCByB
    ld a, l
    add $0A
    ld [wNameCountAlt], a
    ld hl, WriteIndexedNamesAndCount
    ld e, $05
    call CallBankedHL
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

StageDividerRemainderPlusTenEnd:
