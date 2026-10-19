; Stores 1 at $FFA7 with ldh, clears $FFA6 with ldh, and plants $1126 as
; hScriptHandler. BC is saved at hScriptPtr (high at $FFA3, low at $FFA2).
; Those four stores are the 3-byte form. Control returns to the caller.
;
; .from_clear is $1110: it skips the $FFA7 store and starts at the clear.
; .ptr_only is $1113: it skips both tail bytes and only plants the handler
; and the pointer. What $FFA6 and $FFA7 mean here, and what $1126 does, is
; still unknown. $1126 is the next byte and stays INCBIN. hScriptPtr and
; hScriptHandler are the names from reset.asm.

; Planted as hScriptHandler. Still INCBIN.
DEF HANDLER_1126 EQU $1126

StageHandler1126::
    ld a, $01
    ldh [$FFA7], a
.from_clear::
    xor a
    ldh [$FFA6], a
.ptr_only::
    ld a, LOW(HANDLER_1126)
    ld [hScriptHandler], a
    ld a, HIGH(HANDLER_1126)
    ld [hScriptHandler + 1], a
    ld a, b
    ld [hScriptPtr + 1], a
    ld a, c
    ld [hScriptPtr], a
    ret
