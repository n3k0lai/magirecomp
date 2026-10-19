; Reads one script byte as a slot index, doubles it, and returns the word
; at that offset in RecordSlotBases. BC moves past the index.
;
; `add a` keeps only the low eight bits of the doubled index. D is then
; cleared, so an index of $80 or more wraps inside the table. The fifty
; known slots fit in one byte.
;
; LookupIndexedPointer in opcode_03.asm is this address. The callers still
; in INCBIN use the same entry.

LookupScriptIndexPointer::
    ld a, [bc]
    inc bc
    add a
    ld e, a
    ld d, $00
    ld hl, RecordSlotBases
    add hl, de
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ret
