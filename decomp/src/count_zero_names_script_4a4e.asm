; Bank 7 at $66D2. SetD071TwoStage4D35CallBank7 maps this bank and calls
; here after staging $4C:$4D35.
;
; [$D076] is set to 1 and [$D077] to 0, so WriteIndexedNamesAndCount uses
; a zero alternate count. [$D071] is set to 1. The five-byte script at
; $C71B is $4C $4E $4A $66 $0A: bank $4C, pointer $4A4E, handler $0A66.
; [$D126] is copied to [$D125].
;
; CallBankedHL runs bank 5 WriteIndexedNamesAndCount, then this returns.
; WriteIndexedNamesAndCount and CallBankedHL are already source.

CountZeroNamesAndPlantScript4A4E::
    ld a, $01
    ld [$D076], a
    xor a
    ld [$D077], a
    ld a, $01
    ld [$D071], a
    ld hl, $C71B
    ld a, $4C
    ld [hl+], a
    ld a, $4E
    ld [hl+], a
    ld a, $4A
    ld [hl+], a
    ld a, $66
    ld [hl+], a
    ld a, $0A
    ld [hl+], a
    ld a, [$D126]
    ld [$D125], a
    ld hl, WriteIndexedNamesAndCount
    ld e, $05
    call CallBankedHL
    ret
