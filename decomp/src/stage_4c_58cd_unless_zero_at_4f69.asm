; Bank 2 at $4F69. Returns immediately when Z is set. Otherwise stages
; bank $4C and pointer $58CD through StagePointerUnlessD0B6Matches,
; which compares [$D0B6] with [$D103] and returns on a match.
;
; StagePointerUnlessD0B6Matches is already source in this bank.
; The pointer at bank $4C $58CD (file $01318CD) is still INCBIN.

Stage4C58CDUnlessZeroAt4F69::
    ret z
    ld a, $4C
    ld bc, $58CD
    call StagePointerUnlessD0B6Matches
    ret
