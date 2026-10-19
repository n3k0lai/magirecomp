; Script opcode $0D. DispatchScriptOpcode jumps here with BC still pointing
; at the bytes after the opcode.
;
; HL is set to $FF8C and control leaves through jp to the instruction after
; Opcode03's lookup call ($0B25, `ld de, $0005`). That is the same path as
; opcode $03 with the record pointer already chosen: five bytes in is
; hObjectFineX + 2 ($FF91). The lookup at LookupIndexedPointer is skipped.
; What $FF8C itself holds is still unknown. hObjectFineX is the name from
; queue_sprite_list.asm. Opcode03 is the label from opcode_03.asm.

Opcode0D::
    ld hl, $FF8C
    jp Opcode03 + 3
