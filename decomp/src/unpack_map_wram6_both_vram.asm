; Bank 0 at $2DAA. LoadC9RecordPicture calls this with HL as the BG-map
; address, BC as the map source in the bank the caller mapped, E as the
; column count, and D as the row count.
;
; The WRAM bank in wCurrentWRAMBank is saved and restored. Bank 6 is
; stored there and selected with `ldh [rSVBK], a`. $2D8C, still INCBIN,
; reads that source, leaves BC at $D000 in the selected bank, and
; restores HL and DE. CopyMapRectToBothVRAMBanks then writes the
; rectangle to VRAM bank 0 and VRAM bank 1. Restoring rSVBK uses the
; 3-byte `ld [rSVBK], a`.
;
; wCurrentWRAMBank and rSVBK are the names from timer_overflow.asm.
; CopyMapRectToBothVRAMBanks is the name from copy_map_rect_both_vram.asm.

UnpackMapIntoWRAM6AndCopyBoth::
    ld a, [wCurrentWRAMBank]
    push af
    ld a, $06
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    call PrepareMapPlanesAtD000
    call CopyMapRectToBothVRAMBanks
    pop af
    ld [wCurrentWRAMBank], a
    ld [rSVBK], a
    ret
