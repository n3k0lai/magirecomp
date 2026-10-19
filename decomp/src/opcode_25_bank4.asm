; Bank 4 entry for script opcode $25. Opcode25 maps this bank and jumps here.
;
; $C9BB is cleared, then $63D9 and $6346 run. Both are still INCBIN in this
; bank. $63D9 zeros a cluster of WRAM bytes and fills $C9B3-$C9BA with $F0.
; $6346 turns the LCD off and continues the setup that follows.
;
; FinishFrame then runs until byte 2 of wScriptRecord ($C708) is zero.
; $C9BB is set to 1. Bank 2's $5E6D is called through CallBankedHL. Control
; leaves with a jump to $015B, Reset's `ld sp, wStackTop`.
;
; FinishFrame is the name from finish_frame.asm. CallBankedHL is the name
; from call_hl_in_bank.asm. wScriptRecord is the name from finish_startup.asm.

Opcode25Bank4::
    xor a
    ld [$C9BB], a
    call $63D9
    call $6346
.wait:
    call FinishFrame
    ld a, [wScriptRecord + 2]
    and a
    jr nz, .wait
    ld a, $01
    ld [$C9BB], a
    ld hl, $5E6D
    ld e, $02
    call CallBankedHL
    jp $015B
