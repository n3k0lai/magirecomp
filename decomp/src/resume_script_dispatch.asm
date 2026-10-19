; Shared tail after a record is planted at $C9EC / $C9F0. Clears $C9EB,
; $C9EE, and $C9EF, copies BC into hScriptPtr (C low, B high), and plants
; DispatchScriptOpcode ($0A66) as hScriptHandler. Both pointer stores and
; both handler stores are the 3-byte form. What the three cleared bytes
; mean is still unknown.
;
; hScriptPtr and hScriptHandler are the names from reset.asm.

ResumeScriptDispatch::
    xor a
    ld [$C9EB], a
    ld [$C9EE], a
    ld [$C9EF], a
    ld a, b
    ld [hScriptPtr + 1], a
    ld a, c
    ld [hScriptPtr], a
    ld a, LOW(DispatchScriptOpcode)
    ld [hScriptHandler], a
    ld a, HIGH(DispatchScriptOpcode)
    ld [hScriptHandler + 1], a
    ret
