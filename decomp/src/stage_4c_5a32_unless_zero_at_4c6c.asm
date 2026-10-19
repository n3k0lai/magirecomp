; Bank 2 at $4C6C. Returns immediately when Z is set. Otherwise stages
; bank $4C and pointer $5A32 through StagePointerUnlessD0B6Matches,
; which compares [$D0B6] with [$D103] and returns on a match.
;
; The same sequence also lives at $47D0 (Stage4C5A32UnlessZero).
; StagePointerUnlessD0B6Matches is already source in this bank.

Stage4C5A32UnlessZeroAt4C6C::
    ret z
    ld a, $4C
    ld bc, $5A32
    call StagePointerUnlessD0B6Matches
    ret
