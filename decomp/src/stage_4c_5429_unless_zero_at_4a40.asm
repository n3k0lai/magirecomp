; Bank 2 at $4A40. Returns immediately when Z is set. Otherwise stages
; bank $4C and pointer $5429 through StagePointerUnlessD0B6Matches,
; which compares [$D0B6] with [$D103] and returns on a match.
;
; StagePointerUnlessD0B6Matches is already source in this bank.
; Bank $4C at $5429 is file $0131429 and is still INCBIN.

Stage4C5429UnlessZeroAt4A40::
    ret z
    ld a, $4C
    ld bc, $5429
    call StagePointerUnlessD0B6Matches
    ret
