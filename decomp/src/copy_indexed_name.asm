; Copy the 10-byte name for the id at $CD8C to the pointer at $CD8F.
;
; Id $FF selects the ten spaces at $5A9C, the record just before the
; table. Any other id is multiplied by ten and added to $5AA6. Those
; records are fixed-width names (Abaquist, Agovo, and the rest). The
; destination is the word at $CD8F, low byte first. Ten bytes are copied.
;
; Callers store an id in $CD8C and point $CD8F at the buffer first.
; ScanGroupBytes does that for index $0B, with the buffer at $CD91.
; wUnknownCD8C and wUnknownCD8F are the names from indexed_tail_07.asm.
; MulCByB is already source. The name bytes stay INCBIN.

; Ten bytes, and the stride of each name record.
DEF INDEXED_NAME_LEN EQU $0A

; Ten spaces. Used when the id is $FF.
DEF BlankIndexedName EQU $5A9C

; First name. Record 0 is id 0.
DEF IndexedNameTable EQU $5AA6

CopyIndexedName::
    ld a, [wUnknownCD8C]
    ld b, a
    cp $FF
    jr nz, .scaled
    ld hl, BlankIndexedName
    jr .copy
.scaled:
    ld c, INDEXED_NAME_LEN
    call MulCByB
    ld bc, IndexedNameTable
    add hl, bc
.copy:
    ld a, [wUnknownCD8F + 1]
    ld b, a
    ld a, [wUnknownCD8F]
    ld c, a
    ld d, INDEXED_NAME_LEN
.byte:
    ld a, [hl+]
    ld [bc], a
    inc bc
    dec d
    jr nz, .byte
    ret
