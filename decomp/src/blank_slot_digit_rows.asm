; Bank 4 at $6160. CopiedBlockWindowChoice plants this address at
; wCallback, in this bank, and calls RefreshFrame. The next plant is
; $618B, still INCBIN. This bank stays mapped. The routine does not
; write rROMB0.
;
; rVBK is cleared with the 3-byte form, so the writes land in VRAM
; bank 0. Ten cells at $9DC4 and ten at $9DE4 become tile $80. Those
; are window-map rows 14 and 15, columns 4 through 13: the strips
; $60DF copies the slot digits onto. wCallback then becomes
; IdleCallback, low byte first. wCallbackBank is left alone.
;
; wCallback and IdleCallback are the names from default_state.asm.
; rVBK is the name from setup_window.asm.

DEF SLOT_ROW_BLANK EQU $80
DEF SLOT_ROW_CELLS EQU 10
DEF SLOT_MAP_ROW14 EQU $9DC4
DEF SLOT_MAP_ROW15 EQU $9DE4

BlankSlotDigitRows::
    xor a
    ld [rVBK], a
    ld a, SLOT_ROW_BLANK
    ld hl, SLOT_MAP_ROW14
    rept SLOT_ROW_CELLS
        ld [hl+], a
    endr
    ld hl, SLOT_MAP_ROW15
    rept SLOT_ROW_CELLS
        ld [hl+], a
    endr
    ld a, LOW(IdleCallback)
    ld [wCallback], a
    ld a, HIGH(IdleCallback)
    ld [wCallback + 1], a
    ret
