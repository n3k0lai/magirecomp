; Script opcode $0A. DispatchScriptOpcode jumps here with BC still pointing
; at the bytes after the opcode.
;
; The first operand is a slot index. LookupScriptIndexPointer returns that
; record in HL. The next script byte is stored at record offset $09, and HL
; is left on the following record byte. BC is left on the following opcode.
; Control returns through jp DispatchScriptOpcode. What offset $09 means is
; still unknown.
;
; Two earlier points are also entries. A caller still in INCBIN can arrive
; at the add with HL and DE already set, or at the load with HL and BC
; already set. Both continue into the same store and the same return.

Opcode0A::
    call LookupScriptIndexPointer
    ld de, $0009
Opcode0AAddOffset::
    add hl, de
Opcode0AStoreByte::
    ld a, [bc]
    ld [hl+], a
    inc bc
    jp DispatchScriptOpcode
