; Bank 2 at $4951. Returns immediately when Z is set. Otherwise stages
; bank $4C and pointer $5698 through StagePointerUnlessD0B6Matches,
; which compares [$D0B6] with [$D103] and returns on a match.
;
; StagePointerUnlessD0B6Matches is already source in this bank.
; Bank $4C at $5698 is file $0131698 and is still INCBIN.

Stage4C5698UnlessZeroAt4951::
    ret z
    ld a, $4C
    ld bc, $5698
    call StagePointerUnlessD0B6Matches
    ret
