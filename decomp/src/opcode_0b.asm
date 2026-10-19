; Script opcode $0B. DispatchScriptOpcode jumps here with BC still pointing
; at the bytes after the opcode.
;
; The first operand is a slot index. LookupScriptIndexPointer returns that
; record in HL. When bit 6 of the first record byte is clear, BC is saved,
; the record pointer is passed in BC, and bank 1 is mapped. $403D, still
; INCBIN in that bank, is called. hScriptBank is then written back to
; wCurrentROMBank and rROMB0 with the 3-byte load, and BC is restored.
; Bit 6 set skips that call. Either way, bit 7 of the same record byte is
; cleared. What those two bits mean is still unknown.
;
; A caller still in INCBIN can enter at Opcode0BMapBank1 with HL already
; the record pointer. That entry still pops BC, so the caller has pushed
; the value to restore. Control returns through jp DispatchScriptOpcode.
;
; wCurrentROMBank, rROMB0, and hScriptBank are the names from reset.asm.

Opcode0B::
    call LookupScriptIndexPointer
    bit 6, [hl]
    jr nz, Opcode0BClearBit7
    push bc
Opcode0BMapBank1::
    ld b, h
    ld c, l
    ld a, $01
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call TakePointerSlot
    ld a, [hScriptBank]
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    pop bc
Opcode0BClearBit7::
    res 7, [hl]
    jp DispatchScriptOpcode
