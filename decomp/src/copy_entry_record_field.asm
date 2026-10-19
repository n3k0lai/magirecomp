; Bank 4's $6FC5. ApplyC9E4TableEntry calls this after TableWordForC9E4
; stores a pointer at wEntryRecordField ($C9DE/$C9DF). This loads that
; pointer, adds a zero offset (DE is saved and restored around the add),
; and copies the next seventeen record bytes into the $C9xx fields below.
; ROM bank 4 is already mapped; this routine does not touch rROMB0.
;
; wEntryRecordField and wEntryRecord are the names from record_ptr_from_id.asm.
; wUnknownC9D8 is the name from indexed_tail_07.asm. wUnknownC9DA and
; wUnknownC9DB are the names from dispatch_nonzero_d016.asm. The other
; destinations are still unnamed.

; Added to the pointer before the copy. The ROM's offset is zero.
DEF ENTRY_RECORD_COPY_OFFSET EQU $0000

CopyEntryRecordField::
    ld hl, wEntryRecordField
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push de
    ld de, ENTRY_RECORD_COPY_OFFSET
    add hl, de
    pop de
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
    ld [wUnknownC9DA], a
    ld a, [hl+]
    ld [wUnknownC9DB], a
    ld a, [hl+]
    ld [wUnknownC9D8], a
    ld a, [hl+]
    ld [wEntryRecord], a
    ld a, [hl+]
    ld [wEntryRecord + 1], a
    ld a, [hl+]
    ld [$C9D9], a
    ld a, [hl+]
    ld [$C9BE], a
    ld a, [hl+]
    ld [$C9BF], a
    ld a, [hl+]
    ld [$C9D5], a
    ld a, [hl+]
    ld [$C9D6], a
    ld a, [hl+]
    ld [$C9D7], a
    ret
