; Copy the 19-byte record for the id at $CD8C to the pointer at $CD8F.
;
; The id is multiplied by 19 and added to the table at $6916. Each record
; is three pointers followed by thirteen more bytes. RunPairIdScripts
; points $CD8F at $CD91 and then reads the second pointer from $CD93.
; CopyRecordByteBlocks uses the same copy and reads from $CD98, seven
; bytes into the record. wScriptId and wScriptBufPtr are the names from
; run_pair_id_scripts.asm. MulCByB is already source. The records stay
; INCBIN.

; Length of one record, and the stride used to index the table.
DEF INDEXED_RECORD_LEN EQU $13

CopyIndexedRecord::
    ld a, [wScriptId]
    ld c, a
    ld b, INDEXED_RECORD_LEN
    call MulCByB
    ld bc, BlankIndexedNameRecord
    add hl, bc
    ld a, [wScriptBufPtr + 1]
    ld b, a
    ld a, [wScriptBufPtr]
    ld c, a
    ld d, INDEXED_RECORD_LEN
.byte:
    ld a, [hl+]
    ld [bc], a
    inc bc
    dec d
    jr nz, .byte
    ret
