; Script opcode $07. DispatchScriptOpcode jumps here with BC still pointing
; at the bytes after the opcode.
;
; The first operand is an index. LookupIndexedPointer doubles it and returns
; the word from the table at $0303 in HL. The first record byte is skipped.
; The next two script bytes are stored in the following two record bytes.
; BC is left on the following opcode. Control returns through
; jp DispatchScriptOpcode. What those two fields mean is still unknown.
;
; The first store is also an entry. A caller still in INCBIN reaches it with
; A, HL, and BC already set, stores A, then copies one more script byte the
; same way, and also returns through DispatchScriptOpcode.
;
; LookupIndexedPointer is the name from opcode_03.asm.

Opcode07::
    call LookupIndexedPointer
    inc hl
    ld a, [bc]
    inc bc
Opcode07StoreByte::
    ld [hl+], a
    ld a, [bc]
    inc bc
    ld [hl+], a
    jp DispatchScriptOpcode
