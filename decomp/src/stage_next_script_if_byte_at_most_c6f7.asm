; Script entry at $1737. Read one script byte and compare it with
; [wUnknownC6F5 + 2] ($C6F7). If $C6F7 is below that byte, return with BC
; still on it. Otherwise skip the byte, store the new BC at hScriptPtr
; (high at $FFA3, low at $FFA2), increment [wUnknownC6F5], and plant $1756
; as hScriptHandler. The stores are the 3-byte form. Control leaves with ret.
;
; $1756, still INCBIN, is the next script step. It reads another script byte
; against $C6F6. What the $C6F7 compare selects is still unknown.
; wUnknownC6F5 is the name from write_quad_records.asm. hScriptPtr and
; hScriptHandler are the names from reset.asm.
;
; Nothing this routine calls is still inside an INCBIN.

DEF ScriptStepAt1756 EQU $1756

StageNextScriptIfByteAtMostC6F7::
    ld a, [bc]
    ld e, a
    ld a, [wUnknownC6F5 + 2]
    cp e
    ret c
    inc bc
    ld a, b
    ld [hScriptPtr + 1], a
    ld a, c
    ld [hScriptPtr], a
    ld hl, wUnknownC6F5
    inc [hl]
    ld a, LOW(ScriptStepAt1756)
    ld [hScriptHandler], a
    ld a, HIGH(ScriptStepAt1756)
    ld [hScriptHandler + 1], a
    ret
