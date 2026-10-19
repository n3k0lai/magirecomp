; Bank 2 at $4BC3. Returns immediately when Z is set. Otherwise stages
; bank $4C and pointer $59D2 through StagePointerUnlessD0B6Matches,
; which compares [$D0B6] with [$D103] and returns on a match.
;
; StagePointerUnlessD0B6Matches is already source. Bank $4C at $59D2
; is file $01319D2 and is still INCBIN.

Stage4C59D2UnlessZeroAt4BC3::
    ret z
    ld a, $4C
    ld bc, $59D2
    call StagePointerUnlessD0B6Matches
    ret

Stage4C59D2UnlessZeroAt4BC3End:
