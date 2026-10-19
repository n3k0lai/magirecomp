; Fall-through at $1AEE from ArmCountdown1AE8AndDecFFA6 when the
; decrement of $FFA6 reaches zero.
;
; ReloadHighBitsIntoFFA6 stores one plus the high two bits of [BC] at
; $FFA6 and advances BC. CopyNextScriptWordOrC9E5 copies the next two
; script bytes onto wUnknownC9DA. If bit 7 of the high byte is set, that
; word is replaced with the word at $C9E5. The next script byte is stored
; at wPanelSlot ($C9D9). wEntryRecord ($C9DC) is set to 1. BC is saved and
; bank 7 is written to wCurrentROMBank.
;
; The next byte, already source, stores that bank to rROMB0, calls bank
; 7's $41CB, restores BC, and jumps to StepBank7CallbackCountdown.
;
; wUnknownC9DA is the name from dispatch_nonzero_d016.asm. wPanelSlot is
; the name from stage_panel_glyph_dest.asm. wEntryRecord is the name from
; record_ptr_from_id.asm. wCurrentROMBank is the name from reset.asm.
; $FFA6 and $C9E5 are still unnamed. Nothing here is still inside an INCBIN.

StageScriptWordPanelThenBank7::
    call ReloadHighBitsIntoFFA6
    call CopyNextScriptWordOrC9E5
    ld a, [bc]
    inc bc
    ld [wPanelSlot], a
    ld a, $01
    ld [wEntryRecord], a
    push bc
    ld a, $07
    ld [wCurrentROMBank], a
