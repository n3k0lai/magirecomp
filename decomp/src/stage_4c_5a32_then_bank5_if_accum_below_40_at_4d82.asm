; Bank 2 at $4D82. Returns immediately when Z is already set.
;
; Otherwise A is bank $4C and BC is $5A32. StagePointerUnlessD0B6Matches
; compares [$D0B6] with [$D103] and returns on a match; otherwise it
; plants that bank and pointer.
;
; AddDividerStep then adds a divider-derived step to [$FFA9] and returns
; the new byte in A. A value of $40 or more returns here. Below that,
; CallBankedHL runs bank 5 at $4B45 (SetD0B4UnlessD113Is0C).
;
; StagePointerUnlessD0B6Matches, AddDividerStep, CallBankedHL, and
; SetD0B4UnlessD113Is0C are already source. Bank $4C at $5A32 is file
; $0131A32 and is still INCBIN. The same sequence also lives at $4D16.

Stage4C5A32ThenBank5IfAccumBelow40At4D82::
    ret z
    ld a, $4C
    ld bc, $5A32
    call StagePointerUnlessD0B6Matches
    call AddDividerStep
    cp $40
    ret nc
    ld hl, $4B45
    ld e, $05
    call CallBankedHL
    ret
