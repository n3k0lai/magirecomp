; Script path at $14AD. The caller is still INCBIN.
;
; SRAM is enabled in the bank at wSRAMBank, LookupWordAt1234 runs, and SRAM
; is disabled. That call reads the script byte at BC, leaves a word in DE,
; and leaves BC just past the lookup operand. `add a, $00` keeps the SRAM
; bank byte and its flags; nothing reads them.
;
; BC then walks 7-byte records:
;   bank, inclusive low word, inclusive high word, little-endian pointer
; A bank of $FF ends the table. BC is left on the next script byte and
; control jumps to INITIAL_SCRIPT_HANDLER.
;
; Any other bank is held in L. DE below the low word skips the four bytes
; still in the record. DE above the high word skips the pointer. Both ends
; are inclusive. A match loads that pointer into BC, stores L in hScriptBank
; and wCurrentROMBank, maps that bank through rROMB0, and jumps to
; INITIAL_SCRIPT_HANDLER. The second `ld a, l` is in the ROM.
;
; rRAMG, rROMB0, hScriptBank, wCurrentROMBank, and INITIAL_SCRIPT_HANDLER
; are the names from reset.asm. rRAMB, wSRAMBank, and SRAM_ENABLE are the
; names from handle_start_press.asm. LookupWordAt1234 is the name from
; sram_lookup_install_script.asm.

DEF RANGE_END EQU $FF

SelectScriptByLookupRange::
    ld a, [wSRAMBank]
    add a, $00
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    call LookupWordAt1234
    xor a
    ld [rRAMG], a
    jr .readBank

.skipFour:
    inc bc
    inc bc
.skipTwo:
    inc bc
    inc bc
    pop hl

.readBank:
    ld a, [bc]
    ld l, a
    inc bc
    cp RANGE_END
    jr nz, .testLow
    jp INITIAL_SCRIPT_HANDLER

.testLow:
    push hl
    ld a, [bc]
    ld l, a
    inc bc
    ld a, [bc]
    ld h, a
    inc bc
    ld a, e
    sub l
    ld a, d
    sbc h
    jr nc, .testHigh
    jr .skipFour

.testHigh:
    ld a, [bc]
    ld l, a
    inc bc
    ld a, [bc]
    ld h, a
    inc bc
    ld a, l
    sub e
    ld a, h
    sbc d
    jr nc, .matched
    jr .skipTwo

.matched:
    pop hl
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
