; Bank 0 at $32C9. Copies the panel index at $C9D9 into $C9B2,
; stores 4 at $C9B1, and plants $32DF (RunIndexedPanelRoutine) at
; wCallback. The callback bank at $C6E6 is left alone. Returns.
;
; The low three bits of $C9B1 become the BG palette in the panel
; attribute painters. wUnknownC9D9 and wUnknownC9B2 are the names from
; copy_indexed_panel_block.asm. wUnknownC9B1 is the name from
; load_entry_glyph.asm. wCallback is the name from default_state.asm.
; RunIndexedPanelRoutine is the name from run_indexed_panel_routine.asm.

; Written whole to wUnknownC9B1. The painters use its low three bits.
DEF PANEL_FIELD_4 EQU $04

PlantPanelField4Callback::
    ld a, [wUnknownC9D9]
    ld [wUnknownC9B2], a
    ld a, PANEL_FIELD_4
    ld [wUnknownC9B1], a
    ld a, LOW(RunIndexedPanelRoutine)
    ld [wCallback], a
    ld a, HIGH(RunIndexedPanelRoutine)
    ld [wCallback + 1], a
    ret
