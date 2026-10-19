; Bank 2 at $4BF4. [$D071] is set to 2. A is bank $4C and BC is
; $4D35. StagePointerUnlessD0B6Matches returns immediately when
; [$D0B6] equals [$D103]; otherwise it plants that bank and pointer.
;
; CallBankedHL then maps bank 7 and calls $66D2. That routine is still
; INCBIN. Its file address is $01E6D2. StagePointerUnlessD0B6Matches
; and CallBankedHL are already source.

SetD071TwoStage4D35CallBank7::
    ld a, $02
    ld [$D071], a
    ld a, $4C
    ld bc, $4D35
    call StagePointerUnlessD0B6Matches
    ld hl, $66D2
    ld e, $07
    call CallBankedHL
    ret
