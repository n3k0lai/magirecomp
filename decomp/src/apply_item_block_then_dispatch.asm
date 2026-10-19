; Bank 2 at $7595. Opcode2F copies four script bytes to $D392, maps
; this bank, and jumps here.
;
; $762B copies the $37-byte record selected by [$D392] into $D0D9.
; The 16-byte block at $5EDE in bank 5 (its text is "Item") is stored
; at wGroupScaled, with wGroupListPtr aimed at $D100. CopyPtr16Bytes
; copies those 16 bytes to $D100.
;
; The word at $D393 (script bytes 1 and 2) is written to wGroupScaled
; and to $D107. wGroupListPtr is aimed at wGroupList0B. CopyGroupBytes
; in bank 7 copies $22 bytes from that word onto the list.
;
; List byte 5 becomes [$D103] and list byte 4 becomes [$D102].
; DispatchIfD0E0AboveD102 runs in bank 5. A zero [$D0AF] returns.
; Otherwise StoreD0D9AfterLowD103 copies the $D0D9 record into the
; [$D392] slot.
;
; CopyPtr16Bytes, CallBankedHL, CopyGroupBytes,
; DispatchIfD0E0AboveD102, and StoreD0D9AfterLowD103 are already
; source. $762B is still INCBIN. wGroupScaled, wGroupListPtr, and
; wGroupList0B are the names from scan_group_bytes.asm.

ApplyItemBlockThenDispatch::
    call $762B
    ld bc, $5EDE
    ld hl, wGroupScaled
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld bc, $D100
    ld hl, wGroupListPtr
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
    ld hl, wGroupScaled
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld hl, $D107
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld bc, wGroupList0B
    ld hl, wGroupListPtr
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld hl, CopyGroupBytes
    ld e, $07
    call CallBankedHL
    ld hl, wGroupList0B
    ld bc, $0005
    add hl, bc
    ld a, [hl]
    ld [$D103], a
    ld hl, wGroupList0B
    ld bc, $0004
    add hl, bc
    ld a, [hl]
    ld [$D102], a
    ld hl, DispatchIfD0E0AboveD102
    ld e, $05
    call CallBankedHL
    ld a, [$D0AF]
    and a
    ret z
    call StoreD0D9AfterLowD103
    ret
