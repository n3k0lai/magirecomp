; Bank 4 at $5CB3. TryAffordOtherChoice falls through here when the
; armed choice is 5. HL is still the 8-byte record. This bank stays
; mapped. The routine does not write rROMB0.
;
; wUnknownCD49 is set to 1. Record+0 is stored at wUnknownCD8C and at
; $CD51, the operand AddSRAMEntryForOperand reads. wUnknownCD8F points
; at wListTailDest. CopyIndexedName in bank 6 copies that id's ten-byte
; name there, and LIST_TAIL_MARK follows it. $C93D is pointed at
; wListTailDest so the window text is that name.
;
; SRAM bank wSRAMBank is selected with `add a, $00` and left enabled.
; The difference word at $CD4A replaces the word at $A3A5. $CD4D is
; stored at $A4A6 plus the index in $CD4C. When $CD4E is not $FF, $CD4F
; is stored at $A4A6 plus that index. Both paths continue at
; AddSRAMEntryForOperand.
;
; wUnknownCD49 is the name from call_bank4_5494_then_enter_script.asm.
; wUnknownCD8C and wUnknownCD8F are the names from indexed_tail_07.asm.
; wListTailDest and LIST_TAIL_MARK are the names from setup_command_4d.asm.
; INDEXED_NAME_LEN is the name from copy_indexed_name.asm.
; COPY_INDEXED_NAME_BANK is the name from write_indexed_names_and_count.asm.
; OTHER_TEXT_BUF, OTHER_DIFF_WORD, OTHER_COST_WORD, OTHER_INDEX_A,
; OTHER_DIFF_A, OTHER_SENTINEL, OTHER_DIFF_B, and OTHER_COST_BYTES are
; the names from try_afford_other_choice.asm. rRAMB, wSRAMBank, and
; SRAM_ENABLE are the names from handle_start_press.asm. rRAMG is the
; name from reset.asm. CopyIndexedName, CallBankedHL, and
; AddSRAMEntryForOperand are already source.

; $CD51 is the operand byte. No name is committed for it yet.
DEF wNewEntryOperand EQU $CD51

; Flag stored at wUnknownCD49 when choice 5 commits.
DEF COMMIT_OTHER_FLAG EQU $01

; $FF in $CD4E means TryAffordOtherChoice skipped the second stock byte.
DEF NO_SECOND_STOCK EQU $FF

CommitOtherChoiceFive::
    ld a, COMMIT_OTHER_FLAG
    ld [wUnknownCD49], a
    ld a, [hl]
    ld [wUnknownCD8C], a
    ld [wNewEntryOperand], a
    ld bc, wListTailDest
    ld hl, wUnknownCD8F
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld hl, CopyIndexedName
    ld e, COPY_INDEXED_NAME_BANK
    call CallBankedHL
    ld hl, wListTailDest + INDEXED_NAME_LEN
    ld a, LIST_TAIL_MARK
    ld [hl], a
    ld a, LOW(wListTailDest)
    ld [OTHER_TEXT_BUF], a
    ld a, HIGH(wListTailDest)
    ld [OTHER_TEXT_BUF + 1], a
    ld a, [wSRAMBank]
    add a, $00
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld hl, OTHER_DIFF_WORD
    ld a, [hl+]
    ld b, [hl]
    ld c, a
    ld hl, OTHER_COST_WORD
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld a, [OTHER_INDEX_A]
    ld c, a
    ld b, $00
    ld hl, OTHER_COST_BYTES
    add hl, bc
    ld a, [OTHER_DIFF_A]
    ld [hl], a
    ld a, [OTHER_SENTINEL]
    cp NO_SECOND_STOCK
    jr z, AddSRAMEntryForOperand
    ld c, a
    ld b, $00
    ld hl, OTHER_COST_BYTES
    add hl, bc
    ld a, [OTHER_DIFF_B]
    ld [hl], a
