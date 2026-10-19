; Script opcode $04. DispatchScriptOpcode jumps here with BC still pointing
; at the bytes after the opcode.
;
; The first operand is an index. LookupIndexedPointer doubles it and returns
; the word from the table at $0303 in HL. The next script word is added to
; the word at record offset 7. The following operand is stored at that
; address in WRAM bank 6, and the operand after it at the same address in
; WRAM bank 4. BC is left on the following opcode.
;
; $0C49 enters at Opcode04AddWord with HL already $FF8C, skipping the lookup.
; Control returns through jp DispatchScriptOpcode. What reads the two stored
; bytes is still unknown.
;
; LookupIndexedPointer and wWRAMBankMirror are the names from opcode_03.asm.
; $FF70 is rSVBK. wWRAMBankMirror is the shadow defined there as $C937.

Opcode04::
    call LookupIndexedPointer
Opcode04AddWord::
    ld de, $0007
    add hl, de
    ld a, [bc]
    ld e, a
    inc bc
    ld a, [bc]
    ld d, a
    inc bc
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld a, $06
    ld [wWRAMBankMirror], a
    ldh [$ff70], a
    ld a, [bc]
    inc bc
    ld [hl], a
    ld a, $04
    ld [wWRAMBankMirror], a
    ldh [$ff70], a
    ld a, [bc]
    inc bc
    ld [hl], a
    jp DispatchScriptOpcode
