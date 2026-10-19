; Bank 2 at $748B. FinishOpcode2D clears $D0D8 and calls here.
;
; $762B, still INCBIN, copies the $37-byte record selected by [$D392]
; into $D0D9 and stores $FF at $D0B1. The pointer pair at $CD8D/$CD8F
; then hands CopyPtr16Bytes the bank 5 block at $5ECE (the 16 bytes
; contain the text "SummonX") and the destination $D100.
;
; $D0B1 becomes $89 ($09 with bit 7 set). $D103 is $0C. [$D395] is
; copied to $D102. DispatchIfD0E0AboveD102 runs in bank 5. A zero
; [$D0AF] returns; that call is what can clear $D0AF or set $D0D8.
;
; Otherwise three bytes at $D393 are copied to $D068. The four bytes at
; $D082 are added into $D096. The scan starts at the second sum byte
; with slot 6 in E. The first zero stores 6, 7, or 8 at $D103. If the
; next three sums are all nonzero, $D103 is 5. Those four bytes are
; then subtracted back out. The record at $D0D9 is written to the
; [$D392] slot. $D0C0 is 1 and $D0C1 is the chosen slot, so
; PlantSlot11WhenD0C0IsOne plants that slot.
;
; CopyPtr16Bytes, CallBankedHL, DispatchIfD0E0AboveD102,
; IndexTimes37PlusD147, Copy37ByteRecord, and
; PlantSlot11WhenD0C0IsOne are already source. $762B is still INCBIN.

ApplySummonXRecordThenPickSlot::
    call $762B
    ld bc, $5ECE
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
    ld a, $09
    set 7, a
    ld [$D0B1], a
    ld a, $0C
    ld [$D103], a
    ld a, [$D395]
    ld [$D102], a
    ld hl, DispatchIfD0E0AboveD102
    ld e, $05
    call CallBankedHL
    ld a, [$D0AF]
    and a
    ret z
    ld bc, $D068
    ld hl, $D393
    ld a, [hl+]
    ld [bc], a
    inc bc
    ld a, [hl+]
    ld [bc], a
    inc bc
    ld a, [hl+]
    ld [bc], a
    inc bc
    ld hl, $D096
    ld bc, $D082
    ld d, $04

.addD082:
    ld a, [bc]
    inc bc
    add [hl]
    ld [hl+], a
    dec d
    jr nz, .addD082

    ld hl, $D097
    ld e, $06

.scanSum:
    ld a, [hl+]
    and a
    jr z, .storeSlot
    inc e
    ld a, e
    cp $09
    jr z, .slotFive
    jr .scanSum

.slotFive:
    ld e, $05

.storeSlot:
    ld a, e
    ld [$D103], a
    ld hl, $D096
    ld bc, $D082
    ld d, $04

.subD082:
    ld a, [bc]
    inc bc
    ld e, a
    ld a, [hl]
    sub e
    ld [hl+], a
    dec d
    jr nz, .subD082

    ld a, [$D392]
    call IndexTimes37PlusD147
    ld bc, $D0D9
    call Copy37ByteRecord
    ld a, [$D103]
    ld [$D0C1], a
    ld a, $01
    ld [$D0C0], a
    ld hl, PlantSlot11WhenD0C0IsOne
    ld e, $05
    call CallBankedHL
    ret
