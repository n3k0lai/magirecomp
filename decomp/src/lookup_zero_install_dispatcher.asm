; DE-zero path after SRAMLookupInstallScript. The $1234 lookup left DE at
; zero, so no script handler was installed there.
;
; BC still points at the three-byte record the lookup read. Skip those
; bytes, store the following address as hScriptPtr, and plant
; DispatchScriptOpcode ($0A66) as hScriptHandler. The four stores are the
; three-byte form. hScriptPtr and hScriptHandler are the names from
; reset.asm.

LookupZeroInstallDispatcher::
    inc bc
    inc bc
    inc bc
    ld a, b
    ld [hScriptPtr + 1], a
    ld a, c
    ld [hScriptPtr], a
    ld a, LOW(DispatchScriptOpcode)
    ld [hScriptHandler], a
    ld a, HIGH(DispatchScriptOpcode)
    ld [hScriptHandler + 1], a
    ret
