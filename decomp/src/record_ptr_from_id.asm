; Bank 4's $7029. The id at wUnknownC9D8 selects a $2D-byte record in the
; table at $415B, which is still INCBIN. HL returns that record plus $1E.
; $C9DC keeps the record base and $C9DE keeps the same pointer HL returns.
; wUnknownC9D8 is the name from indexed_tail_07.asm. MulCByB is already source.

; Bytes per record in the bank 4 table at $415B.
DEF ENTRY_RECORD_STRIDE EQU $2D

; Start of that table. Still INCBIN.
DEF ENTRY_RECORD_TABLE EQU $415B

; Offset from the record base to the pointer this routine returns.
DEF ENTRY_RECORD_FIELD EQU $001E

; Stored record base. Role of the following field is still unknown.
DEF wEntryRecord EQU $C9DC

; Stored copy of the returned pointer (record plus $1E).
DEF wEntryRecordField EQU $C9DE

RecordPtrFromId::
    ld a, [wUnknownC9D8]
    ld c, a
    ld b, ENTRY_RECORD_STRIDE
    call MulCByB
    ld bc, ENTRY_RECORD_TABLE
    add hl, bc
    ld a, l
    ld [wEntryRecord], a
    ld a, h
    ld [wEntryRecord + 1], a
    ld bc, ENTRY_RECORD_FIELD
    add hl, bc
    ld a, l
    ld [wEntryRecordField], a
    ld a, h
    ld [wEntryRecordField + 1], a
    ret
