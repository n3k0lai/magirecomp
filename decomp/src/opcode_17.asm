; Script opcode $17. DispatchScriptOpcode jumps here with BC still pointing
; at the bytes after the opcode.
;
; HL is set to $FF8C and control leaves through
; jp CopySixScriptBytesFromOffset3 ($0E09). That adds 3 and copies the next
; six script bytes to $FF8F through $FF94: hObjectFineX, hObjectFineY,
; hObjectCellX, hObjectCellY, and the little-endian word at $FF93. What
; $FF8C itself holds is still unknown. hObjectFineX and the three bytes
; after it are the names from queue_sprite_list.asm. The word at $FF93 is
; the name used in copy_six_script_bytes.asm.
; CopySixScriptBytesFromOffset3 is the label from that file. BC is left on
; the following opcode.

Opcode17::
    ld hl, $FF8C
    jp CopySixScriptBytesFromOffset3
