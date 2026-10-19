; Bank 2 at $744A. Opcode2A copies one script byte to $D392 in WRAM
; bank 7, maps this bank, and jumps here.
;
; $762B, still INCBIN, runs first. Sixteen bytes are then copied from
; bank 5 at $5F0E (its text is "Focus") to $D100 through CopyPtr16Bytes.
; The operand at $D392 is stored at $D103 and used as a record index.
; IndexTimes37PlusD147 points HL at $D147 + index * $37. Copy37ByteRecord
; copies the $37 bytes at $D0D9 into that slot and this returns.
;
; CopyPtr16Bytes, CallBankedHL, IndexTimes37PlusD147, and
; Copy37ByteRecord are already source. $762B and the sixteen bytes at
; $5F0E are still INCBIN.

PlantFocusThenCopyD0D9ByOperand::
    call $762B
    ld bc, $5F0E
    ld hl, $CD8D
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld bc, $D100
    ld hl, $CD8F
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld hl, CopyPtr16Bytes
    ld e, $05
    call CallBankedHL
    ld a, [$D392]
    ld [$D103], a
    call IndexTimes37PlusD147
    ld bc, $D0D9
    call Copy37ByteRecord
    ret
