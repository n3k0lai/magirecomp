; Bank 2 at $4A8A. Returns immediately when Z is set. Otherwise stages
; bank $4C and pointer $52AE through StagePointerUnlessD0B6Matches,
; which compares [$D0B6] with [$D103] and returns on a match.
;
; StagePointerUnlessD0B6Matches is already source in this bank.
; Bank $4C at $52AE is file $01312AE and is still INCBIN.

Stage4C52AEUnlessZeroAt4A8A::
    ret z
    ld a, $4C
    ld bc, $52AE
    call StagePointerUnlessD0B6Matches
    ret
