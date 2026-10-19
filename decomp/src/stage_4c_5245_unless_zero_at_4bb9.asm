; Bank 2 at $4BB9. Returns immediately when Z is set. Otherwise stages
; bank $4C and pointer $5245 through StagePointerUnlessD0B6Matches,
; which compares [$D0B6] with [$D103] and returns on a match.
;
; StagePointerUnlessD0B6Matches is already source. Bank $4C at $5245
; is file $0131245 and is still INCBIN.

Stage4C5245UnlessZeroAt4BB9::
    ret z
    ld a, $4C
    ld bc, $5245
    call StagePointerUnlessD0B6Matches
    ret

Stage4C5245UnlessZeroAt4BB9End:
