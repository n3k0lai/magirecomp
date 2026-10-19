; Bank 0 at $32A2. Copies the panel index at $C9D9 into $C9B2, maps
; bank 4, and calls $64EB and then $64C9. Both calls leave bank 4
; mapped. $32DF (RunIndexedPanelRoutine) is stored at wCallback.
; The callback bank at $C6E6 is left alone. Returns.
;
; wUnknownC9D9 and wUnknownC9B2 are the names from
; copy_indexed_panel_block.asm. wCurrentROMBank and rROMB0 are the
; names from reset.asm. wCallback is the name from default_state.asm.
; RunIndexedPanelRoutine is the name from run_indexed_panel_routine.asm.
; $64EB and $64C9 are still INCBIN.

DEF PANEL_SETUP_BANK EQU $04

PlantIndexedPanelCallback::
    ld a, [wUnknownC9D9]
    ld [wUnknownC9B2], a
    ld a, PANEL_SETUP_BANK
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call LoadSelectedPanelByte
    ld a, PANEL_SETUP_BANK
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call LoadSelectedEntryBits
    ld a, LOW(RunIndexedPanelRoutine)
    ld [wCallback], a
    ld a, HIGH(RunIndexedPanelRoutine)
    ld [wCallback + 1], a
    ret
