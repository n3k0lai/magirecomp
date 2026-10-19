; Bank 4 at $722E. InstallScriptRecordLoopBank4 calls this once after
; the script record is stored and before RunScriptRecord. Bank 4 is
; already mapped. This routine does not write rROMB0. CallBankedHL
; maps each callee's bank and restores bank 4 on the way back.
;
; InitPointerList runs in bank 1. The shadow-OAM cursors at $C728 and
; $C729 are cleared and ParkSprites hides every sprite. $C9C5, $C9C8,
; and $C831 are cleared, then $72ED (still INCBIN) runs. $C834 and
; $C835 are cleared, $C832 is set to $00, and $C833 is set to $24.
; [$C9E4] is read and written back, then ApplyC9E4TableEntry runs in
; bank 4.
;
; [$C9E0] is stored at $C9D8 with wPanelSlot ($C9D9) cleared, and
; PresentEntryRecordByPanelSlot runs. [$C9E1] is stored at $C9D8 with
; wPanelSlot set to $01, and that present runs again. $C9D8 is then
; set to $07 and the word at $C9DA is set to $7FFF (high byte first).
; Bank 7 at $4837 runs, then bank 7 at $4575.
;
; $C9D8 is wUnknownC9D8 from indexed_tail_07.asm and wGfx8C00Bank from
; load_c9_record_picture.asm. $C9DA is wGfx8C00Ptr from that same file.
; wPanelSlot is the name from stage_panel_glyph_dest.asm.
; wShadowOAMCursor and wShadowOAMPrevEnd are the names from
; hide_leftover_sprites.asm. What $C9C5, $C9C8, $C831–$C835, $C9E0,
; $C9E1, and the three INCBIN calls mean is still unknown. The
; `ld a, $00` stores are the bytes in the ROM.

PresentInstalledScriptEntries::
    ld hl, InitPointerList
    ld e, $01
    call CallBankedHL
    ld a, $00
    ld [wShadowOAMCursor], a
    ld [wShadowOAMPrevEnd], a
    call ParkSprites
    xor a
    ld [$C9C5], a
    ld [$C9C8], a
    ld [$C831], a
    call $72ED
    xor a
    ld [$C834], a
    ld [$C835], a
    ld a, $00
    ld [$C832], a
    ld a, $24
    ld [$C833], a
    ld a, [$C9E4]
    ld [$C9E4], a
    ld hl, ApplyC9E4TableEntry
    ld e, $04
    call CallBankedHL
    ld a, [$C9E0]
    ld [$C9D8], a
    ld a, $00
    ld [wPanelSlot], a
    ld hl, PresentEntryRecordByPanelSlot
    ld e, $04
    call CallBankedHL
    ld a, [$C9E1]
    ld [$C9D8], a
    ld a, $01
    ld [wPanelSlot], a
    ld hl, PresentEntryRecordByPanelSlot
    ld e, $04
    call CallBankedHL
    ld a, $07
    ld [$C9D8], a
    ld de, $7FFF
    ld a, d
    ld [$C9DB], a
    ld a, e
    ld [$C9DA], a
    ld hl, $4837
    ld e, $07
    call CallBankedHL
    ld hl, $4575
    ld e, $07
    call CallBankedHL
    ret
