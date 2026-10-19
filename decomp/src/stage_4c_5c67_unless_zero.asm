; Bank 2 at $4E7C. Returns immediately when Z is set. Otherwise stages
; bank $4C and pointer $5C67 through StagePointerUnlessD0B6Matches,
; which compares [$D0B6] with [$D103] and returns on a match.
;
; StagePointerUnlessD0B6Matches is already source in this bank.
; Bank $4C at $5C67 is file $0131C67.

Stage4C5C67UnlessZero::
    ret z
    ld a, $4C
    ld bc, $5C67
    call StagePointerUnlessD0B6Matches
    ret
