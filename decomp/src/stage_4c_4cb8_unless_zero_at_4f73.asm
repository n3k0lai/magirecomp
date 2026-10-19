; Bank 2 at $4F73. Returns immediately when Z is set. Otherwise stages
; bank $4C and pointer $4CB8 through StagePointerUnlessD0B6Matches,
; which compares [$D0B6] with [$D103] and returns on a match.
;
; StagePointerUnlessD0B6Matches is already source in this bank.
; The pointer at bank $4C $4CB8 (file $0130CB8) is still INCBIN. It is
; already listed from the $4EFC caller.

Stage4C4CB8UnlessZeroAt4F73::
    ret z
    ld a, $4C
    ld bc, $4CB8
    call StagePointerUnlessD0B6Matches
    ret
