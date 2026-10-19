; Clear the WRAM bank 1 sound state, call $44EF in bank $30, then
; point wSoundCommand at $0659.
;
; rSVBK, wSoundCommand, and BANK_SOUND are the names from timer_overflow.asm.
; CallBankedHL is the name from call_hl_in_bank.asm. It maps the bank in E
; and jumps to HL. It replaces A before that jump, so the $81 loaded here
; does not reach $44EF.
;
; $C926, $C927, $C925, and $C91D are cleared with the sound bytes named in
; select_sound_command.asm. $C91D is then set to $55. Those four are not
; read by the selector.

DEF SOUND_COMMAND_INIT EQU $0659

InitSoundState:
    ld a, WRAM_SOUND
    ld [rSVBK], a
    xor a
    ld [$C91E], a
    ld [$C926], a
    ld [$C927], a
    ld [$C91F], a
    ld [$C925], a
    ld [$C924], a
    ld [$C92A], a
    ld [$C91D], a
    ld a, $FF
    ld [$C921], a
    ld [$C922], a
    ld [$C920], a
    ld a, $81
    ld hl, $44EF
    ld e, BANK_SOUND
    call CallBankedHL
    ld a, $55
    ld [$C91D], a
    ld a, LOW(SOUND_COMMAND_INIT)
    ld [wSoundCommand], a
    ld a, HIGH(SOUND_COMMAND_INIT)
    ld [wSoundCommand + 1], a
    ret
