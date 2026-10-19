; Bank 2 at $4B27. Returns immediately when Z is set. Otherwise stages
; bank $4C and pointer $5854 through StagePointerUnlessD0B6Matches,
; which compares [$D0B6] with [$D103] and returns on a match.
;
; StagePointerUnlessD0B6Matches is already source in this bank.
; Bank $4C at $5854 is file $0131854 and is still INCBIN.

Stage4C5854UnlessZeroAt4B27::
    ret z
    ld a, $4C
    ld bc, $5854
    call StagePointerUnlessD0B6Matches
    ret

Stage4C5854UnlessZeroAt4B27End:
