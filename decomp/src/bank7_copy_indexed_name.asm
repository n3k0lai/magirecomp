; Bank 7 arg-table index 2. DispatchBank7Arg enters here with the
; index from $C9FD in E and bank 7 still mapped.
;
; HL is $A019 plus that index (sEntryScan). The pointer is saved, then
; the index times $13 selects a record at $691C, still INCBIN. The first
; $0D bytes of that record are a name. They are copied to $C949 and a
; $FC mark is stored after them, the same tail SetupCommand4D writes.
;
; HL is restored and control jumps to $743C, still INCBIN. That tail maps
; SRAM bank $C727, adds the byte at $C9FE to [HL], and saturates at $FF.
; An overflow stores 0 at $C9FD; otherwise it stores 1. SRAM is then
; disabled and that tail returns.
;
; sEntryScan is the name from indexed_tail_07.asm. wListTailDest,
; LIST_TAIL_LEN, and LIST_TAIL_MARK are the names from
; setup_command_4d.asm. MulCByB and CopyHLToDE are already source.

; $13-byte records. Only the leading name bytes are copied.
DEF NameRecordStride EQU $13
DEF NameRecordTable EQU $691C

Bank7CopyIndexedName::
    ld hl, sEntryScan
    add hl, de
    push hl
    ld b, e
    ld c, NameRecordStride
    call MulCByB
    ld bc, NameRecordTable
    add hl, bc
    ld bc, LIST_TAIL_LEN
    ld de, wListTailDest
    call CopyHLToDE
    ld a, LIST_TAIL_MARK
    ld [de], a
    pop hl
    jp AddByteToScanC

Bank7CopyIndexedNameEnd:
