; CorfPearlAdjustD110. Bank 7 at $6C1C (file $01EC1C).
;
; Second pointer of CorfPearlIndexedRecord. RunPairIdScripts calls it
; from $CD93. AddACapByteAtBc adds $0F to the bytes at $D110+$0C ($D11C)
; and $D110+$0F ($D11F), capping each sum at $63. SubAFloorByteAtBc then
; subtracts $0F from the byte at $D110+$0B ($D11B), storing $01 on zero
; or underflow. What those bytes count is still unknown.

CorfPearlAdjustD110::
    ld hl, $D110
    ld bc, $000C
    ld e, $63
    ld a, $0F
    call AddACapByteAtBc
    ld hl, $D110
    ld bc, $000F
    ld e, $63
    ld a, $0F
    call AddACapByteAtBc
    ld hl, $D110
    ld bc, $000B
    ld a, $0F
    call SubAFloorByteAtBc
    ret
