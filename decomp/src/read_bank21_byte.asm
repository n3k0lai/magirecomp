; Read one byte from HL while ROM bank $21 is mapped.
;
; The current bank is not saved. Bank $21 is stored in wCurrentROMBank and
; written to rROMB0, then [hl+] is read. That byte is held in E because the
; following stores overwrite A. Bank 1, BANK_POINTERS from default_state.asm,
; is mapped the same way, and the byte is returned in A. HL is one past the
; byte. wCurrentROMBank and rROMB0 are the names from reset.asm.

DEF BANK_BYTE_SOURCE EQU $21

ReadBank21Byte::
    ld a, BANK_BYTE_SOURCE
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    ld a, [hl+]
    ld e, a
    ld a, BANK_POINTERS
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    ld a, e
    ret
