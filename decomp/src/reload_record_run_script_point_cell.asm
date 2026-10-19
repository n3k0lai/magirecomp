; Bank 1 at $5DE1. Record heads such as ResumeUpIdleRecord call this
; first. rROMB0 is left alone by this routine itself.
;
; BC points at a record. LoadRecordHead copies the ten-byte head into
; HRAM and leaves HL just past it. LoadScriptBytes then copies the next
; seven bytes into the HRAM script record and MapScriptBankAndCall runs
; that handler. The ROM bank is restored by that call.
;
; Bit 1 of $FFAA is set. FinishFrame copies $FFAA to $FFAB and clears
; it. What bit 1 marks is still unknown. WRAM bank 5 is stored at
; wCurrentWRAMBank and selected with rSVBK. HL returns the little-endian
; word at hMapCellPointer ($FF93). This does not write rROMB0.
;
; LoadRecordHead is the routine at $412F. LoadScriptBytes and
; MapScriptBankAndCall are the routines at $2928 and $0A3A.
; wCurrentWRAMBank and rSVBK are the names from timer_overflow.asm.
; hMapCellPointer is the name from pick_map_cell_from_div.asm.

ReloadRecordRunScriptPointCell::
    call LoadRecordHead
    call LoadScriptBytes
    call MapScriptBankAndCall
    ld hl, $ffaa
    set 1, [hl]
    ld a, $05
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld hl, hMapCellPointer
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ret
