; Bank 2 at $73AC. Opcode26 copies four script bytes to $D392 in WRAM
; bank 7, maps this bank, and jumps here.
;
; $762B, still INCBIN, runs first. The word at $D393 (operand bytes 2
; and 3) is stored at $CD8D. $CD8F is pointed at $D100. CopyPtr16Bytes
; in bank 5 copies 16 bytes from that word to $D100. The extra `inc bc`
; after the second store is overwritten by `ld bc, $D100`.
;
; DispatchIfD0E0AboveD102 then runs in bank 5. A zero byte at $D0AF
; returns. Any other value calls $7607, still INCBIN, and returns.
;
; CopyPtr16Bytes, DispatchIfD0E0AboveD102, and CallBankedHL are already
; source. $762B and $7607 are still INCBIN.

CopyD393RecordThenDispatch::
    call $762B
    ld bc, $D393
    ld hl, $CD8D
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld bc, $D100
    ld hl, $CD8F
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld hl, CopyPtr16Bytes
    ld e, $05
    call CallBankedHL
    ld hl, DispatchIfD0E0AboveD102
    ld e, $05
    call CallBankedHL
    ld a, [$D0AF]
    and a
    ret z

    call $7607
    ret
