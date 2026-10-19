; Fallthrough at $1C50 from SetCCA6Countdown1C4A when the decrement
; of $FFA6 reaches zero. $1C5E is a second entry that skips the script
; reads and starts at the bank switch.
;
; $1997, already source, left BC on the same script byte.
; ReloadHighBitsIntoFFA6 stores one plus the high two bits of [BC] at
; $FFA6 and advances BC. StoreScriptByteAtC9D8 copies the next byte to
; wUnknownC9D8. CopyNextScriptWordOrC9E5 copies the next word onto
; wUnknownC9DA, or the word at $C9E5 when bit 7 of the high byte is set.
; $C9DC (wEntryRecord) is set to 1. Bank 7 is written to wCurrentROMBank
; and rROMB0, then StepStagedColorEightyPastRow in that bank is called.
; BC is restored and this jumps to StepBank7CallbackCountdown.
;
; ReloadHighBitsIntoFFA6 is the name from reload_high_bits_into_ffa6.asm.
; StoreScriptByteAtC9D8 is the name from store_script_byte_at_c9d8.asm.
; CopyNextScriptWordOrC9E5 is the name from
; copy_next_script_word_or_c9e5.asm. wEntryRecord is the name from
; record_ptr_from_id.asm, defined later in the link, so this store uses
; $C9DC. wCurrentROMBank and rROMB0 are the names from reset.asm.
; StepStagedColorEightyPastRow is the name from
; step_staged_color_eighty_past_row.asm. StepBank7CallbackCountdown is
; the name from step_bank7_callback_countdown.asm.

ReloadWordThenStepEighty::
    call ReloadHighBitsIntoFFA6
    call StoreScriptByteAtC9D8
    call CopyNextScriptWordOrC9E5
    ld a, $01
    ld [$c9dc], a

StepEightyFromSavedWord::
    push bc
    ld a, $07
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call StepStagedColorEightyPastRow
    pop bc
    jp StepBank7CallbackCountdown
