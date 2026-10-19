; Bank 0 at $2DC3. DrawEntryFieldsVRAM1 calls this with BC from
; $C9D0 after the $9C00 row is placed. HL is the BG-map address, E is
; the column count, and D is the row count.
;
; The WRAM bank in wCurrentWRAMBank is saved and restored. Bank 6 is
; stored there and selected with `ldh [rSVBK], a`. PrepareMapPlanesAtD000
; reads that source, leaves BC at $D000 in the selected bank, and
; restores HL and DE. $2D55, still INCBIN, writes each row from the
; end of the rectangle into VRAM bank 0 and then VRAM bank 1.
; Restoring rSVBK uses the 3-byte `ld [rSVBK], a`.
;
; wCurrentWRAMBank and rSVBK are the names from timer_overflow.asm.
; PrepareMapPlanesAtD000 is the name from prepare_map_at_d000.asm.

; Still INCBIN. Copies the prepared rectangle into both VRAM banks,
; walking each row from its last column.
DEF CopyMapRectBothVRAMReverse EQU $2D55

UnpackMapIntoWRAM6AndCopyReverse::
    ld a, [wCurrentWRAMBank]
    push af
    ld a, $06
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    call PrepareMapPlanesAtD000
    call CopyMapRectBothVRAMReverse
    pop af
    ld [wCurrentWRAMBank], a
    ld [rSVBK], a
    ret
