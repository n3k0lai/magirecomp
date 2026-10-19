; Bank 3 at $6784. StepPrefixedBlockChoice0C calls this. The SRAM
; path falls through into RepaintPrefixedBlockWindow.
;
; RefreshRecordLenFromMode updates $CCCC from the mode at $CCCB.
; A zero mode calls $6880, which copies [$CCD5] to $CCC6, clears
; $CCC9, selects WRAM bank 6, and stores list bytes at $CCCD, then
; jumps to RepaintPrefixedBlockWindow. Any other mode calls
; CollectChoiceIndicesForward, which fills those same bytes from
; SRAM, and then falls into the repaint. The repaint rearms the slot.
;
; $6880 is still INCBIN. CHOICE_MODE is the name from
; setup_prefixed_block_choice.asm. CHOICE_00 is the name from
; dispatch_armed_choice.asm. RefreshRecordLenFromMode,
; CollectChoiceIndicesForward, and RepaintPrefixedBlockWindow are
; already source.

RefreshPrefixedBlockList::
    call RefreshRecordLenFromMode
    ld a, [CHOICE_MODE]
    cp CHOICE_00
    jr nz, .fromSram

    call FillChoiceBytesForward
    jr RepaintPrefixedBlockWindow

.fromSram:
    call CollectChoiceIndicesForward

RefreshPrefixedBlockListEnd:
