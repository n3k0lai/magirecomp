; Copy a script bank and pointer from bank $21 into the third script record.
;
; The current bank is not saved. Bank $21 is stored in wCurrentROMBank and
; written to rROMB0, then three bytes are copied from HL. They land at
; $C714-$C716: the bank and the little-endian pointer of the seven-byte
; record FinishFrame runs there. Callers write the handler at $C717
; themselves. Bank 1, BANK_POINTERS from default_state.asm, is mapped the
; same way before returning. HL is three past the source.
;
; $C714 is wThirdScriptRecord in setup_command_4d.asm. wCurrentROMBank and
; rROMB0 are the names from reset.asm. BANK_BYTE_SOURCE is the name from
; read_bank21_byte.asm.

ReadBank21ScriptHead::
    ld a, BANK_BYTE_SOURCE
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    ld a, [hl+]
    ld [$c714], a
    ld a, [hl+]
    ld [$c715], a
    ld a, [hl+]
    ld [$c716], a
    ld a, BANK_POINTERS
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    ret
