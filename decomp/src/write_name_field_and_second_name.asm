; Bank 5 at $5657. Called on the $D0B6 path before the five-byte script
; is written at $C71B. The caller then plants $49 $C9 at $C93D so that
; word points at the text built here.
;
; [$D0DB] is stored at $CD8C and $CD8F is pointed at $C949. CopyIndexedName
; in bank 6 copies that id's ten-byte name there. $FC is stored at $C953.
;
; The seven bytes at $D109 are copied to $C954. If the last of those,
; now at $C95A, is $0C, it is replaced with a space ($20). $FC follows
; at $C95B.
;
; [$D112] is copied the same way to $C95C, and $FC is stored at $C966.
;
; CopyIndexedName and CallBankedHL are already source. wUnknownCD8C and
; wUnknownCD8F are the names from indexed_tail_07.asm. wListTailDest and
; LIST_TAIL_MARK are the names from setup_command_4d.asm. NAME_ID_SRC,
; wSecondNameId, FIRST_NAME_MARK, and COPY_INDEXED_NAME_BANK are the
; names from write_indexed_names_and_count.asm.

DEF FIELD_BYTES EQU $D109
DEF FIELD_LEN EQU $07
DEF FIELD_DEST EQU $C954
DEF FIELD_LAST EQU $C95A
DEF FIELD_CTRL EQU $0C
DEF FIELD_SPACE EQU $20
DEF FIELD_MARK EQU $C95B
DEF TRAILING_NAME_DEST EQU $C95C
DEF TRAILING_NAME_MARK EQU $C966

WriteNameFieldAndSecondName::
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
    ld hl, FIELD_BYTES
    ld bc, FIELD_DEST
    ld d, FIELD_LEN
.copyField:
    ld a, [hl+]
    ld [bc], a
    inc bc
    dec d
    jr nz, .copyField
    ld a, [FIELD_LAST]
    cp FIELD_CTRL
    jr nz, .markField
    ld a, FIELD_SPACE
    ld [FIELD_LAST], a
.markField:
    ld a, LIST_TAIL_MARK
    ld [FIELD_MARK], a
    ld a, [wSecondNameId]
    ld [wUnknownCD8C], a
    ld bc, TRAILING_NAME_DEST
    ld hl, wUnknownCD8F
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld hl, CopyIndexedName
    ld e, COPY_INDEXED_NAME_BANK
    call CallBankedHL
    ld a, LIST_TAIL_MARK
    ld [TRAILING_NAME_MARK], a
    ret
