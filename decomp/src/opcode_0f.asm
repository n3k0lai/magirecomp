; Script opcode $0F. DispatchScriptOpcode jumps here with BC still pointing
; at the bytes after the opcode.
;
; The operand is a slot index. LookupScriptIndexPointer doubles it and
; returns the record pointer in HL. Five bytes into that record, the next
; four bytes are copied to hObjectCellX, hObjectCellY, and the little-endian
; word at $FF93. hObjectFineX and hObjectFineY are both set to 8 first.
; What those record fields mean is still unknown. hObjectFineX and the three
; bytes after it are the names from queue_sprite_list.asm. The word at $FF93
; is the name used in copy_six_script_bytes.asm.
;
; Control leaves through jp DispatchScriptOpcode. BC is left on the
; following opcode. HL is left one byte past the copied field.

Opcode0F::
    call LookupScriptIndexPointer
    ld de, $0005
    add hl, de
    ld a, $08
    ldh [hObjectFineX], a
    ld a, $08
    ldh [hObjectFineY], a
    ld a, [hl+]
    ldh [hObjectCellX], a
    ld a, [hl+]
    ldh [hObjectCellY], a
    ld a, [hl+]
    ldh [$ff93], a
    ld a, [hl+]
    ldh [$ff94], a
    jp DispatchScriptOpcode
