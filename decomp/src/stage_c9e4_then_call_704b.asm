; Saves [$C9E4] on the stack, replaces it with one script byte at [BC],
; and advances BC into hScriptPtr. hScriptHandler becomes
; INITIAL_SCRIPT_HANDLER ($0A66). ROM bank 4 is stored to
; wCurrentROMBank and rROMB0, then $704B in that bank is called. The
; saved low byte is written back to $C9E4 before the return. The pointer
; and handler stores are the 3-byte form.
;
; What $C9E4 and the bank 4 call mean is still unknown. hScriptPtr,
; hScriptHandler, INITIAL_SCRIPT_HANDLER, wCurrentROMBank, and rROMB0
; are the names from reset.asm.

; ROM bank mapped for the call at $704B.
DEF C9E4_CALL_BANK EQU $04

StageC9E4ThenCall704B::
    ld a, [$C9E4]
    ld e, a
    push de
    ld a, [bc]
    ld [$C9E4], a
    inc bc
    ld a, b
    ld [hScriptPtr + 1], a
    ld a, c
    ld [hScriptPtr], a
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ld [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ld [hScriptHandler + 1], a
    ld a, C9E4_CALL_BANK
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call $704B
    pop de
    ld a, e
    ld [$C9E4], a
    ret
