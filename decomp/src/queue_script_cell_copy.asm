; Bank 7, called by Opcode03ScrollEdge after it saves the cell.
;
; WRAM bank 3 holds the map bytes. The column is at wScriptCellPos+1 and
; the row is at wScriptCellPos. The cell address is at wScriptCellAddr.
; The byte there is the metatile id.
;
; BuildMetatilePointers turns that column, row, and id into a $9800 tilemap
; address in DE and a definition pointer in HL. Those two pointers replace
; the saved position and address, high byte first in each pair.
;
; The callback at $4CA1 is still INCBIN. It reloads those pointers, points
; wCallback at IdleCallback, and falls into CopyMetatile. This routine
; leaves the ROM bank alone, so the callback bank is 7.
;
; wCurrentWRAMBank and rSVBK are the names from timer_overflow.asm.
; wScriptCellAddr and wScriptCellPos are the names from
; opcode_03_continue.asm. wCallback and wCallbackBank are the names from
; default_state.asm. WRAM_MAP is the name from draw_metatile_window.asm.

; Bank 7, still INCBIN. Reloads the pointers stored below and copies the cell.
DEF ScriptCellCopy EQU $4CA1

QueueScriptCellCopy::
    ld a, WRAM_MAP
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld a, [wScriptCellPos + 1]
    ld d, a
    ld a, [wScriptCellPos]
    ld e, a
    ld a, [wScriptCellAddr + 1]
    ld h, a
    ld a, [wScriptCellAddr]
    ld l, a
    ld c, [hl]
    call BuildMetatilePointers
    ld a, d
    ld [wScriptCellPos + 1], a
    ld a, e
    ld [wScriptCellPos], a
    ld a, h
    ld [wScriptCellAddr + 1], a
    ld a, l
    ld [wScriptCellAddr], a
    ld a, SCRIPT_CELL_BANK
    ld [wCallbackBank], a
    ld a, LOW(ScriptCellCopy)
    ld [wCallback], a
    ld a, HIGH(ScriptCellCopy)
    ld [wCallback + 1], a
    ret
