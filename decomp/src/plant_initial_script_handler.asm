; Script path at $149E. The caller is still INCBIN.
;
; BC is written into hScriptHandler (B at $FFA5, C at $FFA4). Those two
; stores are then overwritten: hScriptHandler becomes
; INITIAL_SCRIPT_HANDLER ($0A66). Nothing else changes, and the routine
; returns to the caller.
;
; hScriptHandler and INITIAL_SCRIPT_HANDLER are the names from reset.asm.

PlantInitialScriptHandler::
    ld a, b
    ldh [hScriptHandler + 1], a
    ld a, c
    ldh [hScriptHandler], a
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler + 1], a
    ret
