; Bank 2 at $47D0. Returns immediately when Z is set. Otherwise stages
; bank $4C and pointer $5A32 through StagePointerUnlessD0B6Matches,
; which compares [$D0B6] with [$D103] and returns on a match.
;
; StagePointerUnlessD0B6Matches is already source in this bank.

Stage4C5A32UnlessZero::
    ret z
    ld a, $4C
    ld bc, $5A32
    call StagePointerUnlessD0B6Matches
    ret
