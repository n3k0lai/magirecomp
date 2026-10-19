; Bank 7 at $4ADF. StampMapCellInWramBanks saves the cell address and
; position, clears the cell in WRAM bank 5, writes $FC in WRAM bank 3,
; then CallBankedHL maps this bank and enters here.
;
; WRAM bank 3 holds the map bytes. The column is at wScriptCellPos+1 and
; the row is at wScriptCellPos. The cell address is at wScriptCellAddr.
; The byte there is the metatile id just written as $FC.
;
; BuildMetatilePointers turns that column, row, and id into a $9800 tilemap
; address in DE and a definition pointer in HL. Those two pointers replace
; the saved position and address, high byte first in each pair.
;
; wCallback is pointed at ReloadScriptCellCopy in this bank. CallCallback
; runs that copy now when the LCD is off, or asks VBlank to run it and
; waits. The ROM bank is left alone on the way in, so the callback bank
; is 7.
;
; wCurrentWRAMBank and rSVBK are the names from timer_overflow.asm.
; wScriptCellAddr and wScriptCellPos are the names from
; opcode_03_continue.asm. wCallback and wCallbackBank are the names from
; default_state.asm. WRAM_MAP is the name from draw_metatile_window.asm.
; SCRIPT_CELL_BANK is the name from opcode_03_continue.asm. CallCallback
; is the name from call_callback.asm.

CopyStampedMapCell::
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
    ld a, LOW(ReloadScriptCellCopy)
    ld [wCallback], a
    ld a, HIGH(ReloadScriptCellCopy)
    ld [wCallback + 1], a
    call CallCallback
    ret
