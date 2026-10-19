; WaterOrbAdjustD110. Bank 7 at $6F73 (file $01EF73).
;
; Second pointer of WaterOrbIndexedRecord. RunPairIdScripts calls it
; from $CD93. ORs $08 into $D122 and $04 into $D126. AddACapByteAtBc
; then adds $05 to the bytes at $D110+$0E ($D11E), +$0B ($D11B),
; +$0C ($D11C), and +$0F ($D11F), capping each sum at $63.
; SubAFloorByteAtBc subtracts $05 from the byte at $D110+$0D ($D11D),
; storing $01 on zero or underflow. What those bytes count is still
; unknown.

WaterOrbAdjustD110::
    ld hl, $D122
    ld a, $08
    or [hl]
    ld [hl], a
    ld hl, $D126
    ld a, $04
    or [hl]
    ld [hl], a
    ld hl, $D110
    ld bc, $000E
    ld e, $63
    ld a, $05
    call AddACapByteAtBc
    ld hl, $D110
    ld bc, $000B
    ld e, $63
    ld a, $05
    call AddACapByteAtBc
    ld hl, $D110
    ld bc, $000C
    ld e, $63
    ld a, $05
    call AddACapByteAtBc
    ld hl, $D110
    ld bc, $000F
    ld e, $63
    ld a, $05
    call AddACapByteAtBc
    ld hl, $D110
    ld bc, $000D
    ld a, $05
    call SubAFloorByteAtBc
    ret
