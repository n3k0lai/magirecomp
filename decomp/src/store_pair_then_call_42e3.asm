; Fallthrough at $1B83 from SetCountdownHandler1B7D when the decrement
; of $FFA6 reaches zero.
;
; $1997, already source, left BC on the same script byte. $19AD, still
; INCBIN, stores one plus the high two bits of [BC] at $FFA6 and advances
; BC. The next two script bytes are stored at wUnknownC9D8 and wPanelSlot.
; Bank 7 is written to wCurrentROMBank and rROMB0, then $42E3 in that bank
; is called. BC is restored and this jumps to StepBank7CallbackCountdown.
;
; What $42E3 does is still unknown. Its file address is $01C2E3.
; ReloadFFA6FromHighBits is the name from store_panel_slot_call_41bd.asm.
; wUnknownC9D8 is the name from indexed_tail_07.asm. wPanelSlot is the
; name from stage_panel_glyph_dest.asm. wCurrentROMBank and rROMB0 are
; the names from reset.asm.

StorePairThenCall42E3::
    call ReloadFFA6FromHighBits
    ld a, [bc]
    inc bc
    ld [wUnknownC9D8], a
    ld a, [bc]
    inc bc
    ld [wPanelSlot], a
    push bc
    ld a, $07
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call PermutePanelPaletteChannels
    pop bc
    jp StepBank7CallbackCountdown
