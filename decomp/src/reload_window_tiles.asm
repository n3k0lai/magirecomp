; Bank 4 at $54D8. CopiedBlockWindowChoice jumps here when the choice
; is $FE, or when a choice other than 0 or 4 leaves $CD49 nonzero. The
; jump does not push a return, so the ret below returns to the caller of
; that wait. This bank stays mapped. The routine does not write rROMB0.
;
; Sprites are parked and the LCD is turned off. RestoreVRAMBank1Tiles in
; bank 6 runs through CallBankedHL, which maps bank 6 and restores this
; bank. WRAM bank 4 is stored at wCurrentWRAMBank and selected with the
; ldh form of rSVBK. With the LCD off, $800 bytes at $D000 are copied to
; $9000 in VRAM bank 0, then $800 bytes at $D800 are copied to $9000 in
; VRAM bank 1. $9000 is tile indices 0-127 of the $8800 pattern table.
; Those two blocks are the whole of WRAM bank 4. The stores to rVBK are
; the 3-byte form.
;
; SetupWindowTilemap then runs with ROM bank 0 mapped. CallBankedHL maps
; bank 4 again on return. TurnOnLCDIfOff turns the LCD on only when wLCDC
; is still 0.
;
; ParkSprites, TurnOffLCD, CallBankedHL, CopyHLToDE, and TurnOnLCDIfOff
; are already source. SetupWindowTilemap and RestoreVRAMBank1Tiles are
; already source. wCurrentWRAMBank and rSVBK are the names from
; timer_overflow.asm. rVBK is the name from setup_window.asm. The tile
; destination and length are the names from load_both_vram_banks.asm.

ReloadWindowTiles::
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
    ret
