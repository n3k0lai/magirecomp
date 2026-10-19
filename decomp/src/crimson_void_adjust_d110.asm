; CrimsonVoidAdjustD110. Bank 7 at $6C42 (file $01EC42).
;
; Second pointer of CrimsonVoidIndexedRecord. RunPairIdScripts calls it
; from $CD93. AddACapByteAtBc adds $06 to the bytes at $D110+$0B ($D11B)
; and $D110+$0C ($D11C), and adds $14 to the byte at $D110+$10 ($D120),
; capping each sum at $63. SubAFloorByteAtBc then subtracts $0A from the
; bytes at $D110+$0E ($D11E) and $D110+$0F ($D11F), storing $01 on zero
; or underflow. What those bytes count is still unknown.

CrimsonVoidAdjustD110::
    ld hl, $D110
    ld bc, $000B
    ld e, $63
    ld a, $06
    call AddACapByteAtBc
    ld hl, $D110
    ld bc, $000C
    ld e, $63
    ld a, $06
    call AddACapByteAtBc
    ld hl, $D110
    ld bc, $0010
    ld e, $63
    ld a, $14
    call AddACapByteAtBc
    ld hl, $D110
    ld bc, $000E
    ld a, $0A
    call SubAFloorByteAtBc
    ld hl, $D110
    ld bc, $000F
    ld a, $0A
    call SubAFloorByteAtBc
    ret
