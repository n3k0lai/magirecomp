; Bank 2 at $73DD. Opcode28 copies four script bytes to $D392 in WRAM
; bank 7, maps this bank, and jumps here.
;
; $762B, still INCBIN, runs first. Sixteen bytes are then copied from
; bank 5 at $5EFE to $D100 through CopyPtr16Bytes. The word at $D393
; (operand bytes 2 and 3) is stored at $CD8D and at $D107. $CD8F is
; pointed at $CD91. CopyGroupBytes in bank 7 copies $22 bytes from that
; word to $CD91. Byte 4 of that copy is stored at $D102 and byte 5 at
; $D103. $D0B1 is set to $09.
;
; DispatchIfD0E0AboveD102 then runs in bank 5. A zero byte at $D0AF
; returns. Any other value calls StoreD0D9AfterLowD103 and returns.
;
; CopyPtr16Bytes, CopyGroupBytes, DispatchIfD0E0AboveD102,
; StoreD0D9AfterLowD103, and CallBankedHL are already source. $762B
; and the sixteen bytes at $5EFE are still INCBIN.

Load5EFERecordThenGroupDispatch::
    call $762B
    ld bc, $5EFE
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
    ld hl, $D393
    ld a, [hl+]
    ld b, [hl]
    ld c, a
    ld hl, $CD8D
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld hl, $D107
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld bc, $CD91
    ld hl, $CD8F
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld hl, CopyGroupBytes
    ld e, $07
    call CallBankedHL
    ld hl, $CD91
    ld bc, $0005
    add hl, bc
    ld a, [hl]
    ld [$D103], a
    ld hl, $CD91
    ld bc, $0004
    add hl, bc
    ld a, [hl]
    ld [$D102], a
    ld a, $09
    ld [$D0B1], a
    ld hl, DispatchIfD0E0AboveD102
    ld e, $05
    call CallBankedHL
    ld a, [$D0AF]
    and a
    ret z

    call StoreD0D9AfterLowD103
    ret
