; Bank 7. Column at wScriptCellPos+1, row at wScriptCellPos, and the
; metatile id in the low byte of wScriptCellAddr. The high byte is unread.
;
; BuildMetatilePointers turns those into a $9800 tilemap address in DE and
; a definition pointer in HL. Those replace the saved position and address.
; wCallback becomes ReloadScriptCellCopy, which reloads both pointers and
; falls into CopyMetatile. The ROM bank, wCallbackBank, and the WRAM bank
; stay as the caller left them.
;
; wScriptCellAddr and wScriptCellPos are the names from
; opcode_03_continue.asm. wCallback is the name from default_state.asm.

QueueCellCopyFromId::
    ld a, [wScriptCellPos + 1]
    ld d, a
    ld a, [wScriptCellPos]
    ld e, a
    ld a, [wScriptCellAddr]
    ld c, a
    call BuildMetatilePointers
    ld a, d
    ld [wScriptCellPos + 1], a
    ld a, e
    ld [wScriptCellPos], a
    ld a, h
    ld [wScriptCellAddr + 1], a
    ld a, l
    ld [wScriptCellAddr], a
    ld a, LOW(ReloadScriptCellCopy)
    ld [wCallback], a
    ld a, HIGH(ReloadScriptCellCopy)
    ld [wCallback + 1], a
    ret
