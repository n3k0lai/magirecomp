; Bank 7 at $44EA. RestoreSavedTiles calls this through CallBankedHL
; after CopyC7ABToBGPalettes, before the saved tiles are copied back.
;
; $C7EB is the $40 bytes immediately after SavedBlockC7AB. Those bytes
; are the eight object palettes, four colors each. $80 is written to
; rOCPS with the 3-byte store so the index starts at palette 0 and
; auto-increments. C is rOCPD. Each of the $40 bytes is stored there
; in order.
;
; rOCPS and rOCPD are the CGB object-palette index and data ports.

DEF rOCPS EQU $FF6A
DEF rOCPD EQU $FF6B

; Bit 7 of rOCPS makes the palette index advance after each data write.
DEF OCPS_AUTOINC EQU $80

; Eight object palettes follow the background palette block at $C7AB.
DEF ObjPalettesC7EB EQU SavedBlockC7AB + BG_PALETTE_BYTES

CopyC7EBToOBJPalettes::
    ld hl, ObjPalettesC7EB
    ld a, OCPS_AUTOINC
    ld [rOCPS], a
    ld c, LOW(rOCPD)
FOR N, BG_PALETTE_BYTES
    ld a, [hl+]
    ldh [c], a
ENDR
    ret
