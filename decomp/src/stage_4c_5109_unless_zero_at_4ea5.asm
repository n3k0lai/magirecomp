; Bank 2 at $4EA5. Returns immediately when Z is set. Otherwise stages
; bank $4C and pointer $5109 through StagePointerUnlessD0B6Matches,
; which compares [$D0B6] with [$D103] and returns on a match.
;
; StagePointerUnlessD0B6Matches is already source in this bank.
; Script_4C_5109 at bank $4C $5109 (file $0131109) is already source.

Stage4C5109UnlessZeroAt4EA5::
    ret z
    ld a, $4C
    ld bc, $5109
    call StagePointerUnlessD0B6Matches
    ret
