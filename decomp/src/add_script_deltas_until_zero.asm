; Script step at $1E45. BC is the script pointer. The first byte is a
; pair count. Zero means the list is finished: BC is already past that
; byte and control jumps to DispatchScriptOpcode. The pointer is not
; stored on that path.
;
; A nonzero count is saved at $FFA6. BC, still on the first pair, is
; stored at hScriptPtr (high byte first, 3-byte form). hScriptHandler
; becomes .resume ($1E5F), also the 3-byte form, and the first pair is
; applied before this returns.
;
; .resume reads one signed byte into the horizontal pixel delta at
; $C843 and the next into the vertical pixel delta at $C844. Those are
; the deltas StepHorizontalScroll and StepVerticalScroll consume. The
; count is then decremented. A count still above zero is written back
; to $FFA6 and this returns, so the next visit enters at .resume. A
; count that lands on zero stores BC, now past the last pair, at
; hScriptPtr and plants this step again as hScriptHandler. The next
; visit reads a new count.
;
; $FFA6, $C843, and $C844 have no names yet. hScriptPtr and
; hScriptHandler are the names from reset.asm. DispatchScriptOpcode is
; the name from dispatch_script_opcode.asm. Nothing here calls or jumps
; into an INCBIN.

AddScriptDeltasUntilZero::
    ld a, [bc]
    inc bc
    and a
    jp z, DispatchScriptOpcode

    ldh [$ffa6], a
    ld a, b
    ld [hScriptPtr + 1], a
    ld a, c
    ld [hScriptPtr], a
    ld a, LOW(.resume)
    ld [hScriptHandler], a
    ld a, HIGH(.resume)
    ld [hScriptHandler + 1], a

.resume::
    ld a, [bc]
    inc bc
    ld l, a
    ld a, [$c843]
    add l
    ld [$c843], a
    ld a, [bc]
    inc bc
    ld l, a
    ld a, [$c844]
    add l
    ld [$c844], a
    ldh a, [$ffa6]
    dec a
    jr z, .rewait

    ldh [$ffa6], a
    ret

.rewait::
    ld a, b
    ld [hScriptPtr + 1], a
    ld a, c
    ld [hScriptPtr], a
    ld a, LOW(AddScriptDeltasUntilZero)
    ld [hScriptHandler], a
    ld a, HIGH(AddScriptDeltasUntilZero)
    ld [hScriptHandler + 1], a
    ret
