; Stores $10 at $C9FA and $6DF9 at $C9F4 (low byte first), then falls into
; the shared tail at $1216.
;
; What $C9FA and the word at $C9F4 mean is still unknown. The fragment at
; $11F6 plants $08 and $6DE9, then jumps to that same tail. This one
; plants the next pair and continues straight into it.
;
; The tail copies BC to hScriptPtr, plants INITIAL_SCRIPT_HANDLER
; ($0A66) as hScriptHandler, maps bank 4, and calls $6AFA. This fragment
; does not write rROMB0.

; Little-endian word stored at $C9F4. Still unknown.
DEF C9F4_PTR_6DF9 EQU $6DF9

PlantC9FA10AndPtr6DF9::
    ld a, $10
    ld [$C9FA], a
    ld a, LOW(C9F4_PTR_6DF9)
    ld [$C9F4], a
    ld a, HIGH(C9F4_PTR_6DF9)
    ld [$C9F5], a
