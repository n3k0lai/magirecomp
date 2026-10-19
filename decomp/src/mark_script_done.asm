; Sets wScriptDone so the script loop at RunScriptRecord stops, and plants
; DispatchScriptOpcode ($0A66) as hScriptHandler. Both handler stores are
; the 3-byte form. Who calls this, and whether $0A66 runs again after the
; loop sees the flag, is still unknown.
;
; wScriptDone is the name from run_script_record.asm. hScriptHandler is
; the name from reset.asm.

MarkScriptDone::
    ld a, $01
    ld [wScriptDone], a
    ld a, LOW(DispatchScriptOpcode)
    ld [hScriptHandler], a
    ld a, HIGH(DispatchScriptOpcode)
    ld [hScriptHandler + 1], a
    ret
