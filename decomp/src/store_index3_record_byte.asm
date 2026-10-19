; Bank 7 arg-table index 3. DispatchBank7Arg enters here with the index
; from $C9FD in E and D cleared. Bank 7 stays mapped.
;
; The index selects one $22-byte record at $7001, still INCBIN. The first
; $0D bytes are copied to $C949 and a $FC mark is stored after them, the
; same tail SetupCommand4D writes.
;
; CopyHLToDE leaves HL one past that span. Stepping back $0D + $08 lands
; on the ROM byte eight before the name. SRAM bank wSRAMBank is enabled
; and that byte is stored at $A5A5 + index. SRAM is then disabled and
; $C9FD is set to 1. `add a, $00` keeps the RAM-bank byte. Nothing reads
; those flags.
;
; GROUP_BYTE_COUNT is the name from copy_group_bytes.asm. wListTailDest,
; LIST_TAIL_LEN, and LIST_TAIL_MARK are the names from
; setup_command_4d.asm. wBank7ArgC9FC is the name from
; copy_three_c9fc_bank7.asm. rRAMB, wSRAMBank, and SRAM_ENABLE are the
; names from handle_start_press.asm. rRAMG is the name from reset.asm.
; MulCByB and CopyHLToDE are already source. IndexedSetup stores $A5A5
; at wGroupSRAM for selector $03.

; Still INCBIN. $22-byte records. Only the leading name bytes are copied.
DEF Index3RecordTable EQU $7001

; One SRAM byte per index. IndexedSetup uses this base for selector $03.
DEF Index3SRAMOrigin EQU $A5A5

; Field sits this far before the name span CopyHLToDE just walked.
DEF INDEX3_BYTE_BEFORE_NAME EQU $08

StoreIndex3RecordByte::
    ld hl, Index3SRAMOrigin
    add hl, de
    push hl
    ld b, e
    ld c, GROUP_BYTE_COUNT
    call MulCByB
    ld bc, Index3RecordTable
    add hl, bc
    ld bc, LIST_TAIL_LEN
    ld de, wListTailDest
    call CopyHLToDE
    ld a, LIST_TAIL_MARK
    ld [de], a
    ld bc, -(LIST_TAIL_LEN + INDEX3_BYTE_BEFORE_NAME)
    add hl, bc
    ld a, [wSRAMBank]
    add a, $00
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld a, [hl]
    pop hl
    ld [hl], a
    xor a
    ld [rRAMG], a
    ld a, $01
    ld [wBank7ArgC9FC + 1], a
    ret
