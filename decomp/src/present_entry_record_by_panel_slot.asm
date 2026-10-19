; Bank 4's $7055. StageC9D8ThenCall7055 stores one script byte at
; wUnknownC9D8, clears wPanelSlot ($C9D9), and calls here with bank 4
; mapped. RecordPtrFromId turns that id into the pointer at
; wEntryRecordField. $7069 (still INCBIN) copies the next eleven bytes
; of that record into $C9CD–$C9D7. A zero panel slot calls bank 0 at
; $338D, which draws those fields with VRAM bank 0 and the map at $99E0.
; A nonzero slot calls bank 0 at $340B, which draws them with VRAM bank 1
; and the map at $9C00. This routine does not touch rROMB0.
;
; wUnknownC9D8 is the name from indexed_tail_07.asm. wPanelSlot is the
; name from stage_panel_glyph_dest.asm. RecordPtrFromId and
; wEntryRecordField are the names from record_ptr_from_id.asm.

PresentEntryRecordByPanelSlot::
    call RecordPtrFromId
    call $7069
    ld a, [wPanelSlot]
    and a
    jr nz, .nonzeroSlot
    call $338D
    ret

.nonzeroSlot
    call $340B
    ret
