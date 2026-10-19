; Bank 4 at $71CE. PollScriptLoopButtons calls this when B was just
; pressed and the script-loop gate is set. Bank 4 is already mapped.
; This routine does not write rROMB0.
;
; $72B4 runs first. It is still INCBIN. wVBlankRoutine is then pointed
; at DefaultVBlank ($2A49), the same pointer SetupDefaultState installs.
; Bytes 3 and 4 of wScriptRecord become $02 and $14, the tail of the
; 00 00 02 14 pattern InitQuadRecords writes. Byte 2 of that record
; and the script-loop gate are cleared. The loop that follows the
; script record waits on byte 2, so clearing it is how this press
; leaves that loop. The `ld` stores are the 3-byte form.
;
; wVBlankRoutine and DefaultVBlank are the names from default_state.asm.
; wScriptRecord is the name from finish_startup.asm. wScriptLoopGate is
; the name from poll_script_loop_buttons.asm.

HandleScriptLoopB::
    call ScriptLoopBPanelFrames
    ld a, LOW(DefaultVBlank)
    ld [wVBlankRoutine], a
    ld a, HIGH(DefaultVBlank)
    ld [wVBlankRoutine + 1], a
    ld a, $02
    ld [wScriptRecord + 3], a
    ld a, $14
    ld [wScriptRecord + 4], a
    xor a
    ld [wScriptRecord + 2], a
    ld [wScriptLoopGate], a
    ret
