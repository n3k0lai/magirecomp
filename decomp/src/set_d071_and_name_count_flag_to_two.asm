; Bank 2 at $51C2. InitWram7BeforeReset stores this address at $D35D
; and again at $D16E. FinishOpcode2D stores it at $D100.
;
; [$D071] is set to 2, then [$D076] (wNameCountFlag) is set to 2, then
; [$D071] is set to 2 again. A nonzero wNameCountFlag makes
; WriteIndexedNamesAndCount print [$D077] (wNameCountAlt). This routine
; does not change that count. wNameCountFlag is the name from
; write_indexed_names_and_count.asm.

SetD071AndNameCountFlagToTwo::
    ld a, $02
    ld [$D071], a
    ld a, $02
    ld [$D076], a
    ld a, $02
    ld [$D071], a
    ret
