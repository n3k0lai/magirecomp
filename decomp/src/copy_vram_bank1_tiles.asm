; Select VRAM bank 1 and copy 512 bytes from tile data at $8E00 to $CA02.
;
; $8E00 is tiles $E0-$FF of the $8000 pattern table (32 tiles, 16 bytes
; each). HL is the source and BC is the destination. $6170, still INCBIN
; in this bank, copies D outer rows of E bytes: here $20 by $10.
;
; The store to rVBK is the 3-byte form. rVBK is the name from
; setup_window.asm. What the $CA02 buffer is used for is still unknown.

; 512-byte WRAM destination. Role still unknown.
DEF wUnknownCA02 EQU $CA02

; First byte of tiles $E0-$FF in the $8000 pattern table.
DEF vTilesE0 EQU $8E00

CopyVRAMBank1Tiles::
    ld a, $01
    ld [rVBK], a
    ld bc, wUnknownCA02
    ld hl, vTilesE0
    call $6170
    ret
