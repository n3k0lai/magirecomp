; Bank 4 at $6277. LcdOffSetup calls this while $C9BB is zero, after
; CopyC7ABToCC02 and before the copies at $624E.
;
; WRAM bank 6 is selected and remembered in wCurrentWRAMBank. VRAM bank 0
; is selected with the 3-byte store. CopyHLToDE then copies $1000 bytes
; from $8000 to $D000. $8000 is the whole $8000 pattern table (256 tiles).
; $D000 is the start of the selected WRAM bank. A later routine in this
; bank, still INCBIN, copies those bytes back from $D000 to $8000.
;
; wCurrentWRAMBank and rSVBK are the names from timer_overflow.asm.
; rVBK is the name from setup_window.asm. CopyHLToDE is already source.

; Whole $8000 pattern table.
DEF vPattern8000 EQU $8000
DEF PATTERN_8000_BYTES EQU $1000

; Start of the selected WRAM bank.
DEF WRAM_BANK_BASE EQU $D000
DEF WRAM_PATTERN_8000 EQU $06

CopyVRAM8000ToWRAM6::
    ld a, WRAM_PATTERN_8000
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    xor a
    ld [rVBK], a
    ld hl, vPattern8000
    ld de, WRAM_BANK_BASE
    ld bc, PATTERN_8000_BYTES
    call CopyHLToDE
    ret
