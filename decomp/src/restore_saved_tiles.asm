; Bank 4 at $62BE. DispatchNonzeroD016 calls this through CallBankedHL
; after TurnOffLCD, on the mode 3 path and on the shared path, before
; startup continues.
;
; RestoreVRAMBank1Tiles runs in bank 6. CopyHLToDE copies $40 bytes from
; $CC02 back to $C7AB, reversing CopyC7ABToCC02, then copies those same
; $40 bytes to $C72B. What the two blocks hold is still unknown. Bank 7
; then runs $445F and $44EA. Both are still INCBIN.
;
; WRAM bank 6 is selected and remembered in wCurrentWRAMBank. VRAM bank 0
; is selected with the 3-byte store. $1000 bytes at $D000 are copied to
; $8000, reversing CopyVRAM8000ToWRAM6. WRAM bank 4 is selected the same
; way. $800 bytes at $D000 are copied to $9000 in VRAM bank 0, then $800
; bytes at $D800 are copied to $9000 in VRAM bank 1, reversing
; CopyVRAM9000ToWRAM4.
;
; wCurrentWRAMBank and rSVBK are the names from timer_overflow.asm.
; rVBK is the name from setup_window.asm. CallBankedHL, CopyHLToDE,
; RestoreVRAMBank1Tiles, and the pattern-table constants are already source.

; Still INCBIN. Bank 7 is mapped before this call.
DEF Call_Bank7_44EA EQU $44EA

; $40-byte block CopyC7ABToCC02 wrote from $C7AB. Also copied to $C72B.
DEF SavedBlockCC02 EQU $CC02
DEF SavedBlockC7AB EQU $C7AB
DEF BlockC72B EQU $C72B
DEF SAVED_BLOCK_LEN EQU $0040

RestoreSavedTiles::
    ld hl, RestoreVRAMBank1Tiles
    ld e, $06
    call CallBankedHL
    ld hl, SavedBlockCC02
    ld de, SavedBlockC7AB
    ld bc, SAVED_BLOCK_LEN
    call CopyHLToDE
    ld hl, SavedBlockCC02
    ld de, BlockC72B
    ld bc, SAVED_BLOCK_LEN
    call CopyHLToDE
    ld hl, Call_Bank7_445F
    ld e, $07
    call CallBankedHL
    ld hl, Call_Bank7_44EA
    ld e, $07
    call CallBankedHL
    ld a, WRAM_PATTERN_8000
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    xor a
    ld [rVBK], a
    ld hl, WRAM_BANK_BASE
    ld de, vPattern8000
    ld bc, PATTERN_8000_BYTES
    call CopyHLToDE
    ld a, WRAM_PATTERN_9000
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    xor a
    ld [rVBK], a
    ld hl, WRAM_PATTERN_9000_BANK0
    ld de, vPattern9000
    ld bc, PATTERN_9000_BYTES
    call CopyHLToDE
    ld a, $01
    ld [rVBK], a
    ld hl, WRAM_PATTERN_9000_BANK1
    ld de, vPattern9000
    ld bc, PATTERN_9000_BYTES
    call CopyHLToDE
    ret
