; Bank 3 at $6A41. AddPrefixedChoiceWord jumps here when the byte at
; LIST_A3A7 plus the record id is still nonzero after the decrement.
; This routine does not write rROMB0.
;
; SRAM is disabled. $CCC9 becomes $FF, so the next choice pass treats
; the slot index as new. Control returns to DispatchPrefixedBlockChoice.
;
; rRAMG is the name from reset.asm. wLatchedSlot is the name from
; dispatch_prefixed_block_choice.asm. LIST_A3A7 is the name from
; setup_prefixed_block_choice.asm. DispatchPrefixedBlockChoice is
; already source.

; LATCH_NONE is the name from spend_prefixed_block_record.asm.
ClearLatchedSlotResumeChoice::
    xor a
    ld [rRAMG], a
    ld a, LATCH_NONE
    ld [wLatchedSlot], a
    jp DispatchPrefixedBlockChoice
