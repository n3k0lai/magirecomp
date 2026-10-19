; Bank 2 at $4ECE. Returns immediately when Z is already set.
;
; Otherwise A is bank $4C and BC is $5320. StagePointerUnlessD0B6Matches
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
; StagePointerUnlessD0B6Matches, CallBankedHL, and
; SetD071PlantC71BScript4299 are already source. Bank $4C at $5320 is
; file $0131320 and is still INCBIN.

Stage4C5320Store10sThenBank5::
    ret z
    ld a, $4C
    ld bc, $5320
    call StagePointerUnlessD0B6Matches
    ld a, $10
    ld [$D0C5], a
    ld [$D0C6], a
    ld hl, $4595
    ld e, $05
    call CallBankedHL
    ret
