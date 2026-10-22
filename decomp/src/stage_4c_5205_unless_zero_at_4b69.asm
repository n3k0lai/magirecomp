; Bank 2 at $4B69. Returns immediately when Z is set. Otherwise stages
; bank $4C and pointer $5205 through StagePointerUnlessD0B6Matches,
; which compares [$D0B6] with [$D103] and returns on a match.
;
; StagePointerUnlessD0B6Matches and Script_4C_5205 are already source.
; The same pointer is also staged from $4D38.

Stage4C5205UnlessZeroAt4B69::
    ret z
    ld a, $4C
    ld bc, $5205
    call StagePointerUnlessD0B6Matches
    ret

Stage4C5205UnlessZeroAt4B69End:
