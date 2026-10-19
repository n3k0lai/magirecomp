; Bank 3 at $567B. ServiceWindowChoice jumps here when the choice is
; $FE, or when the $CD69 result is neither 0, 1, nor 3. This bank stays
; mapped. The routine does not write rROMB0. The jump replaces that
; caller, so the ret below returns to whoever called ServiceWindowChoice.
;
; Sprites are parked and the LCD is turned off. Bank 6's
; RestoreVRAMBank1Tiles runs through CallBankedHL, which maps bank 6 and
; restores this bank. WRAM bank 4 is stored at wCurrentWRAMBank and
; selected with rSVBK. With the LCD off, $800 bytes at $D000 are copied
; to $9000 in VRAM bank 0, then $800 bytes at $D800 are copied to $9000
; in VRAM bank 1. $9000 is tile indices 0-127 of the $8800 pattern table.
; Those two blocks are the whole of WRAM bank 4. The stores to rVBK are
; the 3-byte form. Selecting rSVBK is ldh.
;
; SetupWindowTilemap then runs in bank 0, and the LCD is turned on if it
; was left off.
;
; ParkSprites, TurnOffLCD, CallBankedHL, CopyHLToDE, and TurnOnLCDIfOff
; are the names from bank 0. RestoreVRAMBank1Tiles is already source in
; bank 6. SetupWindowTilemap is the name from setup_window.asm.
; wCurrentWRAMBank and rSVBK are the names from timer_overflow.asm.
; rVBK is the name from setup_window.asm. vTiles9000, PATTERN_BLOCK,
; and WRAM_FRAME_TILES are the names from load_both_vram_banks.asm.

DEF BANK_RESTORE_VRAM1 EQU $06

LeaveWindowChoiceReloadTiles::
    call ParkSprites
    call TurnOffLCD
    ld hl, RestoreVRAMBank1Tiles
    ld e, BANK_RESTORE_VRAM1
    call CallBankedHL
    ld a, WRAM_FRAME_TILES
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    xor a
    ld [rVBK], a
    ld hl, $D000
    ld de, vTiles9000
    ld bc, PATTERN_BLOCK
    call CopyHLToDE
    ld a, $01
    ld [rVBK], a
    ld hl, $D800
    ld de, vTiles9000
    ld bc, PATTERN_BLOCK
    call CopyHLToDE
    ld hl, SetupWindowTilemap
    ld e, $00
    call CallBankedHL
    call TurnOnLCDIfOff
    ret
