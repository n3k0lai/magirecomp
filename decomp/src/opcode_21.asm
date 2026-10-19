; Script opcode $21. DispatchScriptOpcode jumps here with BC still pointing
; at the bytes after the opcode. This opcode takes no operand, so BC is left
; where it was.
;
; Opcode $20's countdown arm falls into this routine when wSoundCountdown
; ($C924) is already nonzero. That jr lands on the second byte of
; `jp DispatchScriptOpcode`, so `ld h, [hl]` and `ld a, [bc]` run and then
; this opcode.
;
; wSoundRequest ($C91F) is set to $01. SelectSoundCommand treats a leftover
; nonzero request (bits 1 and 2 clear) as the sound command at $06FC
; (SoundRequestBit1). Bit 1 also writes $FF to wSoundIndex in the selector;
; this value does not. Control returns through jp DispatchScriptOpcode.
;
; wSoundRequest is the name from select_sound_command.asm.

Opcode21::
    ld a, $01
    ld [wSoundRequest], a
    jp DispatchScriptOpcode
