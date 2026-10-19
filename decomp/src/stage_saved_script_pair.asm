; Save the script pair into SRAM, maybe copy a map word, then call bank 7.
;
; SRAM is enabled. Bank wSRAMBank is selected with `add a, $00`, which
; keeps that bank byte and its flags. Nothing reads them. $01 is stored
; at $A017. The word at wScriptBaseLo is copied to sSavedScriptPair
; ($A015, then $A016). What $A017 means is still unknown.
;
; SRAM bank wSRAMBank + 1 is selected with `add a, $01`. The script byte
; at BC is consumed. A zero byte skips the copy. Any other byte copies
; the word at sMapWord2 ($A007) onto sMapWord1 ($A005), high byte first.
;
; BC is saved. Bank 7 is stored to wCurrentROMBank and rROMB0, then
; $40D4 is called. hScriptBank is read with the 3-byte form and written
; back to both bank registers. BC is restored and control jumps to
; INITIAL_SCRIPT_HANDLER ($0A66). SRAM stays enabled.
;
; rRAMG, hScriptBank, wCurrentROMBank, rROMB0, BANK_INIT, and
; INITIAL_SCRIPT_HANDLER are the names from reset.asm. rRAMB, wSRAMBank,
; and SRAM_ENABLE are the names from handle_start_press.asm.
; sSavedScriptPair is the name from load_sram_script_dispatch.asm.
; wScriptBaseLo and wScriptBaseHi are the names from opcode_02.asm.
; sMapWord1 and sMapWord2 are the names from draw_start_screen_map.asm.

; Written as $01 before the pair. Its role is still unknown.
DEF sUnknownA017 EQU $A017

StageSavedScriptPairThenBank7::
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld a, [wSRAMBank]
    add a, $00
    ld [rRAMB], a
    ld a, $01
    ld [sUnknownA017], a
    ld a, [wScriptBaseLo]
    ld [sSavedScriptPair], a
    ld a, [wScriptBaseHi]
    ld [sSavedScriptPair + 1], a
    ld a, [wSRAMBank]
    add a, $01
    ld [rRAMB], a
    ld a, [bc]
    inc bc
    and a
    jr z, .callBank7

    ld a, [sMapWord2 + 1]
    ld [sMapWord1 + 1], a
    ld a, [sMapWord2]
    ld [sMapWord1], a

.callBank7:
    push bc
    ld a, BANK_INIT
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call StoreSramBankFlagThenMirror
    ld a, [hScriptBank]
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    pop bc
    jp INITIAL_SCRIPT_HANDLER
