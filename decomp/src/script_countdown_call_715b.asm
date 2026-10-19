; Reads three script bytes at [BC] into $C9EA, $C9E9, and $FFA6, advancing
; BC after each one. BC is then stored at hScriptPtr (high at $FFA3, low at
; $FFA2) with the 3-byte form, and .resume ($1193) is planted as
; hScriptHandler, also with the 3-byte form. Execution falls into .resume.
;
; .resume tests $FFA6. Zero jumps to INITIAL_SCRIPT_HANDLER ($0A66). A
; nonzero count is decremented back into $FFA6. ROM bank 4 is stored to
; wCurrentROMBank and rROMB0, then $715B in that bank is called.
;
; $C9E9 is the pair value from step_script_pair_countdown.asm. What $C9EA
; and this countdown mean is still unknown. hScriptPtr, hScriptHandler,
; INITIAL_SCRIPT_HANDLER, wCurrentROMBank, and rROMB0 are the names from
; reset.asm. $715B is still INCBIN.

; ROM bank mapped for the call at $715B.
DEF COUNTDOWN_715B_BANK EQU $04

ScriptCountdownCall715B::
    ld a, [bc]
    inc bc
    ld [$C9EA], a
    ld a, [bc]
    inc bc
    ld [$C9E9], a
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
    ld a, COUNTDOWN_715B_BANK
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call $715B
    ret
