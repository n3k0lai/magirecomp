; Bank 7 at $41BD. StorePanelSlotCall41BD maps bank 7 and calls this.
;
; wPanelSlot ($C9D9) selects the blend. Zero calls $43BD, which clears
; $C831, copies wEntryRecord to $C830, and steps words in the low saved
; palettes. Any other value calls $440D, which does the same for the high
; palettes. Each call returns here, and this returns.
;
; wPanelSlot is the name from stage_panel_glyph_dest.asm. wEntryRecord is
; the name from record_ptr_from_id.asm. $43BD and $440D are still INCBIN.
; The stepper they call at $48B6 is still unknown.

DispatchPanelSlotBlend::
    ld a, [wPanelSlot]
    and a
    jr nz, .highPalettes
    call BlendLowSlotPalettes
    ret

.highPalettes:
    call BlendHighSlotPalettes
    ret
