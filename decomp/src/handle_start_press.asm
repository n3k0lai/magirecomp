; Start was just pressed. GameLoop maps bank 6 and calls here.
;
; Returns at once unless $C6EE is zero, bit 1 of $FFAB is set, $C716 is
; zero, and $CCA6 is zero. $FFAB is the copy of $FFAA that FinishFrame
; latches. $C716 sits in the script record at $C714. The other two bytes
; are still unknown.
;
; The taken path parks every sprite, turns the LCD off, and pulls the
; window to the top-left (WY 0, WX 7). It copies two 16-byte blocks from
; this bank into VRAM through CopyGlyphBytes, calls $5182 twice with a
; pointer pair and a count, and fills $2C bytes at $CC4D with 1. $C727 is
; stored to the cartridge RAM-bank register. SRAM is enabled, three ranges
; are OR-ed together, two bytes are copied out, and SRAM is disabled.
; $5FC2 and $61F1 run in this bank, the LCD turns on, leftover sprites are
; hidden, and $095F runs. Control then jumps to the loop at $673B and does
; not return to GameLoop.
;
; The loads and stores at $FFAB, rWY, and rWX are the 3-byte form.
; `dec` in each SRAM scan leaves Z set, so `and a` retests the OR.
; `add a, $00` leaves the RAM-bank byte unchanged. Nothing reads those flags.
; wUnknownC6EE, rWX, and rWY are the names from setup_window.asm.
; wGlyphSrc, wGlyphDest, and wGlyphVRAMBank are the names from
; draw_cgb_notice.asm. wUnknownCCA5 is the name from finish_startup.asm.
; rRAMG is the name from reset.asm.

; Latched copy of $FFAA. Bit 1 must be set to continue.
DEF hLatchedFFAB EQU $FFAB

; Nonzero makes this hook return. Role still unknown.
DEF wUnknownC716 EQU $C716
DEF wUnknownCCA6 EQU $CCA6

; Cleared below. Near the sound bytes at $C91E-$C92A. Roles still unknown.
DEF wUnknownC928 EQU $C928
DEF wUnknownC929 EQU $C929
DEF wUnknownC92A EQU $C92A
DEF wUnknownC92C EQU $C92C

DEF wUnknownC728 EQU $C728
DEF wUnknownC729 EQU $C729

; Cartridge RAM-bank register. Written from $C727.
DEF rRAMB EQU $4000
DEF wSRAMBank EQU $C727
DEF SRAM_ENABLE EQU $0A

; Count passed to the still-INCBIN routine at $5182.
DEF wBlockCount EQU $CC42
DEF wBlockSrc EQU $CC43
DEF wBlockDest EQU $CC45

DEF wUnknownCC47 EQU $CC47
DEF wUnknownCC4C EQU $CC4C
DEF wUnknownCC4E EQU $CC4E
DEF wUnknownCC4F EQU $CC4F
DEF wUnknownCC50 EQU $CC50
DEF wUnknownCC51 EQU $CC51
DEF wUnknownCC52 EQU $CC52
DEF wFillCC4D EQU $CC4D
DEF FILL_CC4D_LEN EQU $2C

DEF wUnknownCCA1 EQU $CCA1
DEF wUnknownCCA8 EQU $CCA8
DEF wUnknownCCA9 EQU $CCA9
DEF wUnknownCCAE EQU $CCAE
DEF wUnknownCCB0 EQU $CCB0
DEF wUnknownCCB2 EQU $CCB2
DEF wUnknownCCB6 EQU $CCB6
DEF wUnknownCCB7 EQU $CCB7
DEF wUnknownCCB9 EQU $CCB9
DEF wUnknownCC71 EQU $CC71

DEF wUnknownCD7F EQU $CD7F
DEF wUnknownCD80 EQU $CD80
DEF wUnknownCD81 EQU $CD81

; Bank 6, still INCBIN. CPU address while this bank stays mapped.
DEF Bank6_61F1 EQU $61F1
; Bank 6 loop. Still INCBIN. This hook jumps there instead of returning.

DEF BANK_CALL_624E EQU $04
DEF Far_624E EQU $624E
DEF BANK_CALL_4274 EQU $03
DEF Far_4274 EQU $4274

DEF GLYPH_SRC_A EQU $41D0
DEF GLYPH_DEST_A EQU $97F0
DEF GLYPH_SRC_B EQU $43A0
DEF GLYPH_DEST_B EQU $9750
DEF BLOCK_DEST_A EQU $97A0
DEF BLOCK_COUNT_A EQU $05
DEF BLOCK_DEST_B EQU $9760
DEF BLOCK_COUNT_B EQU $04
DEF PTR_8860 EQU $8860
DEF PTR_49EB EQU $49EB
DEF PTR_42F3 EQU $42F3
DEF PTR_42F7 EQU $42F7

DEF SRAM_SCAN_A EQU $A5A6
DEF SRAM_SCAN_A_LEN EQU $FD
DEF SRAM_SCAN_B EQU $A3A8
DEF SRAM_SCAN_B_LEN EQU $FD
DEF SRAM_SCAN_C EQU $A4A6
DEF SRAM_SCAN_C_LEN EQU $FE
DEF SRAM_BYTE_A118 EQU $A118
DEF SRAM_BYTE_A3A4 EQU $A3A4

