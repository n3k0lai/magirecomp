; Bank 7 at $5C00. StageColorWordThenCall5C00 maps this bank and calls
; here after the script color word is at wUnknownC9DA and wEntryRecord
; is $01.
;
; $C831 is cleared. wEntryRecord ($C9DC) is copied to $C830, the repeat
; count the color steppers read. $61 is stored at wUnknownC9D8. $48FD,
; still INCBIN, then steps that staged color word. The little-endian
; word at $C7DB is copied to $C9E5 (low) and $C9E6 (high). $5CE2, still
; INCBIN, writes that pair into the $C7AB slots. $C831 is set to $01
; before the return.
;
; wEntryRecord is the name from record_ptr_from_id.asm. wUnknownC9D8 is
; the name from indexed_tail_07.asm. wUnknownC9DA is the name from
; dispatch_nonzero_d016.asm. $C830, $C831, $C7DB, $C9E5, and $C9E6 are
; still unnamed. $48FD is file address $01C8FD. $5CE2 is file address
; $01DCE2.

; Little-endian word copied into $C9E5 before that write.
DEF WordAtC7DB EQU $C7DB

StepStagedColorAndCopyC7DB::
    xor a
    ld [$C831], a
    ld a, [wEntryRecord]
    ld [$C830], a
    ld a, $61
    ld [wUnknownC9D8], a
    call StepStagedColorEightyPastRow
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
