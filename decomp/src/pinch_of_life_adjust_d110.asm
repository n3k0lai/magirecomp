; PinchOfLifeAdjustD110. Bank 7 at $6E40 (file $01EE40).
;
; Second pointer of PinchOfLifeIndexedRecord. RunPairIdScripts calls it
; from $CD93. $10 is ORed into $D122. The word at $D119 is stored high
; byte first. This adds $000F, writes the sum back to $D119, and copies
; that same word to $D117. AddACapByteAtBc adds $0F to the byte at
; $D110+$0E ($D11E) and caps the sum at $63. SubAFloorByteAtBc subtracts
; $0F from the byte at $D110+$0B ($D11B) and floors a zero or underflow
; at $01. What those bytes and words count is still unknown.

PinchOfLifeAdjustD110::
    ld hl, $D122
    ld a, $10
    or [hl]
    ld [hl], a
    ld a, [$D119]
    ld h, a
    ld a, [$D11A]
    ld l, a
    ld c, $0F
    ld b, $00
    add hl, bc
    ld a, h
    ld [$D119], a
    ld [$D117], a
    ld a, l
    ld [$D11A], a
    ld [$D118], a
    ld hl, $D110
    ld bc, $000E
    ld e, $63
    ld a, $0F
    call AddACapByteAtBc
    ld hl, $D110
    ld bc, $000B
    ld a, $0F
    call SubAFloorByteAtBc
    ret
