; Script step at $1DE1. BC is the script pointer.
;
; The first word is left in DE for the bank 1 continuation. The next word
; is an address in HL. DE is pushed across the stores.
;
; The next script byte is read while WRAM bank 6 is selected, then written
; to HL in bank 5. The byte after that is read while bank 4 is selected,
; then written to the same address in bank 3. $C937 mirrors rSVBK. That
; name is defined later, in timer_overflow.asm, so the store uses
; wWRAMBankMirror from opcode_03.asm and the select is the raw $FF70.
;
; DE is popped. BC, now past those six bytes, is stored at hScriptPtr with
; the 3-byte form, high byte first. hScriptHandler becomes
; DispatchScriptOpcode ($0A66), also the 3-byte form. Bank 1 is mapped,
; and control leaves through jp Opcode03Continue. What that continuation
; does with DE and HL is still unknown.
;
; hScriptPtr, hScriptHandler, wCurrentROMBank, and rROMB0 are the names
; from reset.asm. DispatchScriptOpcode and SCRIPT_OPCODE_BANK are the
; names from dispatch_script_opcode.asm. Opcode03Continue is the name
; from opcode_03.asm. Nothing here calls or jumps into an INCBIN.

WriteScriptBytesThroughBanks6And4::
    ld a, [bc]
    ld e, a
    inc bc
    ld a, [bc]
    ld d, a
    inc bc
    ld a, [bc]
    ld l, a
    inc bc
    ld a, [bc]
    ld h, a
    inc bc
    push de
    ld a, $06
    ld [wWRAMBankMirror], a
    ldh [$ff70], a
    ld a, [bc]
    ld e, a
    inc bc
    ld a, $05
    ld [wWRAMBankMirror], a
    ldh [$ff70], a
    ld [hl], e
    ld a, $04
    ld [wWRAMBankMirror], a
    ldh [$ff70], a
    ld a, [bc]
    ld e, a
    inc bc
    ld a, $03
    ld [wWRAMBankMirror], a
    ldh [$ff70], a
    ld [hl], e
    pop de
    ld a, b
    ld [hScriptPtr + 1], a
    ld a, c
    ld [hScriptPtr], a
    ld a, LOW(DispatchScriptOpcode)
    ld [hScriptHandler], a
    ld a, HIGH(DispatchScriptOpcode)
    ld [hScriptHandler + 1], a
    ld a, SCRIPT_OPCODE_BANK
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    jp Opcode03Continue
