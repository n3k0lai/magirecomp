; Fallthrough at $1B21 from ArmCountdownHandlerAndDecFFA6 when the
; decrement of $FFA6 reaches zero. $1B29 is a second entry that skips
; the reload and the $C9D9 store.
;
; $1997, already source, left BC on the same script byte. $19AD, still
; INCBIN, stores one plus the high two bits of [BC] at $FFA6 and advances
; BC. The next byte is stored at $C9D9 (wPanelSlot). $C9DC (wEntryRecord)
; is set to 1. Bank 7 is written to wCurrentROMBank and rROMB0, then
; $41BD in that bank is called. BC is restored and this jumps to
; StepBank7CallbackCountdown.
;
; What $41BD does is still unknown. Its file address is $01C1BD.
; wCurrentROMBank and rROMB0 are the names from reset.asm. wPanelSlot is
; the name from stage_panel_glyph_dest.asm. wEntryRecord is the name from
; record_ptr_from_id.asm.

; Bank 0, still INCBIN. Reloads $FFA6 from the high bits of [BC].
DEF ReloadFFA6FromHighBits EQU $19AD

StorePanelSlotCall41BD::
    call ReloadFFA6FromHighBits
    ld a, [bc]
    inc bc
    ld [$c9d9], a

SetEntryRecordCall41BD::
    ld a, $01
    ld [$c9dc], a
    push bc
    ld a, $07
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call DispatchPanelSlotBlend
    pop bc
    jp StepBank7CallbackCountdown
