; Script opcode $20. The bank 1 pointer table at $42C3 maps opcode $20
; here. DispatchScriptOpcode jumps here with BC pointing at the operand.
; That byte is read into E and BC advances past it.
;
; wSoundCountdown ($C924) is the countdown SelectSoundCommand decrements
; when bit 1 is set, then runs SoundCountdown. SoundCountdown passes the
; byte at $C925 to InstallSoundIndex. When the countdown is zero, this
; stores 2 (bit 1 set, so the selector runs once) and copies the operand
; to $C925, then returns through jp DispatchScriptOpcode.
;
; When the countdown is already nonzero, the jr enters the second byte of
; that jp. Those address bytes are $66 $0A, so they run as `ld h, [hl]`
; and `ld a, [bc]`, and execution falls into opcode $21 at $0EBD.
;
; wSoundCountdown is the name from select_sound_command.asm.

Opcode20ArmCountdown::
    ld a, [bc]
    inc bc
    ld e, a
    ld a, [wSoundCountdown]
    and a
    jr nz, .dispatch + 1

    ld a, $02
    ld [wSoundCountdown], a
    ld a, e
    ld [$C925], a

.dispatch:
    jp DispatchScriptOpcode
