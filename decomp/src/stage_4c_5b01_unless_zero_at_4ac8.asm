; Bank 2 at $4AC8. Returns immediately when Z is set. Otherwise stages
; bank $4C and pointer $5B01 through StagePointerUnlessD0B6Matches,
; which compares [$D0B6] with [$D103] and returns on a match.
;
; StagePointerUnlessD0B6Matches is already source in this bank.
; Bank $4C at $5B01 is file $0131B01 and is still INCBIN.

Stage4C5B01UnlessZeroAt4AC8::
    ret z
    ld a, $4C
    ld bc, $5B01
    call StagePointerUnlessD0B6Matches
    ret

Stage4C5B01UnlessZeroAt4AC8End:
