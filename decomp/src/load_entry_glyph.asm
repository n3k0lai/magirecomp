; Bank 4's $648D. DrawIndexedEntry stores the record id at $C9D8, then
; calls here. The id selects the glyph source that CopyGlyphBytes reads.
;
; An id at or above $F0 installs a fixed source: pointer $5B80, bank $45,
; and $05 at $C9B1. A lower id calls bank 4's $7029, which returns HL at
; record+$1E for the record at $415B + id*$2D. Eleven bytes past that
; return value are the source pointer, the ROM bank, and a byte whose
; low three bits are stored at $C9B1.
;
; wUnknownC9D8 is the name from indexed_tail_07.asm. wGlyphSrc is the
; name from draw_cgb_notice.asm. wCallbackBank is the name from
; default_state.asm. CallBankedHL is the name from call_hl_in_bank.asm.

; Id at or above this uses the fixed glyph source.
DEF GLYPH_ID_FIXED EQU $F0

; Fixed source used for those ids. Still INCBIN.
DEF FIXED_GLYPH_SRC EQU $5B80
DEF FIXED_GLYPH_BANK EQU $45
DEF FIXED_GLYPH_FIELD EQU $05

; Bank 4, still INCBIN. Multiplies the id by $2D, points HL at that
; record plus $1E, and returns.
DEF LookupEntryRecord EQU $7029
DEF BANK_ENTRY_RECORD EQU $04

; Bytes from the $7029 return value to the glyph pointer.
DEF GLYPH_FIELD_OFF EQU $000B

; Low three bits of the byte after the glyph bank. Role still unknown.
DEF wUnknownC9B1 EQU $C9B1

LoadEntryGlyphSource::
    ld a, [wUnknownC9D8]
    cp GLYPH_ID_FIXED
    jr c, .fromRecord

    ld hl, FIXED_GLYPH_SRC
    ld a, l
    ld [wGlyphSrc], a
    ld a, h
    ld [wGlyphSrc + 1], a
    ld a, FIXED_GLYPH_BANK
    ld [wCallbackBank], a
    ld a, FIXED_GLYPH_FIELD
    ld [wUnknownC9B1], a
    ret

.fromRecord:
    ld hl, LookupEntryRecord
    ld e, BANK_ENTRY_RECORD
    call CallBankedHL
    ld bc, GLYPH_FIELD_OFF
    add hl, bc
    ld a, [hl+]
    ld [wGlyphSrc], a
    ld a, [hl+]
    ld [wGlyphSrc + 1], a
    ld a, [hl+]
    ld [wCallbackBank], a
    ld a, [hl+]
    and $07
    ld [wUnknownC9B1], a
    ret
