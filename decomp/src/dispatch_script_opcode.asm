; Dispatch one script opcode and jump to its handler.
;
; MapScriptBankAndCall leaves BC as the script pointer at hScriptPtr and
; enters here through hScriptHandler. The byte at BC is the opcode. BC moves
; past it and is written back to hScriptPtr with the 3-byte form.
;
; The opcode is doubled into DE, including the carry when it is $80 or more,
; and used as an index into the pointer table at $42C3. That read runs in
; bank 1. The script bank at hScriptBank is then written back to
; wCurrentROMBank and rROMB0. Both of those stores, and the stores of the
; fetched pointer into hScriptHandler, are the 3-byte form.
;
; Control leaves through jp hl. The handler address is also left in
; hScriptHandler, so a later pass through MapScriptBankAndCall reenters it.
; wCurrentROMBank, rROMB0, hScriptBank, hScriptPtr, and hScriptHandler are
; the names from reset.asm.

; Pointer table in bank 1. Two bytes per opcode. Still INCBIN.
DEF ScriptOpcodeTable EQU $42C3

DEF SCRIPT_OPCODE_BANK EQU $01

DispatchScriptOpcode::
    ld a, [bc]
    inc bc
    add a
    ld e, a
    ld d, $00
    rl d
    ld hl, hScriptPtr
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld hl, ScriptOpcodeTable
    add hl, de
    ld a, SCRIPT_OPCODE_BANK
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld a, [hScriptBank]
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    ld a, h
    ld [hScriptHandler + 1], a
    ld a, l
    ld [hScriptHandler], a
    jp hl
