; Script step at $18EC. BC is the script pointer.
; Reads a little-endian pointer into HL and advances BC past it.
; Pushes BC, then calls $2C97. HL is that pointer and BC is still the
; next script byte. $2C97 is still INCBIN. What it does with HL is
; still unknown.
;
; On return this copies hScriptBank into wCurrentROMBank and rROMB0
; (both stores and the load are the 3-byte form), restores BC, and
; jumps to INITIAL_SCRIPT_HANDLER ($0A66).
;
; hScriptBank, wCurrentROMBank, rROMB0, and INITIAL_SCRIPT_HANDLER are
; the names from reset.asm.

CallScriptPtrThenMapScriptBank::
    ld a, [bc]
    ld l, a
    inc bc
    ld a, [bc]
    ld h, a
    inc bc
    push bc
    call RunBank21ScriptList
    ld a, [hScriptBank]
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    pop bc
    jp INITIAL_SCRIPT_HANDLER
