; Bank 7 at $5C29. Call5C29AfterCountdown maps this bank and calls
; here after it has stored $01 at wEntryRecord.
;
; $C831 is cleared. wEntryRecord ($C9DC) is copied to $C830, the repeat
; count the color steppers read. $61 is stored at wUnknownC9D8, the
; panel index ApplyPanelRowWords reads. That routine walks the row and
; returns. The little-endian word at $C7DB is copied to $C9E5 (low) and
; $C9E6 (high). WriteC9E5WordAtC7ABSlots writes that pair into the
; $C7AB slots. $C831 is set to $01 before the return.
;
; wEntryRecord is the name from record_ptr_from_id.asm. wUnknownC9D8 is
; the name from indexed_tail_07.asm. ApplyPanelRowWords is bank 7 at
; $489D. WriteC9E5WordAtC7ABSlots is bank 7 at $5CE2. WordAtC7DB is the
; name from step_staged_color_and_copy_c7db.asm. $C830, $C831, $C9E5,
; and $C9E6 are still unnamed.

ApplyPanelRowAndCopyC7DB::
    xor a
    ld [$C831], a
    ld a, [wEntryRecord]
    ld [$C830], a
    ld a, $61
    ld [wUnknownC9D8], a
    call ApplyPanelRowWords
    ld hl, WordAtC7DB
    ld a, [hl+]
    ld b, [hl]
    ld c, a
    ld a, b
    ld [$C9E6], a
    ld a, c
    ld [$C9E5], a
    call WriteC9E5WordAtC7ABSlots
    ld a, $01
    ld [$C831], a
    ret
