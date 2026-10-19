; Bank 4 at $624E. LcdOffSetup calls this while $C9BB is zero, after
; CopyVRAM8000ToWRAM6.
;
; WRAM bank 4 is selected and remembered in wCurrentWRAMBank. VRAM bank 0
; is selected with the 3-byte store. CopyHLToDE copies $800 bytes from
; $9000 to $D000. VRAM bank 1 is then selected the same way, and $800
; bytes are copied from $9000 to $D800. $9000 is the second pattern table
; (128 tiles). $D000 and $D800 sit in the selected WRAM bank.
;
; wCurrentWRAMBank and rSVBK are the names from timer_overflow.asm.
; rVBK is the name from setup_window.asm. CopyHLToDE is already source.

; Second pattern table, 128 tiles.
DEF vPattern9000 EQU $9000
DEF PATTERN_9000_BYTES EQU $0800

; Copies land in WRAM bank 4.
DEF WRAM_PATTERN_9000 EQU $04
DEF WRAM_PATTERN_9000_BANK0 EQU $D000
DEF WRAM_PATTERN_9000_BANK1 EQU $D800

CopyVRAM9000ToWRAM4::
    ld a, WRAM_PATTERN_9000
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    xor a
    ld [rVBK], a
    ld hl, vPattern9000
    ld de, WRAM_PATTERN_9000_BANK0
    ld bc, PATTERN_9000_BYTES
    call CopyHLToDE
    ld a, $01
    ld [rVBK], a
    ld hl, vPattern9000
    ld de, WRAM_PATTERN_9000_BANK1
    ld bc, PATTERN_9000_BYTES
    call CopyHLToDE
    ret
