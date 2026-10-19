; Bank 3 at $6B03. SpendPrefixedBlockRecord jumps here when the
; little-endian cost does not fit in the SRAM word at $A3A5, or when
; $C9FD is zero after the bank 7 copy. The cost is still on the stack.
;
; This path discards that cost, stores $02 in wSoundSlotA, and returns
; to the prefixed-block choice loop. wSoundSlotA is the name from
; select_sound_command.asm. DispatchPrefixedBlockChoice is already source.

DEF PREFIXED_RECORD_SOUND EQU $02

RejectPrefixedRecordCost::
    pop bc
    ld a, PREFIXED_RECORD_SOUND
    ld [wSoundSlotA], a
    jp DispatchPrefixedBlockChoice
