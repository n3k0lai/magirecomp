; Bank 2 at $4BCD. Returns immediately when Z is set. Otherwise loads
; bank $4C into A and falls into StagePointer5A32, which sets BC to
; $5A32 and calls StagePointerUnlessD0B6Matches.
;
; StagePointerUnlessD0B6Matches and Script_4C_5A32 are already source.

Stage4C5A32UnlessZeroAt4BCD::
    ret z
    ld a, $4C
