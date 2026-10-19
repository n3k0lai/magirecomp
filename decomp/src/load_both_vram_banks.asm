; Entered by a jump from StepSlotPair after that routine has already dropped
; three stacked words. This routine does not return to StepSlotPair.
;
; Sprites are parked and the LCD is turned off. Bank 6's $61D2 runs through
; CallBankedHL, which maps bank 6 and restores the previous bank. WRAM bank 4
; is selected and remembered in wCurrentWRAMBank. With the LCD off, $800
; bytes at $D000 are copied to $9000 in VRAM bank 0, then $800 bytes at
; $D800 are copied to $9000 in VRAM bank 1. $9000 is tile indices 0-127 of
; the $8800 pattern table. Those two blocks are the whole of WRAM bank 4.
; The stores to rVBK are the 3-byte form. Selecting rSVBK is ldh.
;
; SetupWindowTilemap runs in bank 0, then the LCD is turned on if it was
; left off. Three more stacked words are discarded. wUnknownC92C is set to
; $0F, wUnknownC928 and wUnknownC929 are cleared, and wUnknownC92A is set
; to 4.
;
; ParkSprites, TurnOffLCD, CallBankedHL, CopyHLToDE, and TurnOnLCDIfOff are
; the names from bank 0. SetupWindowTilemap is the name from
; setup_window.asm. wCurrentWRAMBank and rSVBK are the names from
; timer_overflow.asm. rVBK is the name from setup_window.asm.
; wUnknownC928, wUnknownC929, wUnknownC92A, and wUnknownC92C are the names
; from handle_start_press.asm. $61D2 in bank 6 is still INCBIN.

; Tiles 0-127 of the $8800 pattern table. $800 bytes.
DEF vTiles9000 EQU $9000
DEF PATTERN_BLOCK EQU $0800

; Bank 6, still INCBIN. CPU address while that bank is mapped.
DEF FarReload61D2 EQU $61D2

DEF BANK_RELOAD EQU $06
DEF WRAM_FRAME_TILES EQU $04

LoadBothVRAMBanks::
    call ParkSprites
    call TurnOffLCD
    ld hl, FarReload61D2
    ld e, BANK_RELOAD
    call CallBankedHL
    ld a, WRAM_FRAME_TILES
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    xor a
    ld [rVBK], a
    ld hl, $d000
    ld de, vTiles9000
    ld bc, PATTERN_BLOCK
    call CopyHLToDE
    ld a, $01
    ld [rVBK], a
    ld hl, $d800
    ld de, vTiles9000
    ld bc, PATTERN_BLOCK
    call CopyHLToDE
    ld hl, SetupWindowTilemap
    ld e, $00
    call CallBankedHL
    call TurnOnLCDIfOff
    pop de
    pop de
    pop de
    ld a, $0f
    ld [$c92c], a
    xor a
    ld [$c928], a
    ld [$c929], a
    ld a, $04
    ld [$c92a], a
    ret
