; Bank 4 at $64C9. PlantIndexedPanelCallback maps bank 4, calls
; LoadSelectedPanelByte (which copies the selected panel byte into
; wUnknownC9D8), then calls here.
;
; An id at or above $F0 stores $05 at wUnknownC9B1 and returns. A lower
; id calls bank 4's $7029, which returns HL at record+$1E. Three bytes
; past the glyph pointer at that return value (the same byte
; LoadEntryGlyphSource masks) are loaded with the following byte into
; HL. Only the low three bits of the first of those bytes are stored at
; wUnknownC9B1. HL still holds the word on return; the caller at $32A2
; does not read it. Bank 4 stays mapped.
;
; GLYPH_ID_FIXED, FIXED_GLYPH_FIELD, LookupEntryRecord, BANK_ENTRY_RECORD,
; GLYPH_FIELD_OFF, and wUnknownC9B1 are the names from
; load_entry_glyph.asm. wUnknownC9D8 is the name from
; indexed_tail_07.asm. CallBankedHL is the name from call_hl_in_bank.asm.

LoadSelectedEntryBits::
    ld a, [wUnknownC9D8]
    cp GLYPH_ID_FIXED
    jr c, .fromRecord
    ld a, FIXED_GLYPH_FIELD
    ld [wUnknownC9B1], a
    ret

.fromRecord:
    ld hl, LookupEntryRecord
    ld e, BANK_ENTRY_RECORD
    call CallBankedHL
    ld bc, GLYPH_FIELD_OFF + 3
    add hl, bc
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    and $07
    ld [wUnknownC9B1], a
    ret
