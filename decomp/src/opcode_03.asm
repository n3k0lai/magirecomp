; Script opcode $03. DispatchScriptOpcode jumps here with BC still pointing
; at the bytes after the opcode.
;
; The first operand is an index. LookupIndexedPointer doubles it and returns
; the word from the table at $0303 in HL. Five bytes into that record, byte 5
; is added to the third operand and byte 6 to the second. That pair is pushed
; for the bank 1 continuation.
;
; The next script word is added to the word at record offset 7. The following
; operand is stored at that address in WRAM bank 5, and the operand after it
; at the same address in WRAM bank 3. $C937 mirrors rSVBK; both names are
; from timer_overflow.asm, which is assembled later, so the addresses are
; written out here.
;
; BC, now past those operands, is stored at hScriptPtr with the 3-byte form,
; high byte first. hScriptHandler is set to DispatchScriptOpcode, also the
; 3-byte form. The adjusted pair is popped into DE, bank 1 is mapped, and
; control leaves through jp $4617. HL still points at the address just
; written. What the continuation does with DE and HL is still unknown.
;
; hScriptPtr, hScriptHandler, wCurrentROMBank, and rROMB0 are the names from
; reset.asm. SCRIPT_OPCODE_BANK is the name from dispatch_script_opcode.asm.

; Bank 0, still INCBIN. Reads one script byte as an index and returns a pointer.
DEF LookupIndexedPointer EQU $0DFB

; Bank 1, still INCBIN. CPU address while SCRIPT_OPCODE_BANK is mapped.
DEF Opcode03Continue EQU $4617

; Shadow of rSVBK. Defined again later as wCurrentWRAMBank.
DEF wWRAMBankMirror EQU $C937

Opcode03::
    call LookupIndexedPointer
    ld de, $0005
    add hl, de
    ld a, [hl+]
    ld d, a
    ld a, [bc]
    ld e, a
    inc bc
    ld a, [hl+]
    add e
    ld e, a
    ld a, [bc]
    inc bc
    add d
    ld d, a
    push de
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
    ld a, $05
    ld [wWRAMBankMirror], a
    ldh [$ff70], a
    ld a, [bc]
    inc bc
    ld [hl], a
    ld a, $03
    ld [wWRAMBankMirror], a
    ldh [$ff70], a
    ld a, [bc]
    inc bc
    ld [hl], a
    ld a, b
    ld [hScriptPtr + 1], a
    ld a, c
    ld [hScriptPtr], a
    ld a, LOW(DispatchScriptOpcode)
    ld [hScriptHandler], a
    ld a, HIGH(DispatchScriptOpcode)
    ld [hScriptHandler + 1], a
    pop de
    ld a, SCRIPT_OPCODE_BANK
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    jp Opcode03Continue
