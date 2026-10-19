; Bank 2 at $4850. [$D071] is set to 2.
;
; TrySetBitPairAtPlus14 tests the two bytes at $D110 + $14 ($D124 and
; $D125) against mask $10. If either byte already has that bit, A is 0
; and this returns. Otherwise the mask is stored into $D125 and
; StageNameTextAndScript41C1 runs with A = $10.
;
; TrySetBitPairAtPlus14 and StageNameTextAndScript41C1 are already source.

SetD071TwoMarkBit10::
    ld a, $02
    ld [$D071], a
    ld a, $10
    ld hl, $D110
    call TrySetBitPairAtPlus14
    and a
    ret z
    ld a, $10
    call StageNameTextAndScript41C1
    ret
