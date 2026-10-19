; Bank 7 at $445F. CopyIndexedPanelBlock and RestoreSavedTiles call this
; after bank 7 is mapped.
;
; $C7AB is SavedBlockC7AB from restore_saved_tiles.asm: the $40 bytes
; copied back from $CC02. Those bytes are the eight background palettes,
; four colors each. $80 is written to rBCPS with the 3-byte store so the
; index starts at palette 0 and auto-increments. C is rBCPD. Each of the
; $40 bytes is stored there in order.
;
; rBCPS and rBCPD are the CGB background-palette index and data ports.

DEF rBCPS EQU $FF68
DEF rBCPD EQU $FF69

; Bit 7 of rBCPS makes the palette index advance after each data write.
DEF BCPS_AUTOINC EQU $80

DEF BG_PALETTE_BYTES EQU $40

CopyC7ABToBGPalettes::
    ld hl, SavedBlockC7AB
    ld a, BCPS_AUTOINC
    ld [rBCPS], a
    ld c, LOW(rBCPD)
FOR N, BG_PALETTE_BYTES
    ld a, [hl+]
    ldh [c], a
ENDR
    ret
