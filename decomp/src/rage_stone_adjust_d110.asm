; RageStoneAdjustD110. Bank 7 at $6E80 (file $01EE80).
;
; Second pointer of RageStoneIndexedRecord. RunPairIdScripts calls it
; from $CD93. AddACapByteAtBc adds $02 to the byte at $D110+$0B ($D11B)
; and $02 at $D110+$0D ($D11D), capping each sum at $63. What those
; bytes count is still unknown.

RageStoneAdjustD110::
    ld hl, $D110
    ld bc, $000B
    ld e, $63
    ld a, $02
    call AddACapByteAtBc
    ld hl, $D110
    ld bc, $000D
    ld e, $63
    ld a, $02
    call AddACapByteAtBc
    ret
