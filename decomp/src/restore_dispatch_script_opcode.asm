; Bank 1 at $4A2E. Opcode9DBody jumps here when wUnknownC6EE is 2.
; Clears bit 7 of hScriptBank (that bit had forced bank 1) and plants
; DispatchScriptOpcode ($0A66) as hScriptHandler. Both handler stores
; are the 3-byte form.
;
; hScriptBank and hScriptHandler are the names from reset.asm.
; wUnknownC6EE is the name from setup_window.asm.

RestoreDispatchScriptOpcode::
    ld hl, hScriptBank
    res 7, [hl]
    ld a, LOW(DispatchScriptOpcode)
    ld [hScriptHandler], a
    ld a, HIGH(DispatchScriptOpcode)
    ld [hScriptHandler + 1], a
    ret
