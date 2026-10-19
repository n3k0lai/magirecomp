; Script opcode $9D. DispatchScriptOpcode jumps here.
;
; Bit 7 of hScriptBank forces the next handler to run from bank 1.
; hScriptHandler is set to $4972 with the 3-byte form, then this returns
; to MapScriptBankAndCall. That continuation, still INCBIN, resumes opcode
; dispatch once [$C6EE] is 2.
;
; hScriptBank and hScriptHandler are the names from reset.asm. wUnknownC6EE
; is the name from setup_window.asm.

; Bank 1 continuation. Resumes dispatch when [$C6EE] is 2. Still INCBIN.
DEF Opcode9DContinue EQU $4972

Opcode9D::
    ld hl, hScriptBank
    set 7, [hl]
    ld a, LOW(Opcode9DContinue)
    ld [hScriptHandler], a
    ld a, HIGH(Opcode9DContinue)
    ld [hScriptHandler + 1], a
    ret
