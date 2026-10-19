; Bank 2 at $4A19. Returns immediately when Z is set. Otherwise stages
; bank $4C and pointer $4F18 through StagePointerUnlessD0B6Matches,
; which compares [$D0B6] with [$D103] and returns on a match.
;
; The same sequence also lives at $47F8 (Stage4C4F18UnlessZero).
; StagePointerUnlessD0B6Matches is already source in this bank.
; Bank $4C at $4F18 is file $0130F18 and is still INCBIN.

Stage4C4F18UnlessZeroAt4A19::
    ret z
    ld a, $4C
    ld bc, $4F18
    call StagePointerUnlessD0B6Matches
    ret
