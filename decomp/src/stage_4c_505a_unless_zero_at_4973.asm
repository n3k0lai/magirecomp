; Bank 2 at $4973. Returns immediately when Z is set. Otherwise stages
; bank $4C and pointer $505A through StagePointerUnlessD0B6Matches,
; which compares [$D0B6] with [$D103] and returns on a match.
;
; StagePointerUnlessD0B6Matches is already source in this bank.
; Bank $4C at $505A is file $013105A and is still INCBIN.

Stage4C505AUnlessZeroAt4973::
    ret z
    ld a, $4C
    ld bc, $505A
    call StagePointerUnlessD0B6Matches
    ret
