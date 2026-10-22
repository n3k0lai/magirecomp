; Bank 2 at $4FB3. Returns immediately when Z is already set.
;
; Otherwise A is bank $4C and BC is $57D0. StagePointerUnlessD0B6Matches
; compares [$D0B6] with [$D103] and returns on a match; otherwise it
; plants that bank and pointer.
;
; [$D0C5] and [$D0C6] are both set to $10. ClearMarksAndWalkSlots folds
; a nonzero [$D0C5] as ([$D0C6] * [$D073]) >> 5 into the $D0E0 pair.
;
; CallBankedHL then runs bank 5 at $4595 (SetD071PlantC71BScript4299),
; which sets [$D071] to 1, plants $4C $99 $42 $66 $0A at $C71B, and
; calls WriteIndexedNamesAndCount.
;
; StagePointerUnlessD0B6Matches, CallBankedHL, Script_4C_57D0, and
; SetD071PlantC71BScript4299 are already source.

Stage4C57D0Store10sThenBank5At4FB3::
    ret z
    ld a, $4C
    ld bc, $57D0
    call StagePointerUnlessD0B6Matches
    ld a, $10
    ld [$D0C5], a
    ld [$D0C6], a
    ld hl, $4595
    ld e, $05
    call CallBankedHL
    ret
