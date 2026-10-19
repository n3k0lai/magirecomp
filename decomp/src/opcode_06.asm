; Script opcode $06. DispatchScriptOpcode jumps here with BC still pointing
; at the bytes after the opcode.
;
; The first operand is an index. LookupIndexedPointer doubles it and returns
; the word from the table at $0303 in HL. That record's bytes at offsets 3
; and 4 are set to $08. The next operand is a second index. Four bytes from
; offset 5 of the second record are copied onto offset 5 of the first.
; BC is left on the following opcode. Control returns through
; jp DispatchScriptOpcode. What the copied fields mean is still unknown.
;
; $0BC5 is the store of the second copied byte. Bank $62, still INCBIN, enters
; there with `call nz` when A, DE, and HL are already set. That caller stores
; A, then copies two more bytes the same way, and also returns through
; DispatchScriptOpcode.
;
; LookupIndexedPointer is the name from opcode_03.asm.

Opcode06::
    call LookupIndexedPointer
    ld de, $0003
    add hl, de
    push hl
    call LookupIndexedPointer
    ld de, $0005
    add hl, de
    pop de
    ld a, $08
    ld [de], a
    inc de
    ld a, $08
    ld [de], a
    inc de
    ld a, [hl+]
    ld [de], a
    inc de
    ld a, [hl+]
Opcode06StoreLoadedByte::
    ld [de], a
    inc de
    ld a, [hl+]
    ld [de], a
    inc de
    ld a, [hl+]
    ld [de], a
    jp DispatchScriptOpcode
