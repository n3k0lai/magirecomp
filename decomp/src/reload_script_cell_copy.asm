; Bank 7 callback queued by QueueScriptCellCopy.
;
; That routine replaced the saved column, row, and map address with a
; $9800 tilemap address in wScriptCellPos and a definition pointer in
; wScriptCellAddr. Reload both pairs (high byte first), point wCallback
; at IdleCallback, and fall into CopyMetatile. DE and HL stay live for
; that entry. The ROM bank is left alone.
;
; wScriptCellAddr and wScriptCellPos are the names from
; opcode_03_continue.asm. wCallback and IdleCallback are the names from
; default_state.asm.

ReloadScriptCellCopy::
    ld a, [wScriptCellPos + 1]
    ld d, a
    ld a, [wScriptCellPos]
    ld e, a
    ld a, [wScriptCellAddr + 1]
    ld h, a
    ld a, [wScriptCellAddr]
    ld l, a
    ld a, LOW(IdleCallback)
    ld [wCallback], a
    ld a, HIGH(IdleCallback)
    ld [wCallback + 1], a
