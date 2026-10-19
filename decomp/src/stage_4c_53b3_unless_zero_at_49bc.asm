; Bank 2 at $49BC. Returns immediately when Z is set. Otherwise stages
; bank $4C and pointer $53B3 through StagePointerUnlessD0B6Matches,
; which compares [$D0B6] with [$D103] and returns on a match.
;
; StagePointerUnlessD0B6Matches is already source in this bank.
; Bank $4C at $53B3 is file $01313B3 and is still INCBIN.
; The same pointer is also staged from $47EE.

Stage4C53B3UnlessZeroAt49BC::
    ret z
    ld a, $4C
    ld bc, $53B3
    call StagePointerUnlessD0B6Matches
    ret
