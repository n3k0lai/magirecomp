; Script handler at $15AB. The caller is still INCBIN.
;
; The byte at BC is a repeat count. Zero jumps to INITIAL_SCRIPT_HANDLER
; ($0A66). Otherwise the count is stored at $FFA6 with ldh, BC (just past
; that byte) is stored at hScriptPtr with the [hl+] form, and .step is
; planted as hScriptHandler with the 3-byte form. Execution falls into
; .step.
;
; .step reads two script bytes into $C6D2 and $C6D3 and leaves HL just
; past them. $FFA6 is then decremented. A remaining count is written back
; with ldh and the handler returns. hScriptPtr still names those two
; bytes, so the next pass copies them again. A count that hits zero
; stores HL at hScriptPtr (high byte first) and plants
; INITIAL_SCRIPT_HANDLER.
;
; What $C6D2 and $C6D3 mean is still unknown. $FFA6 has no name yet.
; hScriptPtr, hScriptHandler, and INITIAL_SCRIPT_HANDLER are the names
; from reset.asm.

RepeatTwoScriptBytes::
    ld a, [bc]
    inc bc
    and a
    jp z, INITIAL_SCRIPT_HANDLER

    ldh [$FFA6], a
    ld hl, hScriptPtr
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld a, LOW(.step)
    ld [hScriptHandler], a
    ld a, HIGH(.step)
    ld [hScriptHandler + 1], a
.step::
    ld h, b
    ld l, c
    ld a, [hl+]
    ld [$C6D2], a
    ld a, [hl+]
    ld [$C6D3], a
    ldh a, [$FFA6]
    dec a
    jr z, .last

    ldh [$FFA6], a
    ret

.last:
    ld a, h
    ld [hScriptPtr + 1], a
    ld a, l
    ld [hScriptPtr], a
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ld [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ld [hScriptHandler + 1], a
    ret
