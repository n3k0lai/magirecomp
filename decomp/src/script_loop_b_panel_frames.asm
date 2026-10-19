; Bank 4 at $72B4. HandleScriptLoopB calls this when B was just pressed,
; before it restores the default VBlank pointer. Bank 4 is already mapped.
; This routine does not write rROMB0. CallBankedHL maps bank 7 and restores
; bank 4 on the way back.
;
; $C9DE is set to $08 and used as the pass count. wUnknownC9D8 is set to
; $07 and the little-endian word at wUnknownC9DA is set to $7FFF. Bank 7's
; FillPanelWordsFromC9DA writes that word across the panel row. wEntryRecord
; is then set to $04, the step byte ApplyPanelRowWords copies to $C830.
;
; Each of the eight passes calls ApplyPanelRowWords, ApplyC9BCScrollThenFrame,
; and FinishFrame, then decrements $C9DE. The loop stops when that byte is
; zero.
;
; wUnknownC9D8 is the name from indexed_tail_07.asm. wUnknownC9DA and
; wUnknownC9DB are the names from dispatch_nonzero_d016.asm. wEntryRecord
; and wEntryRecordField ($C9DE) are the names from record_ptr_from_id.asm.
; Here $C9DE is only the countdown. FillPanelWordsFromC9DA,
; ApplyPanelRowWords, ApplyC9BCScrollThenFrame, CallBankedHL, and
; FinishFrame are already source.

; Passes of the panel step. Stored at $C9DE and counted down.
DEF SCRIPT_LOOP_B_PASSES EQU $08

; Panel index stored at wUnknownC9D8 before the fill.
DEF SCRIPT_LOOP_B_PANEL EQU $07

; Little-endian color word stored at wUnknownC9DA.
DEF SCRIPT_LOOP_B_WORD EQU $7FFF

; Bank of FillPanelWordsFromC9DA and ApplyPanelRowWords.
DEF SCRIPT_LOOP_B_PANEL_BANK EQU $07

; Byte stored at wEntryRecord before the step loop.
DEF SCRIPT_LOOP_B_STEP EQU $04

ScriptLoopBPanelFrames::
    ld a, SCRIPT_LOOP_B_PASSES
    ld [wEntryRecordField], a
    ld a, SCRIPT_LOOP_B_PANEL
    ld [wUnknownC9D8], a
    ld a, LOW(SCRIPT_LOOP_B_WORD)
    ld [wUnknownC9DA], a
    ld a, HIGH(SCRIPT_LOOP_B_WORD)
    ld [wUnknownC9DB], a
    ld hl, FillPanelWordsFromC9DA
    ld e, SCRIPT_LOOP_B_PANEL_BANK
    call CallBankedHL
    ld a, SCRIPT_LOOP_B_STEP
    ld [wEntryRecord], a
.step:
    ld hl, ApplyPanelRowWords
    ld e, SCRIPT_LOOP_B_PANEL_BANK
    call CallBankedHL
    call ApplyC9BCScrollThenFrame
    call FinishFrame
    ld a, [wEntryRecordField]
    dec a
    ld [wEntryRecordField], a
    jr nz, .step
    ret
