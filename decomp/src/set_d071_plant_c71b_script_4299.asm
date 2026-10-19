; Bank 5 at $4595. Stage4C4E80Store10sThenBank5 reaches this through
; CallBankedHL after staging $4C:$4E80 and storing $10 in [$D0C5] and
; [$D0C6].
;
; [$D071] is set to 1. The five-byte script at $C71B is $4C $99 $42 $66 $0A:
; bank $4C, pointer $4299, handler $0A66. WriteIndexedNamesAndCount then
; builds the indexed names and the count text, and this routine returns.
;
; WriteIndexedNamesAndCount is already source. Bank $4C at $4299 (file
; $0130299) is still INCBIN.

SetD071PlantC71BScript4299::
    ld a, $01
    ld [$D071], a
    ld hl, $C71B
    ld a, $4C
    ld [hl+], a
    ld a, $99
    ld [hl+], a
    ld a, $42
    ld [hl+], a
    ld a, $66
    ld [hl+], a
    ld a, $0A
    ld [hl+], a
    call WriteIndexedNamesAndCount
    ret
