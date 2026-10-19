; Script tail at $2801. BC is the script pointer.
;
; The first word is a WRAM address in HL. The next byte is the WRAM bank:
; it is stored at $C937 and selected with rSVBK. `ld a, a` keeps that bank
; in A; it is the 1-byte form, not a nop. The byte after the bank is stored
; at HL. BC is left one past that byte, and control jumps to
; DispatchScriptOpcode ($0A66).
;
; wWRAMBankMirror is the name from opcode_03.asm. rSVBK is defined later,
; in timer_overflow.asm, so the select is the raw $FF70.
; DispatchScriptOpcode is the name from dispatch_script_opcode.asm.

StoreScriptByteInWramBank::
    ld a, [bc]
    ld l, a
    inc bc
    ld a, [bc]
    ld h, a
    inc bc
    ld a, [bc]
    inc bc
    ld a, a
    ld [wWRAMBankMirror], a
    ldh [$ff70], a
    ld a, [bc]
    ld [hl], a
    inc bc
    jp DispatchScriptOpcode

StoreScriptByteInWramBankEnd:
