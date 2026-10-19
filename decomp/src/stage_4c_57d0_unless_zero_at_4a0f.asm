; Bank 2 at $4A0F. Returns immediately when Z is set. Otherwise stages
; bank $4C and pointer $57D0 through StagePointerUnlessD0B6Matches,
; which compares [$D0B6] with [$D103] and returns on a match.
;
; The same sequence also lives at $47E4 (Stage4C57D0UnlessZero).
; StagePointerUnlessD0B6Matches is already source in this bank.
; Bank $4C at $57D0 is file $01317D0 and is still INCBIN.

Stage4C57D0UnlessZeroAt4A0F::
    ret z
    ld a, $4C
    ld bc, $57D0
    call StagePointerUnlessD0B6Matches
    ret
