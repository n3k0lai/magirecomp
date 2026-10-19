; Bank 2 at $4EE8. Returns immediately when Z is set. Otherwise stages
; bank $4C and pointer $51D0 through StagePointerUnlessD0B6Matches,
; which compares [$D0B6] with [$D103] and returns on a match.
;
; StagePointerUnlessD0B6Matches is already source in this bank.
; ScriptStaged51D0 at bank $4C $51D0 (file $01311D0) is already source.

Stage4C51D0UnlessZeroAt4EE8::
    ret z
    ld a, $4C
    ld bc, ScriptStaged51D0
    call StagePointerUnlessD0B6Matches
    ret
