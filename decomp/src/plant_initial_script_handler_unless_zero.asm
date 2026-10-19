; Entry at $17B2. If A is zero, return and leave hScriptHandler alone.
; Otherwise plant INITIAL_SCRIPT_HANDLER ($0A66) there and return.
;
; The three callers still in the $172B hole load [$C6F9], [$C6FB], or
; [$C6FD] into A and jump here. AddAndShift copies $C6F8, $C6FA, and
; $C6FC into those bytes. The handler stores are the 3-byte form.
; hScriptHandler and INITIAL_SCRIPT_HANDLER are the names from reset.asm.
; What a nonzero value means is still unknown.

PlantInitialScriptHandlerUnlessZero::
    and a
    ret z
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ld [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ld [hScriptHandler + 1], a
    ret
