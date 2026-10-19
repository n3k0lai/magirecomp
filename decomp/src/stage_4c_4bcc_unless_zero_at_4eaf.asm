; Bank 2 at $4EAF. Returns immediately when Z is set. Otherwise stages
; bank $4C and pointer $4BCC through StagePointerUnlessD0B6Matches,
; which compares [$D0B6] with [$D103] and returns on a match.
;
; StagePointerUnlessD0B6Matches is already source in this bank.
; Bank $4C at $4BCC (file $0130BCC) is still INCBIN.

Stage4C4BCCUnlessZeroAt4EAF::
    ret z
    ld a, $4C
    ld bc, $4BCC
    call StagePointerUnlessD0B6Matches
    ret
