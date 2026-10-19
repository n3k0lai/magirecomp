; Bank 2 at $4EF2. Returns immediately when Z is set. Otherwise stages
; bank $4C and pointer $5805 through StagePointerUnlessD0B6Matches,
; which compares [$D0B6] with [$D103] and returns on a match.
;
; StagePointerUnlessD0B6Matches is already source in this bank.
; Script5805 at bank $4C $5805 is already source.

Stage4C5805UnlessZeroAt4EF2::
    ret z
    ld a, $4C
    ld bc, Script5805
    call StagePointerUnlessD0B6Matches
    ret
