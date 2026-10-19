; Script step at $1EE7. BC is the script pointer. The next byte is
; loaded into E and BC moves one past it. That pointer is not written
; back to hScriptPtr. ROM bank 1 is stored in wCurrentROMBank and
; selected with rROMB0, then control jumps to $45E6 in that bank.
;
; $45E6 is still INCBIN. What it does with E and BC is unknown.
; wCurrentROMBank and rROMB0 are the names from reset.asm.

StageScriptByteEnterBank1::
    ld a, [bc]
    inc bc
    ld e, a
    ld a, $01
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    jp ApplyScriptByteToC12E
