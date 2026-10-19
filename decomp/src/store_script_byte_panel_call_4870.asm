; Fallthrough at $1BEA from SetCCA6Countdown1BE4 when the decrement
; of $FFA6 reaches zero.
;
; $1997, already source, left BC on the same script byte. $19AD, still
; INCBIN, stores one plus the high two bits of [BC] at $FFA6 and advances
; BC. StoreScriptByteAtC9D8 copies the next byte to wUnknownC9D8. The
; byte after that is stored at wPanelSlot. Bank 7 is written to
; wCurrentROMBank and rROMB0, then $4870 in that bank is called. BC is
; restored and this jumps to StepBank7CallbackCountdown.
;
; $1C01 is the pop, and $1C02 is only the jump. Bank $3C jumps to $1C01
; when carry is clear, and bank $74 calls $1C02.
;
; What $4870 does is still unknown. Its file address is $01C870.
; ReloadFFA6FromHighBits is the name from store_panel_slot_call_41bd.asm.
; StoreScriptByteAtC9D8 is the name from store_script_byte_at_c9d8.asm.
; wPanelSlot is the name from stage_panel_glyph_dest.asm.
; wCurrentROMBank and rROMB0 are the names from reset.asm.
; StepBank7CallbackCountdown is the name from
; step_bank7_callback_countdown.asm.

StoreScriptBytePanelCall4870::
    call ReloadFFA6FromHighBits
    call StoreScriptByteAtC9D8
    ld a, [bc]
    ld [wPanelSlot], a
    inc bc
    push bc
    ld a, $07
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call RotatePalettesEightyPastRow

PopBCThenStepBank7::
    pop bc

JumpStepBank7CallbackCountdown::
    jp StepBank7CallbackCountdown
