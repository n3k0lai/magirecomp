; Load a saved script from SRAM and jump to DispatchScriptOpcode.
;
; Selects SRAM bank wSRAMBank ($C727). `add a, $00` keeps that bank byte
; and its flags. Nothing reads them. SRAM is enabled, then five bytes are
; read. $A015 and $A016 land at wScriptPairLo and wScriptPairHi. $A012 is
; the script bank. $A013 and $A014 are a little-endian pointer. SRAM is
; disabled before the pointer is tested.
;
; A zero pointer leaves BC alone and jumps to DispatchScriptOpcode. A
; nonzero pointer stores the bank at hScriptBank, wCurrentROMBank, and
; rROMB0, then copies the pointer into BC. `ld a, a` keeps that bank in A
; between the HRAM store and the two ROM-bank stores. Both paths leave
; through jp DispatchScriptOpcode.
;
; The next routine, still INCBIN at $2035, jumps back here after a bank 7
; call. wScriptPairLo is the name from opcode_01.asm. rRAMG, hScriptBank,
; wCurrentROMBank, and rROMB0 are the names from reset.asm. wSRAMBank,
; rRAMB, and SRAM_ENABLE are the names from handle_start_press.asm.

; SRAM bank byte saved with the script. Still unknown besides this load.
DEF sSavedScriptBank EQU $A012

; Little-endian pointer. Zero means keep the incoming BC.
DEF sSavedScriptPtr EQU $A013

; Two bytes copied to $C9A1 and $C9A2 on every entry.
DEF sSavedScriptPair EQU $A015

LoadSRAMScriptAndDispatch::
    ld a, [$C727]
    add a, $00
    ld [$4000], a
    ld a, $0A
    ld [rRAMG], a
    ld a, [sSavedScriptPair]
    ld [wScriptPairLo], a
    ld a, [sSavedScriptPair + 1]
    ld [wScriptPairHi], a
    ld a, [sSavedScriptBank]
    ld e, a
    ld a, [sSavedScriptPtr]
    ld l, a
    ld a, [sSavedScriptPtr + 1]
    ld h, a
    xor a
    ld [rRAMG], a
    ld a, h
    or l
    jr z, .dispatch

    ld a, e
    ldh [hScriptBank], a
    ld a, a
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    ld c, l
    ld b, h
.dispatch:
    jp DispatchScriptOpcode
