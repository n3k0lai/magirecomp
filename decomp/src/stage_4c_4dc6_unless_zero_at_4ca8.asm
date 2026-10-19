; Bank 2 at $4CA8. Returns immediately when Z is set. Otherwise stages
; bank $4C and pointer $4DC6 through StagePointerUnlessD0B6Matches,
; which compares [$D0B6] with [$D103] and returns on a match.
;
; The same pointer is also staged from $48A5. That bank $4C routine
; is still INCBIN (file $0130DC6). StagePointerUnlessD0B6Matches is
; already source in this bank.

Stage4C4DC6UnlessZeroAt4CA8::
    ret z
    ld a, $4C
    ld bc, $4DC6
    call StagePointerUnlessD0B6Matches
    ret
