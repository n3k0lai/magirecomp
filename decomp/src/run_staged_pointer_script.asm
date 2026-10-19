; Bank 4 at $71ED. StagePointerUnlessD0B6Matches calls this after it
; has stored a bank at $C9CC and a pointer little-endian at $C9CA, and
; before it plants the $4C:$4000 script. Bank 4 is already mapped.
; This routine does not write rROMB0.
;
; wCallback is set to $29A4, still INCBIN in bank 0. The LCD is turned
; off, the timer is armed, and PresentInstalledScriptEntries runs.
; wScriptRecord then becomes the staged bank, the staged pointer, and
; INITIAL_SCRIPT_HANDLER ($0A66). WriteQuadRecords clears the following
; quad, RunScriptRecord runs the record just stored, and TurnOnLCDIfOff
; turns the LCD on when wLCDC is still zero.
;
; PollScriptLoopButtons and ApplyC9BCScrollThenFrame then repeat while
; byte 2 of wScriptRecord ($C708) is nonzero. HandleScriptLoopB runs
; once that byte is clear, restoring the default VBlank pointer and
; clearing the script-loop gate, and this returns.
;
; wCallback is the name from default_state.asm. wScriptRecord is the
; name from finish_startup.asm. INITIAL_SCRIPT_HANDLER is the name from
; reset.asm. $C9CA and $C9CC are the staging bytes written by
; StagePointerUnlessD0B6Matches. What $29A4 means is still unknown.

; Bank 0 address planted at wCallback. Still INCBIN.
DEF STAGED_SCRIPT_CALLBACK EQU $29A4

RunStagedPointerScript::
    ld a, LOW(STAGED_SCRIPT_CALLBACK)
    ld [wCallback], a
    ld a, HIGH(STAGED_SCRIPT_CALLBACK)
    ld [wCallback + 1], a
    call TurnOffLCD
    call SetTimerModulo
    call PresentInstalledScriptEntries
    ld hl, wScriptRecord
    ld a, [$C9CC]
    ld [hl+], a
    ld a, [$C9CA]
    ld [hl+], a
    ld a, [$C9CB]
    ld [hl+], a
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ld [hl+], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ld [hl+], a
    call WriteQuadRecords
    call RunScriptRecord
    call TurnOnLCDIfOff
.loop:
    call PollScriptLoopButtons
    call ApplyC9BCScrollThenFrame
    ld a, [wScriptRecord + 2]
    and a
    jr nz, .loop
    call HandleScriptLoopB
    ret
