; Fallthrough at $1C1D from SetCCA6Countdown1C17 when the decrement
; of $FFA6 reaches zero. $1C20 is a second entry. Bank $44 calls it
; when carry is set, and that entry skips the reload.
;
; $1997, already source, left BC on the same script byte. $19AD, still
; INCBIN, stores one plus the high two bits of [BC] at $FFA6 and advances
; BC. StoreScriptByteAtC9D8 copies the next byte to wUnknownC9D8.
; $C9DC (wEntryRecord) is set to 1. Bank 7 is written to wCurrentROMBank
; and rROMB0, then ApplyPanelRowWords in that bank is called. BC is
; restored and this jumps to StepBank7CallbackCountdown.
;
; ApplyPanelRowWords copies wEntryRecord into $C830 and walks the panel
; row selected by wUnknownC9D8. ReloadFFA6FromHighBits is the name from
; store_panel_slot_call_41bd.asm. StoreScriptByteAtC9D8 is the name from
; store_script_byte_at_c9d8.asm. wEntryRecord is the name from
; record_ptr_from_id.asm, defined later in the link, so this store uses
; $C9DC. wCurrentROMBank and rROMB0 are the names from reset.asm.
; StepBank7CallbackCountdown is the name from
; step_bank7_callback_countdown.asm. ApplyPanelRowWords is the name from
; apply_panel_row_words.asm.

ReloadFFA6StoreC9D8ApplyPanelRow::
    call ReloadFFA6FromHighBits

StoreC9D8ThenApplyPanelRow::
    call StoreScriptByteAtC9D8
    ld a, $01
    ld [$c9dc], a
    push bc
    ld a, $07
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call ApplyPanelRowWords
    pop bc
    jp StepBank7CallbackCountdown
