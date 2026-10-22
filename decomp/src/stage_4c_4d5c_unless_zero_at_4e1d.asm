; Bank 2 at $4E1D. Returns immediately when Z is set. Otherwise stages
; bank $4C and pointer $4D5C through StagePointerUnlessD0B6Matches,
; which compares [$D0B6] with [$D103] and returns on a match.
;
; StagePointerUnlessD0B6Matches is already source in this bank.
; Bank $4C at $4D5C is Script_4C_4D5C, already source.

Stage4C4D5CUnlessZeroAt4E1D::
    ret z
    ld a, $4C
    ld bc, $4D5C
    call StagePointerUnlessD0B6Matches
    ret
