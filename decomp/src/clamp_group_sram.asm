; Bank 7 arg-table index 0. DispatchBank7Arg enters here with the index
; from $C9FD in E and D cleared. $C9FE is the addend.
;
; The index selects one $22-byte record. Thirteen bytes of that record,
; the same span SetupCommand4D copies from wGroupListOther, are written
; at $C949 with a $FC byte after them. The cap is the byte six before
; that span. Both the tails and the caps stay INCBIN.
;
; SRAM[$A3A7 + index] is the live count. ScanGroupBytes names $A3A7 as
; one base stored at wGroupSRAM. If the count already equals the cap,
; $C9FD is left 0 and SRAM is disabled. Otherwise the count becomes
; min(count + $C9FE, cap), overflow clamps to the cap, and $C9FD is set
; to 1. `add a, $00` keeps the RAM-bank byte. Nothing reads those flags.
;
; wBank7ArgC9FC is the name from copy_three_c9fc_bank7.asm. GROUP_BYTE_COUNT
; is the name from copy_group_bytes.asm. wListTailDest, LIST_TAIL_LEN, and
; LIST_TAIL_MARK are the names from setup_command_4d.asm. rRAMB, wSRAMBank,
; and SRAM_ENABLE are the names from handle_start_press.asm. rRAMG is the
; name from reset.asm. MulCByB and CopyHLToDE are already source.

; One SRAM byte per index. Also passed to ScanGroupBytes.
DEF GroupSRAMOrigin EQU $A3A7

; First 13-byte tail. Index times GROUP_BYTE_COUNT, still in this bank.
DEF GroupTailTable EQU $5E0B

; Cap sits this far before the tail that CopyHLToDE just walked.
DEF GROUP_CAP_BEFORE_TAIL EQU $06

ClampGroupSRAMByte::
    ld hl, GroupSRAMOrigin
    add hl, de
    push hl
    ld b, e
    ld c, GROUP_BYTE_COUNT
    call MulCByB
    ld bc, GroupTailTable
    add hl, bc
    ld bc, LIST_TAIL_LEN
    ld de, wListTailDest
    call CopyHLToDE
    ld a, LIST_TAIL_MARK
    ld [de], a
    ld bc, -(LIST_TAIL_LEN + GROUP_CAP_BEFORE_TAIL)
    add hl, bc
    ld a, [hl]
    ld b, a
    xor a
    ld [wBank7ArgC9FC + 1], a
    ld a, [wSRAMBank]
    add a, $00
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    pop hl
    ld a, [hl]
    ld c, a
    cp b
    jr z, .disable

    ld a, [wBank7ArgC9FC + 2]
    add a, c
    jr c, .clamp

    cp b
    jr z, .store
    jr c, .store

.clamp:
    ld a, b
.store:
    ld [hl], a
    ld a, $01
    ld [wBank7ArgC9FC + 1], a

.disable:
    xor a
    ld [rRAMG], a
    ret
