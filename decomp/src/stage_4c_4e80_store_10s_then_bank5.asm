; Bank 2 at $4929. Returns immediately when Z is already set.
;
; Otherwise A is bank $4C and BC is $4E80. StagePointerUnlessD0B6Matches
; compares [$D0B6] with [$D103] and returns on a match; otherwise it
; plants that bank and pointer.
;
; [$D0C5] and [$D0C6] are both set to $10. ClearMarksAndWalkSlots folds
; a nonzero [$D0C5] as ([$D0C6] * [$D073]) >> 5 into the $D0E0 pair.
;
; CallBankedHL then runs bank 5 at $4595 (file $014595), still INCBIN.
; Those bytes set [$D071] to 1, plant $4C $99 $42 $66 $0A at $C71B, and
; call $5575.
;
; AddDividerStep adds a divider-derived step to [$FFA9] and returns the
; new byte in A. A value of $40 or more returns here. Below that,
; CallBankedHL runs bank 5 at $4B45 (SetD0B4UnlessD113Is0C).
;
; StagePointerUnlessD0B6Matches, CallBankedHL, AddDividerStep, and
; SetD0B4UnlessD113Is0C are already source. Bank $4C at $4E80 is file
; $0130E80 and is still INCBIN.

Stage4C4E80Store10sThenBank5::
    ret z
    ld a, $4C
    ld bc, $4E80
    call StagePointerUnlessD0B6Matches
    ld a, $10
    ld [$D0C5], a
    ld [$D0C6], a
    ld hl, $4595
    ld e, $05
    call CallBankedHL
    call AddDividerStep
    cp $40
    ret nc
    ld hl, $4B45
    ld e, $05
    call CallBankedHL
    ret
