; FlameAuraAdjustD110. Bank 7 at $6D3B (file $01ED3B).
;
; Second pointer of FlameAuraIndexedRecord. RunPairIdScripts calls it
; from $CD93. ORs $02 into the byte at $D122. AddACapByteAtBc then adds
; $0F to the bytes at $D110+$0C ($D11C) and $D110+$0B ($D11B), capping
; each sum at $63. SubAFloorByteAtBc subtracts $0F from the bytes at
; $D110+$0E ($D11E) and $D110+$0F ($D11F), storing $01 on zero or
; underflow. What those bytes count is still unknown.

FlameAuraAdjustD110::
    ld hl, $D122
    ld a, $02
    or [hl]
    ld [hl], a
    ld hl, $D110
    ld bc, $000C
    ld e, $63
    ld a, $0F
    call AddACapByteAtBc
    ld hl, $D110
    ld bc, $000B
    ld e, $63
    ld a, $0F
    call AddACapByteAtBc
    ld hl, $D110
    ld bc, $000E
    ld a, $0F
    call SubAFloorByteAtBc
    ld hl, $D110
    ld bc, $000F
    ld a, $0F
    call SubAFloorByteAtBc
    ret
