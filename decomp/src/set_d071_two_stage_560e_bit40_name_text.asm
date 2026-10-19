; Bank 2 at $4C76. [$D071] is set to 2. Bank $4C and pointer $560E
; are staged through StagePointerUnlessD0B6Matches, which compares
; [$D0B6] with [$D103] and returns on a match.
;
; TrySetBitPairAtPlus14 tests the two bytes at $D110 + $14 ($D124 and
; $D125) against mask $40. If either already has that bit, A is 0 and
; this returns. Otherwise the mask is stored in the second byte.
;
; A is then $40 for StageNameTextAndScript41C1, which builds the name
; text and plants the $4C $C1 $41 $66 $0A script at $C71B.
;
; StagePointerUnlessD0B6Matches, TrySetBitPairAtPlus14, and
; StageNameTextAndScript41C1 are already source. Bank $4C at $560E is
; file $013160E and is still INCBIN.

SetD071TwoStage560EBit40NameText::
    ld a, $02
    ld [$D071], a
    ld a, $4C
    ld bc, $560E
    call StagePointerUnlessD0B6Matches
    ld a, $40
    ld hl, $D110
    call TrySetBitPairAtPlus14
    and a
    ret z
    ld a, $40
    call StageNameTextAndScript41C1
    ret
