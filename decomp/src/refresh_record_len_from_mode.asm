; Bank 3 at $6B25. StepPrefixedBlockChoice0B calls this while this
; bank stays mapped.
;
; The mode at $CCCB chooses how $CCCC is refreshed. A zero mode stores
; WRAM bank 6 at $C937, selects it with rSVBK, and copies [$D000] to
; $CCCC. The bank stays selected. Any other mode calls $74EF with
; HL = $A3A7 and C = $F0, which counts the nonzero SRAM bytes and
; stores that count at $CCCC.
;
; CHOICE_MODE is the name from setup_prefixed_block_choice.asm.
; CHOICE_00 is the name from dispatch_armed_choice.asm. LIST_A3A7 is
; the name from setup_prefixed_block_choice.asm. COUNT_WINDOW is the
; name from prepare_choice_012.asm. RECORD_LEN is the name from
; stage_copied_block_arm_slot.asm. wCurrentWRAMBank and rSVBK are the
; names from timer_overflow.asm. CountNonzeroChoiceBytes is already
; source.

DEF LIST_WRAM_BANK EQU $06

; Byte copied into $CCCC while WRAM bank 6 is selected.
DEF wListSourceD000 EQU $D000

RefreshRecordLenFromMode::
    ld a, [CHOICE_MODE]
    cp CHOICE_00
    jr z, .copyBank6Byte

    ld hl, LIST_A3A7
    ld c, COUNT_WINDOW
    call CountNonzeroChoiceBytes
    ret

.copyBank6Byte:
    ld a, LIST_WRAM_BANK
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld a, [wListSourceD000]
    ld [RECORD_LEN], a
    ret

RefreshRecordLenFromModeEnd:
