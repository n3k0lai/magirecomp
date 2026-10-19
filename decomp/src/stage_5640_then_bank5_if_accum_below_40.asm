; Bank 2 at $4838. Returns immediately when Z is already set.
;
; Otherwise A is bank $4C and BC is $5640. StagePointerUnlessD0B6Matches
; compares [$D0B6] with [$D103] and returns on a match; otherwise it
; plants that bank and pointer.
;
; AddDividerStep then adds a divider-derived step to [$FFA9] and returns
; the new byte in A. A value of $40 or more returns here. Below that,
; CallBankedHL runs bank 5 at $4B45 (file $014B45), still INCBIN.
;
; StagePointerUnlessD0B6Matches, AddDividerStep, and CallBankedHL are
; already source.

Stage5640ThenBank5IfAccumBelow40::
    ret z
    ld a, $4C
    ld bc, $5640
    call StagePointerUnlessD0B6Matches
    call AddDividerStep
    cp $40
    ret nc
    ld hl, $4B45
    ld e, $05
    call CallBankedHL
    ret
