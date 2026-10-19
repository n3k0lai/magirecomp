; Bank 5 at $55E0. CopyD107GroupThenScript446D calls this through
; CallBankedHL, then points $C93D at $C949 so that word reads the text
; built here.
;
; [$D0DB] is stored at $CD8C and $CD8F is pointed at $C949. CopyIndexedName
; in bank 6 copies that id's ten-byte name there. $FC is stored at $C953.
; Thirteen bytes are copied from $CD9D onto $C954, and $FC follows them.
;
; CopyIndexedName and CallBankedHL are already source. wUnknownCD8C and
; wUnknownCD8F are the names from indexed_tail_07.asm. wListTailDest and
; LIST_TAIL_MARK are the names from setup_command_4d.asm. NAME_ID_SRC,
; FIRST_NAME_MARK, SECOND_NAME_BUF, and COPY_INDEXED_NAME_BANK are the
; names from write_indexed_names_and_count.asm.

; Thirteen-byte list filled for indexes other than 6 and $0B. ScanGroupBytes
; copies this same span as tiles. What each byte means is still unknown.
DEF wOtherListBytes EQU $CD9D
DEF OTHER_LIST_BYTES EQU $0D

CopyIndexedNameThenOtherList::
    ld a, [NAME_ID_SRC]
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
    ld bc, SECOND_NAME_BUF
    ld hl, wOtherListBytes
    ld d, OTHER_LIST_BYTES
.copyByte:
    ld a, [hl+]
    ld [bc], a
    inc bc
    dec d
    jr nz, .copyByte
    ld a, LIST_TAIL_MARK
    ld [bc], a
    ret
