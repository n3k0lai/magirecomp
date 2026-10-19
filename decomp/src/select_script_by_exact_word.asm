; Script path at $151F. The caller is still INCBIN.
;
; SRAM is enabled in the bank at wSRAMBank, LookupWordAt1234 runs, and SRAM
; is disabled. That call reads the script byte at BC, leaves a word in DE,
; and leaves BC just past the lookup operand. `add a, $00` keeps the SRAM
; bank byte and its flags; nothing reads them.
;
; BC then walks 5-byte records:
;   bank, low byte, high byte, little-endian pointer
; The low and high bytes must equal E and D. A bank of $FF ends the table.
; BC is left on the next script byte and control jumps to
; INITIAL_SCRIPT_HANDLER.
;
; A low-byte miss skips the three bytes still in the record. A high-byte
; miss skips the pointer. A match loads that pointer into BC, stores L in
; hScriptBank and wCurrentROMBank, maps that bank through rROMB0, and jumps
; to INITIAL_SCRIPT_HANDLER. The second `ld a, l` is in the ROM.
;
; rRAMG, rROMB0, hScriptBank, wCurrentROMBank, and INITIAL_SCRIPT_HANDLER
; are the names from reset.asm. rRAMB, wSRAMBank, and SRAM_ENABLE are the
; names from handle_start_press.asm. LookupWordAt1234 is the name from
; sram_lookup_install_script.asm.

DEF EXACT_END EQU $FF

SelectScriptByExactWord::
    ld a, [wSRAMBank]
    add a, $00
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    call LookupWordAt1234
    xor a
    ld [rRAMG], a
    jr .readBank

.skipThree:
    inc bc
.skipTwo:
    inc bc
    inc bc

.readBank:
    ld a, [bc]
    ld l, a
    inc bc
    cp EXACT_END
    jr nz, .testLow
    jp INITIAL_SCRIPT_HANDLER

.testLow:
    ld a, [bc]
    inc bc
    cp e
    jr nz, .skipThree

    ld a, [bc]
    inc bc
    cp d
    jr nz, .skipTwo

    ld a, [bc]
    ld e, a
    inc bc
    ld a, [bc]
    ld b, a
    ld c, e
    ld a, l
    ld [hScriptBank], a
    ld a, l
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    jp INITIAL_SCRIPT_HANDLER
