; Bank 3 at $7637. DispatchArmedChoice jumps here after $521A stores
; the choice byte. StepFeChoiceByCce3 jumps here when $CCE3 is already
; 3. The copied-block choice loop jumps here for $FE and $0D.
;
; Sprites are parked and the LCD is turned off. Bank 6's
; RestoreVRAMBank1Tiles runs through CallBankedHL, which maps bank 6
; and restores the previous bank. WRAM bank 4 is selected and remembered
; in wCurrentWRAMBank. With the LCD off, $800 bytes at $D000 are copied
; to $9000 in VRAM bank 0, then $800 bytes at $D800 are copied to $9000
; in VRAM bank 1. $9000 is tile indices 0-127 of the $8800 pattern
; table. Those two blocks are the whole of WRAM bank 4. The stores to
; rVBK are the 3-byte form. Selecting rSVBK is ldh.
;
; SetupWindowTilemap runs in bank 0, then the LCD is turned on if it
; was left off, and this returns to the caller of the choice loop.
;
; ParkSprites, TurnOffLCD, CallBankedHL, CopyHLToDE, and TurnOnLCDIfOff
; are the names from bank 0. SetupWindowTilemap is the name from
; setup_window.asm. RestoreVRAMBank1Tiles is already source in bank 6.
; wCurrentWRAMBank and rSVBK are the names from timer_overflow.asm.
; rVBK is the name from setup_window.asm.

; vTiles9000, PATTERN_BLOCK, BANK_RELOAD, and WRAM_FRAME_TILES are the
; names from load_both_vram_banks.asm. VRAM_BANK_1 is the name from
; copy_choice_record_tiles.asm. rSVBK and wCurrentWRAMBank are the names
; from match_wram5_script_byte.asm.

DEF BANK_SETUP_WINDOW EQU $00

ReloadChoiceFrame::
    call ParkSprites
    call TurnOffLCD
    ld hl, RestoreVRAMBank1Tiles
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
    ld a, VRAM_BANK_1
    ld [rVBK], a
    ld hl, $d800
    ld de, vTiles9000
    ld bc, PATTERN_BLOCK
    call CopyHLToDE
    ld hl, SetupWindowTilemap
    ld e, BANK_SETUP_WINDOW
    call CallBankedHL
    call TurnOnLCDIfOff
    ret
