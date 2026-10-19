; Bank 2 at $4EB9. Same sequence as SetD071TwoMarkBit80 at $4B54,
; with mask $40.
;
; [$D071] is set to 2. TrySetBitPairAtPlus14 tests the two bytes at
; $D110 + $14 ($D124 and $D125) against mask $40. If either byte already
; has that bit, A is 0 and this returns. Otherwise the mask is stored
; into $D125 and StageNameTextAndScript41C1 runs with A = $40.
;
; TrySetBitPairAtPlus14 and StageNameTextAndScript41C1 are already source.

SetD071TwoMarkBit40At4EB9::
    ld a, $02
    ld [$D071], a
    ld a, $40
    ld hl, $D110
    call TrySetBitPairAtPlus14
    and a
    ret z
    ld a, $40
    call StageNameTextAndScript41C1
    ret
