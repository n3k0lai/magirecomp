; Paint the start-screen background map, then its attributes.
;
; Called from the start-button hook while this bank stays mapped. A `jp`
; at $5FBF also enters at DrawStartScreenAttrs.
;
; VRAM bank 0: $233 bytes from $9C00 are filled with tile $80 (through
; $9E32). Six cells get tile $85, three runs of $12 get tile $83, and two
; columns of five get tile $84 every $20 bytes. $6EBB, still INCBIN, is
; called with A, HL, DE, and C for the remaining strips and is not
; decoded here.
;
; If SRAM byte $A3A4 in the bank at $C727 is zero, five cells at $9E02
; are set back to $80. Otherwise SRAM is left enabled across that skip.
; `add a, $00` keeps the bank byte and its flags. Nothing reads them.
;
; Three words are loaded and passed to $041A in bank 0, still INCBIN.
; $61E1 then writes $C92F, $C92E, and $C92D added to tile base $A1.
; The word at $A3A5 is little-endian. The words at $A005 and $A007, in
; SRAM bank $C727+1, are stored high byte first. What they count is
; still unknown.
;
; VRAM bank 1: $234 attribute bytes from $9C00 are set to $0F (through
; $9E33). A run of $12 at $9E21 becomes $4F. Rows 1 through $10 get $2F
; in the first column, by shifting the row index left five times. Four
; cells are patched, $C6F1 is cleared, and $C6F0 is set to 7.
;
; Stores to rVBK and rRAMG use the 3-byte form. rVBK is the name from
; setup_window.asm. rRAMG is the name from reset.asm. wSRAMBank is the
; name from handle_start_press.asm. The $4000 store is the cartridge
; RAM-bank register, also named rRAMB there.

; Tile written across the cleared map. Picture still unknown.
DEF TILE_MAP_FILL EQU $80
DEF TILE_MAP_MARK EQU $85
DEF TILE_MAP_ROW EQU $83
DEF TILE_MAP_COL EQU $84

DEF vBGMap EQU $9C00
DEF MAP_FILL_LEN EQU $0233
DEF MAP_ATTR_LEN EQU $0234
DEF MAP_RUN_LEN EQU $12
DEF MAP_COL_LEN EQU $05
DEF MAP_ROW_STRIDE EQU $20

; Attribute written across the same window, then patched.
DEF ATTR_FILL EQU $0F
DEF ATTR_RUN EQU $4F
DEF ATTR_ROW EQU $2F
DEF ATTR_TAIL EQU $4F
DEF ATTR_CORNER EQU $6F
DEF ATTR_ROW_COUNT EQU $10
DEF ATTR_SHIFT EQU $05

; Still unknown. Cleared and set just before the return.
DEF wUnknownC6F0 EQU $C6F0
DEF wUnknownC6F1 EQU $C6F1
DEF wUnknownC6F0_VALUE EQU $07

; Cartridge RAM. wSRAMBank and SRAM_ENABLE are the names from
; handle_start_press.asm.
DEF sMapFlag EQU $A3A4
DEF sMapWord0 EQU $A3A5
DEF sMapWord1 EQU $A005
DEF sMapWord2 EQU $A007

; Tile added to the three bytes $041A leaves in $C92D-$C92F.
DEF TILE_DIGIT_BASE EQU $A1

DrawStartScreenMap::
    xor a
    ld [rVBK], a
    ld bc, MAP_FILL_LEN
    ld hl, vBGMap
.fillMap:
    ld a, TILE_MAP_FILL
    ld [hl+], a
    dec bc
    ld a, c
    or b
    jr nz, .fillMap

    ld a, TILE_MAP_MARK
    ld [$9C00], a
    ld [$9C13], a
    ld [$9D60], a
    ld [$9D73], a
    ld [$9E20], a
    ld [$9E33], a
    ld a, TILE_MAP_ROW
    ld hl, $9E21
    ld c, MAP_RUN_LEN
.row9E21:
    ld [hl+], a
    dec c
    jr nz, .row9E21

    ld a, TILE_MAP_ROW
    ld hl, $9D61
    ld c, MAP_RUN_LEN
.row9D61:
    ld [hl+], a
    dec c
    jr nz, .row9D61

    ld a, TILE_MAP_ROW
    ld hl, $9C01
    ld c, MAP_RUN_LEN
