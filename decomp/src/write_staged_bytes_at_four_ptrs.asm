; Writes one staged byte through each of four little-endian pointers at
; $C836, $C838, $C83A, and $C83C. rVBK is 0 for the tile byte at $C83E and
; 1 for the attribute byte at $C83F, both with the 3-byte store. The first
; three pointers are walked by pushing HL, following the word, and popping
; it back so the next word is two bytes later. The fourth follow leaves HL
; on that destination.
;
; The tail stores IdleCallback ($29A4) at wCallback, the same pair the
; default-state path writes. wCallback and IdleCallback are the names from
; default_state.asm. rVBK is the name from setup_window.asm. The four
; pointers and the two staged bytes are still unnamed.

DEF StagedPtrTable EQU $C836
DEF StagedTileByte EQU $C83E
DEF StagedAttrByte EQU $C83F

WriteStagedBytesAtFourPtrs:
    xor a
    ld [rVBK], a
    ld hl, StagedPtrTable
    push hl
    ld a, [hli]
    ld h, [hl]
    ld l, a
    ld a, [StagedTileByte]
    ld [hl], a
    pop hl
    inc hl
    inc hl
    push hl
    ld a, [hli]
    ld h, [hl]
    ld l, a
    ld a, [StagedTileByte]
    ld [hl], a
    pop hl
    inc hl
    inc hl
    push hl
    ld a, [hli]
    ld h, [hl]
    ld l, a
    ld a, [StagedTileByte]
    ld [hl], a
    pop hl
    inc hl
    inc hl
    ld a, [hli]
    ld h, [hl]
    ld l, a
    ld a, [StagedTileByte]
    ld [hl], a
    ld a, $01
    ld [rVBK], a
    ld hl, StagedPtrTable
    push hl
    ld a, [hli]
    ld h, [hl]
    ld l, a
    ld a, [StagedAttrByte]
    ld [hl], a
    pop hl
    inc hl
    inc hl
    push hl
    ld a, [hli]
    ld h, [hl]
    ld l, a
    ld a, [StagedAttrByte]
    ld [hl], a
    pop hl
    inc hl
    inc hl
    push hl
    ld a, [hli]
    ld h, [hl]
    ld l, a
    ld a, [StagedAttrByte]
    ld [hl], a
    pop hl
    inc hl
    inc hl
    ld a, [hli]
    ld h, [hl]
    ld l, a
    ld a, [StagedAttrByte]
    ld [hl], a
    ld a, LOW(IdleCallback)
    ld [wCallback], a
    ld a, HIGH(IdleCallback)
    ld [wCallback + 1], a
    ret
