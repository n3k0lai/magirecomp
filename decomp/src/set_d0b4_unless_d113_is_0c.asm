; Bank 5 at $4B45. Stage5640ThenBank5IfAccumBelow40 calls here through
; CallBankedHL when [$FFA9] is below $40, after staging $4C:$5640.
;
; [$D113] is record+3 of the usual $D110 buffer. $0C leaves [$D0B4]
; unchanged. Any other value stores $01 there. FinishLowD103Refresh
; treats a nonzero [$D0B4] as the alternate script and skip path.

SetD0B4UnlessD113Is0C::
    ld a, [$D113]
    cp $0C
    ret z
    ld a, $01
    ld [$D0B4], a
    ret
