; Entry at $17BF. A is the byte to match. If [BC] differs, return and
; leave BC, hScriptPtr, and hScriptHandler alone. If it matches, consume
; that byte, save the new BC as hScriptPtr (high at $FFA3, low at $FFA2),
; plant INITIAL_SCRIPT_HANDLER ($0A66) in hScriptHandler, and return.
;
; The three callers still in the $1737 hole load [$C6F9], [$C6FB], or
; [$C6FD] into A and jump here. Those are the same three bytes the
; $17B2 entry tests for zero. What a match means is still unknown.
; hScriptPtr, hScriptHandler, and INITIAL_SCRIPT_HANDLER are the names
; from reset.asm. The handler stores are the 3-byte form.

MatchScriptByteThenPlantHandler::
    ld d, a
    ld a, [bc]
    cp d
    ret nz
    inc bc
    ld a, b
    ld [hScriptPtr + 1], a
    ld a, c
    ld [hScriptPtr], a
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ld [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ld [hScriptHandler + 1], a
    ret
