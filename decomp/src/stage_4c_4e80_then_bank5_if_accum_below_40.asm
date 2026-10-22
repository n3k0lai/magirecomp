; Bank 2 at $49C6. Returns immediately when Z is already set.
;
; Otherwise A is bank $4C and BC is $4E80. StagePointerUnlessD0B6Matches
; compares [$D0B6] with [$D103] and returns on a match; otherwise it
; plants that bank and pointer.
;
; AddDividerStep then adds a divider-derived step to [$FFA9] and returns
; the new byte in A. A value of $40 or more returns here. Below that,
; CallBankedHL runs bank 5 at $4B45 (SetD0B4UnlessD113Is0C).
;
; StagePointerUnlessD0B6Matches, AddDividerStep, CallBankedHL,
; SetD0B4UnlessD113Is0C, and bank $4C at $4E80 (Script_4C_4E80) are already
; source. The same $4E80 pointer is also staged from $4865, $4929, and $4C40.

Stage4C4E80ThenBank5IfAccumBelow40::
    ret z
    ld a, $4C
    ld bc, $4E80
    call StagePointerUnlessD0B6Matches
    call AddDividerStep
    cp $40
    ret nc
    ld hl, $4B45
    ld e, $05
    call CallBankedHL
    ret
