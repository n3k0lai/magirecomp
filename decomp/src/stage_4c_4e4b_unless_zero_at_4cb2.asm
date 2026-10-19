; Bank 2 at $4CB2. Returns immediately when Z is set. Otherwise stages
; bank $4C and pointer $4E4B through StagePointerUnlessD0B6Matches,
; which compares [$D0B6] with [$D103] and returns on a match.
;
; That bank $4C routine is still INCBIN (file $0130E4B).
; StagePointerUnlessD0B6Matches is already source in this bank.

Stage4C4E4BUnlessZeroAt4CB2::
    ret z
    ld a, $4C
    ld bc, $4E4B
    call StagePointerUnlessD0B6Matches
    ret
