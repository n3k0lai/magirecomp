; Bank 2 at $4995. Returns immediately when Z is set. Otherwise stages
; bank $4C and pointer $56D6 through StagePointerUnlessD0B6Matches,
; which compares [$D0B6] with [$D103] and returns on a match.
;
; StagePointerUnlessD0B6Matches is already source in this bank.
; Bank $4C at $56D6 is file $01316D6 and is still INCBIN.

Stage4C56D6UnlessZeroAt4995::
    ret z
    ld a, $4C
    ld bc, $56D6
    call StagePointerUnlessD0B6Matches
    ret
