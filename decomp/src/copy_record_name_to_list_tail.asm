; CopyRecordNameToListTail. Bank 2 at $56C7.
;
; RunFlaggedMeasureScript and RunRankMeasureScript call this first when
; bit 1 of $D389 is set. HL is the record those callers already hold,
; usually $D110. The byte at record+2 is the indexed-name id.
;
; That id is stored at $CD8C and $CD8F is pointed at $C949. CopyIndexedName
; in bank 6 copies the ten-byte name there. $FC is stored at $C953, the
; byte after that name. HL is restored.
;
; CopyIndexedName and CallBankedHL are already source. wUnknownCD8C and
; wUnknownCD8F are the names from indexed_tail_07.asm. wListTailDest and
; LIST_TAIL_MARK are the names from setup_command_4d.asm. FIRST_NAME_MARK
; and COPY_INDEXED_NAME_BANK are the names from
; write_indexed_names_and_count.asm.

DEF RECORD_NAME_ID EQU $0002

CopyRecordNameToListTail::
    push hl
    ld bc, RECORD_NAME_ID
    add hl, bc
    ld a, [hl]
    ld [wUnknownCD8C], a
    ld bc, wListTailDest
    ld hl, wUnknownCD8F
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld hl, CopyIndexedName
    ld e, COPY_INDEXED_NAME_BANK
    call CallBankedHL
    ld a, LIST_TAIL_MARK
    ld [FIRST_NAME_MARK], a
    pop hl
    ret
