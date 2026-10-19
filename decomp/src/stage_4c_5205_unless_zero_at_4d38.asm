; Bank 2 at $4D38. Returns immediately when Z is set. Otherwise stages
; bank $4C and pointer $5205 through StagePointerUnlessD0B6Matches,
; which compares [$D0B6] with [$D103] and returns on a match.
;
; StagePointerUnlessD0B6Matches is already source in this bank.
; Bank $4C at $5205 is file $0131205 and is still INCBIN.

Stage4C5205UnlessZeroAt4D38::
    ret z
    ld a, $4C
    ld bc, $5205
    call StagePointerUnlessD0B6Matches
    ret
