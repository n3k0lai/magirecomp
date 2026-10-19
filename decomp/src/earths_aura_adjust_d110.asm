; EarthsAuraAdjustD110. Bank 7 at $6C80 (file $01EC80).
;
; Second pointer of EarthsAuraIndexedRecord. RunPairIdScripts calls it
; from $CD93. ORs $01 into the byte at $D122. AddACapByteAtBc then adds
; $0F to the bytes at $D110+$0F ($D11F) and $D110+$0E ($D11E), capping
; each sum at $63. SubAFloorByteAtBc subtracts $19 from the byte at
; $D110+$0D ($D11D), storing $01 on zero or underflow. What those bytes
; count is still unknown.

EarthsAuraAdjustD110::
    ld hl, $D122
    ld a, $01
    or [hl]
    ld [hl], a
    ld hl, $D110
    ld bc, $000F
    ld e, $63
    ld a, $0F
    call AddACapByteAtBc
    ld hl, $D110
    ld bc, $000E
    ld e, $63
    ld a, $0F
    call AddACapByteAtBc
    ld hl, $D110
    ld bc, $000D
    ld a, $19
    call SubAFloorByteAtBc
    ret
