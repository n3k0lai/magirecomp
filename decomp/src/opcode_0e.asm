; Script opcode $0E. DispatchScriptOpcode jumps here with BC still pointing
; at the bytes after the opcode.
;
; HL is set to $FF8C and control leaves through jp Opcode04AddWord ($0B75).
; That is the same path as opcode $04 with the record pointer already chosen:
; the word at record offset 7 is adjusted, then one operand is stored in WRAM
; bank 6 and the next in WRAM bank 4. LookupIndexedPointer is skipped. What
; $FF8C itself holds is still unknown. Opcode04AddWord is the label from
; opcode_04.asm.

Opcode0E::
    ld hl, $FF8C
    jp Opcode04AddWord