.row9C01:
    ld [hl+], a
    dec c
    jr nz, .row9C01

    ld a, TILE_MAP_COL
    ld hl, $9D80
    ld c, MAP_COL_LEN
    ld de, MAP_ROW_STRIDE
.col9D80:
    ld [hl], a
    add hl, de
    dec c
    jr nz, .col9D80

    ld a, TILE_MAP_COL
    ld hl, $9D93
    ld c, MAP_COL_LEN
    ld de, MAP_ROW_STRIDE
.col9D93:
    ld [hl], a
    add hl, de
    dec c
    jr nz, .col9D93

    xor a
    ld [rVBK], a
    ld a, $86
    ld hl, $9D82
    ld de, $0001
    ld c, $05
    call StampTileRun
    ld a, $8B
    ld hl, $9DA2
    ld de, $0001
    ld c, $05
    call StampTileRun
    ld a, $90
    ld hl, $9DC2
    ld de, $0001
    ld c, $05
    call StampTileRun
    ld a, $95
    ld hl, $9DE2
    ld de, $0001
    ld c, $05
    call StampTileRun
    ld a, $9A
    ld hl, $9E02
    ld de, $0001
    ld c, $05
    call StampTileRun
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld a, [wSRAMBank]
    add a, $00
    ld [$4000], a
    ld a, [sMapFlag]
    and a
    jr nz, .afterFlag

    ld hl, $9E02
    ld a, TILE_MAP_FILL
    ld d, $05
.blank9E02:
    ld [hl+], a
    dec d
    jr nz, .blank9E02

    xor a
    ld [rRAMG], a

.afterFlag:
    ld a, $7A
    ld hl, $9E0E
    ld de, $0001
    ld c, $05
    call StampTileRun
    ld a, $76
    ld hl, $9DEE
    ld de, $0001
    ld c, $04
    call StampTileRun
    ld a, $9F
    ld [$9DAB], a
    ld a, $A0
    ld [$9D8D], a
    ld a, $75
    ld [$9DAF], a
    ld a, [wSRAMBank]
    add a, $00
    ld [$4000], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld hl, sMapWord0
    ld a, [hl+]
    ld d, [hl]
    ld e, a
    xor a
    ld [rRAMG], a
    call FormatStartDigits
    ld hl, $9D8E
    ld d, TILE_DIGIT_BASE
    call WriteDigitTiles
    ld a, [wSRAMBank]
    add a, $01
    ld [$4000], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld hl, sMapWord1
    ld a, [hl+]
    ld e, [hl]
    ld d, a
    call FormatStartDigits
    ld hl, $9DAC
    ld d, TILE_DIGIT_BASE
    call WriteDigitTiles
    ld hl, sMapWord2
    ld a, [hl+]
    ld e, [hl]
    ld d, a
    call FormatStartDigits
    ld hl, $9DB0
    ld d, TILE_DIGIT_BASE
    call WriteDigitTiles
    xor a
    ld [rRAMG], a

; Also the target of the jp at $5FBF.
DrawStartScreenAttrs:
    ld a, $01
    ld [rVBK], a
    ld d, ATTR_FILL
    ld bc, MAP_ATTR_LEN
.fillAttr:
    ld hl, $9BFF
    add hl, bc
    ld [hl], d
    dec bc
    ld a, c
    or b
    jr nz, .fillAttr

    ld a, ATTR_RUN
    ld d, MAP_RUN_LEN
    ld hl, $9E21
.attr9E21:
    ld [hl+], a
    dec d
    jr nz, .attr9E21

    ld bc, ATTR_ROW_COUNT
.attrRows:
    ld hl, vBGMap
    push bc
    ld a, ATTR_SHIFT
.shiftRow:
    sla c
    rl b
    dec a
    jr nz, .shiftRow

    add hl, bc
    ld a, ATTR_ROW
    ld [hl+], a
    pop bc
    dec c
    jr nz, .attrRows

    ld a, ATTR_ROW
    ld [$9C00], a
    ld [$9D60], a
    ld a, ATTR_TAIL
    ld [$9E33], a
    ld a, ATTR_CORNER
    ld [$9E20], a
    xor a
    ld [wUnknownC6F1], a
    ld a, wUnknownC6F0_VALUE
    ld [wUnknownC6F0], a
    ret
