; Stores $08 at $C9FA and $6DE9 at $C9F4 (low byte first), then jumps to
; the shared tail at $1216.
;
; .high_only is $1200. Callers that already wrote $C9FA and $C9F4 enter
; there and only store $6D at $C9F5. .join is $1205: it is only the jump.
; What $C9FA and the word at $C9F4 mean is still unknown. The same shape
; sits just after this jump with $10 at $C9FA and $6DF9 at $C9F4.
;
; The tail at $1216 is still INCBIN. It copies BC to hScriptPtr, plants
; INITIAL_SCRIPT_HANDLER ($0A66) as hScriptHandler, maps bank 4, calls
; $6AFA, and returns. hScriptPtr, hScriptHandler, and
; INITIAL_SCRIPT_HANDLER are the names from reset.asm. This fragment does
; not write rROMB0.

; Little-endian word stored at $C9F4. Still unknown.
DEF C9F4_PTR_6DE9 EQU $6DE9

PlantC9FA08AndPtr6DE9::
    ld a, $08
    ld [$C9FA], a
    ld a, LOW(C9F4_PTR_6DE9)
    ld [$C9F4], a
.high_only::
    ld a, HIGH(C9F4_PTR_6DE9)
    ld [$C9F5], a
.join::
    jr $1216
