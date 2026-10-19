; Bank 4 at $711C. ScriptHandler1126 calls this with bank 4 mapped
; and BC just past the three script bytes it stored. $C9E7/$C9E8 are
; the low and high bytes of a table of pairs. $FFA6 is the pair index.
; $FFA7 is how many times the current pair's second byte still applies.
;
; When $FFA7 is already 0, the index advances and the next pair's first
; byte is the new count. A zero count plants BC as hScriptPtr and
; INITIAL_SCRIPT_HANDLER ($0A66) as hScriptHandler, then returns. The
; pointer stores and the handler stores are the 3-byte form. A nonzero
; count is saved at $FFA7 and then decremented, the same way an entry
; that arrived with $FFA7 already nonzero only decrements it. Either
; way the pair's second byte is copied to $C9E9 and $715B is called.
; What $C9E9 and $715B do is still unknown. $FFA6 and $FFA7 have no
; names yet. hScriptPtr and hScriptHandler are the names from reset.asm.
; INITIAL_SCRIPT_HANDLER is the name from reset.asm.

; Table base planted by ScriptHandler1126. Low byte at $C9E7.
DEF SCRIPT_PAIR_TABLE EQU $C9E7

; Second byte of the selected pair. Still unnamed.
DEF SCRIPT_PAIR_VALUE EQU $C9E9

StepScriptPairCountdown::
    ld hl, SCRIPT_PAIR_TABLE
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ldh a, [$FFA6]
    sla a
    ld e, a
    ld d, $00
    add hl, de
    ldh a, [$FFA7]
    and a
    jr nz, .decrement
    ldh a, [$FFA6]
    inc a
    ldh [$FFA6], a
    inc hl
    inc hl
    ld a, [hl]
    and a
    jr nz, .reload
    ld a, b
    ld [hScriptPtr + 1], a
    ld a, c
    ld [hScriptPtr], a
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ld [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ld [hScriptHandler + 1], a
    ret

.reload::
    ldh [$FFA7], a
.decrement::
    dec a
    ldh [$FFA7], a
    inc hl
    ld a, [hl]
    ld [SCRIPT_PAIR_VALUE], a
    call StepScrollByScriptPair
    ret
