; Bank 2 at $4F5F. Returns immediately when Z is set. Otherwise stages
; bank $4C and pointer $4C7E through StagePointerUnlessD0B6Matches,
; which compares [$D0B6] with [$D103] and returns on a match.
;
; StagePointerUnlessD0B6Matches is already source in this bank.
; The pointer at bank $4C $4C7E (file $0130C7E) is still INCBIN.

Stage4C4C7EUnlessZeroAt4F5F::
    ret z
    ld a, $4C
    ld bc, $4C7E
    call StagePointerUnlessD0B6Matches
    ret
