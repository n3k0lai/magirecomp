; Copy a length-prefixed block to $D000 and plant the script that follows.
;
; BC is a pointer. Three bytes are skipped, then a little-endian length is
; read into BC. The bytes after that word are copied to $D000. WRAM bank 6
; is stored at wCurrentWRAMBank and selected with rSVBK, and it stays
; selected. CopyHLToDE leaves HL one past the block; that pointer is saved
; at hScriptPtr and INITIAL_SCRIPT_HANDLER ($0A66) is saved at
; hScriptHandler. The four HRAM stores are ldh. BC is zero on return.
;
; wCurrentWRAMBank and rSVBK are the names from timer_overflow.asm.
; hScriptPtr, hScriptHandler, and INITIAL_SCRIPT_HANDLER are the names
; from reset.asm. CopyHLToDE is the routine at $07A0.

DEF WRAM_BLOCK_BANK EQU $06
DEF BLOCK_AT_D000 EQU $D000

CopyPrefixedBlockToD000::
    ld l, c
    ld h, b
    inc hl
    inc hl
    inc hl
    ld a, [hl+]
    ld c, a
    ld a, [hl+]
    ld b, a
    ld de, BLOCK_AT_D000
    ld a, WRAM_BLOCK_BANK
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    call CopyHLToDE
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler + 1], a
    ld a, h
    ldh [hScriptPtr + 1], a
    ld a, l
    ldh [hScriptPtr], a
    ret
