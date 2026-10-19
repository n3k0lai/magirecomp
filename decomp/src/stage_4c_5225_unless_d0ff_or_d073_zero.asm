; Bank 2 at $517D. Nonzero [$D0FF] jumps to $5191, still INCBIN
; (file $009191). Zero [$D073] returns. Otherwise A is bank $4C and
; BC is $5225. StagePointerUnlessD0B6Matches compares [$D0B6] with
; [$D103] and returns on a match.
;
; That bank $4C routine is still INCBIN (file $0131225).
; StagePointerUnlessD0B6Matches is already source in this bank.

Stage4C5225UnlessD0FFOrD073Zero::
    ld a, [$D0FF]
    and a
    jr nz, $5191
    ld a, [$D073]
    and a
    ret z
    ld a, $4C
    ld bc, $5225
    call StagePointerUnlessD0B6Matches
    ret
