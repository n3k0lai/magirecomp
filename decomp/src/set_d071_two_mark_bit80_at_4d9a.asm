; Bank 2 at $4D9A. Same sequence as SetD071TwoMarkBit80 at $4B54.
;
; [$D071] is set to 2. TrySetBitPairAtPlus14 tests the two bytes at
; $D110 + $14 ($D124 and $D125) against mask $80. If either byte already
; has that bit, A is 0 and this returns. Otherwise the mask is stored
; into $D125 and StageNameTextAndScript41C1 runs with A = $80.
;
; TrySetBitPairAtPlus14 and StageNameTextAndScript41C1 are already source.

SetD071TwoMarkBit80At4D9A::
    ld a, $02
    ld [$D071], a
    ld a, $80
    ld hl, $D110
    call TrySetBitPairAtPlus14
    and a
    ret z
    ld a, $80
    call StageNameTextAndScript41C1
    ret
