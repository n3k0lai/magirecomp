; Bank 2 at $48E3. Returns immediately when Z is set. Otherwise stages
; bank $4C and pointer $4D87 through StagePointerUnlessD0B6Matches,
; which compares [$D0B6] with [$D103] and returns on a match.
;
; StagePointerUnlessD0B6Matches is already source in this bank.
; Bank $4C at $4D87 is file $0130D87 and is still INCBIN.

Stage4C4D87UnlessZeroAt48E3::
    ret z
    ld a, $4C
    ld bc, $4D87
    call StagePointerUnlessD0B6Matches
    ret
