; Script entry at $1AB0. Plants .wait as hScriptHandler, then calls
; SaveScriptPtrAndSplitByte. That helper saves BC as hScriptPtr, stores
; the low six bits of [BC] at $FFA7, stores (([BC] & $C0) >> 6) + 1 at
; $FFA6, and leaves BC on that same byte.
;
; .wait is also the fall-through. It decrements $FFA6 and returns while
; the count stays above zero. At zero it calls ReloadHighBitsIntoFFA6,
; which reloads that high-bit count into $FFA6 and advances BC.
;
; The next script byte is stored at wPanelSlot ($C9D9). Bank 7 is mapped
; and $416B is called. BC is restored and control jumps to
; StepBank7CallbackCountdown. Unlike the $1A44 entry, wEntryRecord is
; left alone.
;
; hScriptHandler is the name from reset.asm. The handler stores are the
; 3-byte form. wPanelSlot is the name from stage_panel_glyph_dest.asm.
; wCurrentROMBank and rROMB0 are the names from reset.asm. $FFA6 and
; bank 7's $416B are still unnamed. $416B is file address $01C16B.

StorePanelSlotThenCall416B::
    ld a, LOW(.wait)
    ld [hScriptHandler], a
    ld a, HIGH(.wait)
    ld [hScriptHandler + 1], a
    call SaveScriptPtrAndSplitByte

.wait:
    ldh a, [$FFA6]
    dec a
    ldh [$FFA6], a
    ret nz

    call ReloadHighBitsIntoFFA6
    ld a, [bc]
    inc bc
    ld [wPanelSlot], a
    push bc
    ld a, $07
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call CyclePanelSlotPaletteColors
    pop bc
    jp StepBank7CallbackCountdown
