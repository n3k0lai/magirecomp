; Bank 2 at $4A80. Returns immediately when Z is set. Otherwise stages
; bank $4C and pointer $4DC6 through StagePointerUnlessD0B6Matches,
; which compares [$D0B6] with [$D103] and returns on a match.
;
; The same sequence also lives at $4CA8. That bank $4C routine is
; already listed (file $0130DC6). StagePointerUnlessD0B6Matches is
; already source in this bank.

Stage4C4DC6UnlessZeroAt4A80::
    ret z
    ld a, $4C
    ld bc, $4DC6
    call StagePointerUnlessD0B6Matches
    ret
