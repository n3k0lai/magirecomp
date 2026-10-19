; Bank 2 at $4BD7. [$D071] is set to 2. A is bank $4C and BC is
; $4B79. StagePointerUnlessD0B6Matches returns immediately when
; [$D0B6] equals [$D103]; otherwise it plants that bank and pointer.
;
; TrySetBitPairAtPlus14 then tests the two bytes at $D110 + $14
; ($D124 and $D125) against mask $40. If either byte already has
; that bit, A is 0 and this returns. Otherwise the mask is stored
; into $D125 and StageNameTextAndScript41C1 runs with A = $40.

SetD071TwoStage4B79AndMarkBit40::
    ld a, $02
    ld [$D071], a
    ld a, $4C
    ld bc, $4B79
    call StagePointerUnlessD0B6Matches
    ld a, $40
    ld hl, $D110
    call TrySetBitPairAtPlus14
    and a
    ret z
    ld a, $40
    call StageNameTextAndScript41C1
    ret
