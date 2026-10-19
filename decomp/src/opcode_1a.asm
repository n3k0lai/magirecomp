; Script opcode $1A. DispatchScriptOpcode jumps here with BC still pointing
; at the bytes after the opcode.
;
; HL is the little-endian word at $FF93, the field opcode $0F copies. Both
; loads are the 3-byte form, high byte first. WRAM bank 3 is stored in
; wCurrentWRAMBank and selected with rSVBK, and the byte at that pointer is
; compared with the next script byte. A mismatch returns without advancing
; BC, and leaves bank 3 mapped. A match steps BC past the operand and
; resumes opcode dispatch.
;
; wCurrentWRAMBank and rSVBK are the names from timer_overflow.asm.

Opcode1A::
    ld a, [$FF94]
    ld h, a
    ld a, [$FF93]
    ld l, a
    ld a, $03
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld e, [hl]
    ld a, [bc]
    cp e
    ret nz
    inc bc
    jp DispatchScriptOpcode
