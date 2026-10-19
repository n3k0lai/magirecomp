; Bank 2 at $4AD2. Returns immediately when Z is set. Otherwise stages
; bank $4C and pointer $53EE through StagePointerUnlessD0B6Matches,
; which compares [$D0B6] with [$D103] and returns on a match.
;
; StagePointerUnlessD0B6Matches is already source in this bank.
; Bank $4C at $53EE is file $01313EE and is still INCBIN.

Stage4C53EEUnlessZeroAt4AD2::
    ret z
    ld a, $4C
    ld bc, $53EE
    call StagePointerUnlessD0B6Matches
    ret

Stage4C53EEUnlessZeroAt4AD2End:
