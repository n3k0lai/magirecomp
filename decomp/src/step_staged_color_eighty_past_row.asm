; Bank 7 at $48FD. StepStagedColorAndCopyC7DB calls this after it has
; copied wEntryRecord into $C830, the repeat count StepColorWords reads,
; and stored $61 at wUnknownC9D8. The staged color word is at
; wUnknownC9DA.
;
; $C831 is cleared. PanelRowFromHighNibble returns HL = $C72B plus eight
; times the high nibble of wUnknownC9D8. HL is then moved $80 bytes past
; that row. PanelQuadFromLowNibble returns the low byte of four times one
; more than the low nibble; that byte is the word count in BC, with B
; cleared. DE is the little-endian word at wUnknownC9DA, the step
; StepColorWords applies to each word at HL. $C831 is set to $01 before
; the return.
;
; wUnknownC9D8 is the name from indexed_tail_07.asm. wUnknownC9DA and
; wUnknownC9DB are the names from dispatch_nonzero_d016.asm. wEntryRecord
; is the name from record_ptr_from_id.asm. $C830, $C831, and $C72B are
; still unnamed.

StepStagedColorEightyPastRow::
    xor a
    ld [$C831], a
    call PanelRowFromHighNibble
    ld bc, $0080
    add hl, bc
    call PanelQuadFromLowNibble
    ld b, $00
    ld c, a
    ld a, [wUnknownC9DB]
    ld d, a
    ld a, [wUnknownC9DA]
    ld e, a
    call StepColorWords
    ld a, $01
    ld [$C831], a
    ret
