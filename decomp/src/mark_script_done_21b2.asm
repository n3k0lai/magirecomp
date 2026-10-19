; Second copy of MarkScriptDone. Sets wScriptDone so the script loop at
; RunScriptRecord stops, and plants DispatchScriptOpcode ($0A66) as
; hScriptHandler. Both handler stores are the 3-byte form. Who calls this
; copy is still unknown.
;
; wScriptDone is the name from run_script_record.asm. hScriptHandler is
; the name from reset.asm. DispatchScriptOpcode is the routine at $0A66.

MarkScriptDone21B2::
    ld a, $01
    ld [wScriptDone], a
    ld a, LOW(DispatchScriptOpcode)
    ld [hScriptHandler], a
    ld a, HIGH(DispatchScriptOpcode)
    ld [hScriptHandler + 1], a
    ret