HandleStartPress::
    ld a, [wUnknownC6EE]
    cp $00
    ret nz
    ld a, [hLatchedFFAB]
    bit 1, a
    ret z
    ld a, [wUnknownC716]
    and a
    ret nz
    ld a, [wUnknownCCA6]
    and a
    ret nz
    ld a, $06
    ld [wUnknownC92C], a
    xor a
    ld [wUnknownC928], a
    ld [wUnknownC929], a
    ld a, $04
    ld [wUnknownC92A], a
    ld a, $00
    ld [wUnknownC728], a
    ld [wUnknownC729], a
    call ParkSprites
    call TurnOffLCD
    call CopyVRAMBank1Tiles
    ld hl, Far_624E
    ld e, BANK_CALL_624E
    call CallBankedHL
    xor a
    ld [rWY], a
    ld a, $07
    ld [rWX], a
    call SelectIndexedSetup0A
    ld a, $00
    ld [wUnknownCC47], a
    ld bc, PTR_8860
    ld hl, wBlockDest
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld bc, PTR_49EB
    ld hl, wUnknownCCAE
    ld a, c
    ld [hl+], a
    ld [hl], b
    xor a
    ld [wUnknownCD7F], a
    ld [wUnknownCD80], a
    ld [wUnknownCC4C], a
    ld [wUnknownCCA1], a
    ld [wUnknownCD81], a
    ld hl, Far_4274
    ld e, BANK_CALL_4274
    call CallBankedHL
    ld a, $ff
    ld [wUnknownCCA9], a
    ld a, $81
    ld [wUnknownCCA8], a
    ld a, $01
    ld [wUnknownCCB9], a
    ld a, $01
    ld [wGlyphVRAMBank], a
    ld bc, GLYPH_SRC_A
    ld hl, wGlyphSrc
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld bc, GLYPH_DEST_A
    ld hl, wGlyphDest
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld e, BANK_WINDOW_TILES
    ld hl, CopyGlyphBytes
    call CallBankedHL
    ld bc, StartPressListGlyphs
    ld hl, wBlockSrc
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld bc, BLOCK_DEST_A
    ld hl, wBlockDest
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld a, BLOCK_COUNT_A
    ld [wBlockCount], a
    call CopyIndexedBlocks
    ld bc, GLYPH_SRC_B
    ld hl, wGlyphSrc
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld bc, GLYPH_DEST_B
    ld hl, wGlyphDest
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld e, BANK_WINDOW_TILES
    ld hl, CopyGlyphBytes
    call CallBankedHL
    ld bc, StartPressBlankGlyphs
    ld a, [wUnknownCCA5]
    and a
    jr z, .block_src_b
    ld bc, StartPressSaveGlyphs
.block_src_b:
    ld hl, wBlockSrc
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld bc, BLOCK_DEST_B
    ld hl, wBlockDest
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld a, BLOCK_COUNT_B
    ld [wBlockCount], a
    call CopyIndexedBlocks
    ld bc, PTR_42F3
    ld hl, wUnknownCCB0
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld bc, PTR_42F7
    ld hl, wUnknownCCB2
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld hl, wFillCC4D
    ld a, h
    ld [wUnknownCCB7], a
    ld a, l
    ld [wUnknownCCB6], a
    ld a, $01
    ld d, FILL_CC4D_LEN
.fill_cc4d:
    ld [hl+], a
    dec d
    jr nz, .fill_cc4d
    ld a, [wSRAMBank]
    add a, $00
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld hl, SRAM_SCAN_A
    ld d, SRAM_SCAN_A_LEN
    xor a
.scan_a:
    or [hl]
    inc hl
    dec d
    jr nz, .scan_a
    and a
    jr nz, .scan_b_begin
    ld [wUnknownCC4E], a
.scan_b_begin:
    ld hl, SRAM_SCAN_B
    ld d, SRAM_SCAN_B_LEN
    xor a
.scan_b:
    or [hl]
    inc hl
    dec d
    jr nz, .scan_b
    and a
    jr nz, .scan_c_begin
    ld [wUnknownCC50], a
.scan_c_begin:
    ld hl, SRAM_SCAN_C
    ld d, SRAM_SCAN_C_LEN
    xor a
.scan_c:
    or [hl]
    inc hl
    dec d
    jr nz, .scan_c
    and a
    jr nz, .copy_sram_bytes
    ld [wUnknownCC52], a
.copy_sram_bytes:
    ld a, [SRAM_BYTE_A118]
    inc a
    ld [wUnknownCC4F], a
    ld a, [SRAM_BYTE_A3A4]
    ld [wUnknownCC51], a
    ld a, [wUnknownCCA5]
    ld [wUnknownCC71], a
    xor a
    ld [rRAMG], a
    call DrawStartScreenMap
    call Bank6_61F1
    call TurnOnLCDIfOff
    call HideLeftoverSprites
    call RefreshFrame
    jp AfterStartLoop
