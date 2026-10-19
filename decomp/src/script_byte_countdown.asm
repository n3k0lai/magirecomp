; Reads one script byte at [BC] into $FFA6 and advances BC. BC is then
; stored at hScriptPtr (high at $FFA3, low at $FFA2) with the 3-byte form,
; and .resume is planted as hScriptHandler, also with the 3-byte form.
; Execution falls into .resume.
;
; .resume tests $FFA6. Zero jumps to INITIAL_SCRIPT_HANDLER ($0A66). A
; nonzero count is decremented back into $FFA6 and the routine returns, so
; the next pass through hScriptHandler enters .resume again.
;
; What the countdown means is still unknown. hScriptPtr, hScriptHandler,
; and INITIAL_SCRIPT_HANDLER are the names from reset.asm. $FFA6 has no
; name yet.

ScriptByteCountdown::
    ld a, [bc]
    inc bc
    ldh [$FFA6], a
    ld a, b
    ld [hScriptPtr + 1], a
    ld a, c
    ld [hScriptPtr], a
    ld a, LOW(.resume)
    ld [hScriptHandler], a
    ld a, HIGH(.resume)
    ld [hScriptHandler + 1], a
.resume::
    ldh a, [$FFA6]
    and a
    jp z, INITIAL_SCRIPT_HANDLER
    dec a
    ldh [$FFA6], a
    ret
