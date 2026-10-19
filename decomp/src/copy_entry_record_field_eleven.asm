; Bank 4's $7069. PresentEntryRecordByPanelSlot calls this after
; RecordPtrFromId stores a pointer at wEntryRecordField ($C9DE/$C9DF).
; This loads that pointer and copies the next eleven record bytes into
; $C9CD–$C9D7. ROM bank 4 is already mapped; this routine does not touch
; rROMB0.
;
; wEntryRecordField is the name from record_ptr_from_id.asm. The eleven
; destinations are still unnamed.

CopyEntryRecordFieldEleven::
    ld a, [wEntryRecordField + 1]
    ld h, a
    ld a, [wEntryRecordField]
    ld l, a
    ld a, [hl+]
    ld [$C9CD], a
    ld a, [hl+]
    ld [$C9CE], a
    ld a, [hl+]
    ld [$C9CF], a
    ld a, [hl+]
    ld [$C9D0], a
    ld a, [hl+]
    ld [$C9D1], a
    ld a, [hl+]
    ld [$C9D2], a
    ld a, [hl+]
    ld [$C9D3], a
    ld a, [hl+]
    ld [$C9D4], a
    ld a, [hl+]
    ld [$C9D5], a
    ld a, [hl+]
    ld [$C9D6], a
    ld a, [hl+]
    ld [$C9D7], a
    ret
