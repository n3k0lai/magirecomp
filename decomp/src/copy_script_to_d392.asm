; Copies A script bytes from BC to $D392 in WRAM bank 7, then plants the
; initial script handler and maps ROM bank 2.
;
; BC is the source pointer (the script operand stream). A is the byte
; count. Those bytes land at $D392 while WRAM bank 7 is selected, so the
; stores are in that bank. CopyHLToDE leaves HL one past the last byte
; copied. That pointer is written back to hScriptPtr. hScriptHandler
; becomes INITIAL_SCRIPT_HANDLER ($0A66). ROM bank 2 is stored to
; wCurrentROMBank and rROMB0. The caller returns into that bank.
;
; hScriptPtr, hScriptHandler, INITIAL_SCRIPT_HANDLER, wCurrentROMBank, and
; rROMB0 are the names from reset.asm. wCurrentWRAMBank and rSVBK are the
; names from timer_overflow.asm. CopyHLToDE is already source.

; WRAM bank that holds the $D392 script copy.
DEF SCRIPT_COPY_WRAM_BANK EQU $07

; ROM bank mapped for the caller after the handler is planted.
DEF SCRIPT_COPY_ROM_BANK EQU $02

CopyScriptToD392::
    ld l, c
    ld h, b
    ld de, $D392
    ld c, a
    ld b, $00
    ld a, SCRIPT_COPY_WRAM_BANK
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    call CopyHLToDE
    ld a, h
    ldh [hScriptPtr + 1], a
    ld a, l
    ldh [hScriptPtr], a
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ldh [hScriptHandler + 1], a
    ld a, SCRIPT_COPY_ROM_BANK
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    ret
