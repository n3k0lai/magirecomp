; Bank 2 at $4D0C. Returns immediately when Z is set. Otherwise stages
; bank $4C and pointer $4D87 through StagePointerUnlessD0B6Matches,
; which compares [$D0B6] with [$D103] and returns on a match.
;
; StagePointerUnlessD0B6Matches is already source in this bank.
; Bank $4C at $4D87 is Script_4C_4D87, already source.

Stage4C4D87UnlessZero::
    ret z
    ld a, $4C
    ld bc, $4D87
    call StagePointerUnlessD0B6Matches
    ret
