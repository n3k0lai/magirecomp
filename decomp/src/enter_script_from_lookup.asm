; Script handler planted by SRAMLookupInstallScript when the $1234 lookup
; leaves DE nonzero. BC is the record address stored as hScriptPtr.
;
; The first byte is a ROM bank. It is saved in E and written to hScriptBank
; with the three-byte form. The next two bytes are a little-endian pointer,
; low then high, and become BC.
;
; That bank is stored in wCurrentROMBank and written to rROMB0, both with
; the three-byte form. Control leaves through DispatchScriptOpcode, which
; reads the opcode at the new BC.
;
; hScriptBank, wCurrentROMBank, and rROMB0 are the names from reset.asm.

EnterScriptFromLookup::
    ld a, [bc]
    ld e, a
    ld [hScriptBank], a
    inc bc
    ld a, [bc]
    ld l, a
    inc bc
    ld a, [bc]
    ld b, a
    ld c, l
    ld a, e
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    jp DispatchScriptOpcode
