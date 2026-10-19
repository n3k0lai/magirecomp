; Bank 0 at $2AF8. StepMapStripGlyph stores this as wCallback when the
; strip tile id reaches the end.
;
; [$C946] is the first tile id and [$C947] is the id past the end. [$C945]
; is the attribute written in VRAM bank 1. The word at $C93F is the first
; map cell. Each cell gets that attribute, then the next tile id in bank 0,
; until the id reaches the end. wCallback becomes IdleCallback.
;
; $2B00, $2B04, and $2B1F are entries inside this routine. $2B00 loads the
; attribute from [$C945]. $2B04 paints from the tile id in E through the id
; in D. $2B1F stores A as the low byte of wCallback and $29 as the high byte.
;
; The rVBK stores are the 3-byte form. rVBK is the name from
; setup_window.asm. wCallback and IdleCallback are the names from
; default_state.asm. The four strip bytes are named in
; run_d0b1_map_strips.asm.

; First tile id of the finished strip. run_d0b1_map_strips.asm calls this
; wStripTileLoCopy.
DEF STRIP_TILE_LO_COPY EQU $C946
; Tile id that ends the range. The same byte is wStripTileEnd.
DEF STRIP_TILE_END EQU $C947
; Attribute written to VRAM bank 1. The same byte is wStripTileMid.
DEF STRIP_TILE_ATTR EQU $C945
; Little-endian map cell. The same word is wStripMapCell.
DEF wStripMapCellPtr EQU $C93F

PaintStripMapCells::
    ld a, [STRIP_TILE_LO_COPY]
    ld e, a
    ld a, [STRIP_TILE_END]
    ld d, a

PaintStripMapFromAttr::
    ld a, [STRIP_TILE_ATTR]
    ld b, a

PaintStripMapSpan::
    ld hl, wStripMapCellPtr
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld c, e

.cell:
    ld a, $01
    ld [rVBK], a
    ld a, b
    ld [hl], a
    xor a
    ld [rVBK], a
    ld a, c
    ld [hl+], a
    inc c
    ld a, c
    cp d
    jr nz, .cell
    ld a, LOW(IdleCallback)

StoreStripCallbackLow::
    ld [wCallback], a
    ld a, HIGH(IdleCallback)
    ld [wCallback + 1], a
    ret
