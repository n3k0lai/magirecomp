; Script entry at $1756, planted by StageNextScriptIfByteAtMostC6F7.
; Read one script byte into E and advance BC. Then load [wUnknownC6F5 + 1]
; ($C6F6) and leave HL on $C6F5.
;
; If $C6F6 is zero, store the new BC at hScriptPtr (high byte first, 3-byte
; form) and plant INITIAL_SCRIPT_HANDLER ($0A66) as hScriptHandler. That
; address is DispatchScriptOpcode. Control leaves with ret.
;
; If $C6F6 is below the script byte, return with the byte already consumed.
; Otherwise write $01 to $C6F5 and $FF to $C6F6, then return.
;
; What $C6F6 selects is still unknown. wUnknownC6F5 is the name from
; write_quad_records.asm. hScriptPtr, hScriptHandler, and
; INITIAL_SCRIPT_HANDLER are the names from reset.asm.
;
; Nothing this routine calls is still inside an INCBIN.

DispatchIfC6F6IsZeroElseMarkIt::
    ld hl, wUnknownC6F5 + 1
    ld a, [bc]
    ld e, a
    inc bc
    ld a, [hl-]
    and a
    jr z, .c6f6IsZero
    cp e
    ret c
    ld a, $01
    ld [hl+], a
    ld a, $ff
    ld [hl+], a
    ret

.c6f6IsZero
    ld a, b
    ld [hScriptPtr + 1], a
    ld a, c
    ld [hScriptPtr], a
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ld [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ld [hScriptHandler + 1], a
    ret
