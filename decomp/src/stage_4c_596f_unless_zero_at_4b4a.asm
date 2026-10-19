; Bank 2 at $4B4A. Returns immediately when Z is set. Otherwise stages
; bank $4C and pointer $596F through StagePointerUnlessD0B6Matches,
; which compares [$D0B6] with [$D103] and returns on a match.
;
; StagePointerUnlessD0B6Matches and Script596F are already source.
; The same pointer is also staged from $495B.

Stage4C596FUnlessZeroAt4B4A::
    ret z
    ld a, $4C
    ld bc, $596F
    call StagePointerUnlessD0B6Matches
    ret

Stage4C596FUnlessZeroAt4B4AEnd:
