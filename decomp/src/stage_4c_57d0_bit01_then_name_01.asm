; Bank 2 at $4B31. Returns immediately when Z is set. Otherwise stages
; bank $4C and pointer $57D0 through StagePointerUnlessD0B6Matches,
; which compares [$D0B6] with [$D103] and returns on a match.
;
; TrySetBitPairAtPlus14 tests the two bytes at $D110 + $14 ($D124 and
; $D125) against mask $01. If either already has that bit, A is 0 and
; this returns. Otherwise the mask is stored in the second byte.
;
; A is then $01 for StageNameTextAndScript41C1, which builds the name
; text and plants the $4C $C1 $41 $66 $0A script at $C71B.
;
; StagePointerUnlessD0B6Matches, TrySetBitPairAtPlus14,
; StageNameTextAndScript41C1, and Script_4C_57D0 are already source.

Stage4C57D0Bit01ThenName01::
    ret z
    ld a, $4C
    ld bc, $57D0
    call StagePointerUnlessD0B6Matches
    ld a, $01
    ld hl, $D110
    call TrySetBitPairAtPlus14
    and a
    ret z
    ld a, $01
    call StageNameTextAndScript41C1
    ret

Stage4C57D0Bit01ThenName01End:
