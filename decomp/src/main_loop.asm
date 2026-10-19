; Main loop. FinishStartup jumps here. That file names this address MainLoop.
;
; Each pass increments $FFA8 and wraps at $100. $C932 is the just-pressed
; mask filled by ReadJoypad: the low nibble is A, B, Select, Start, and the
; high nibble is Right, Left, Up, Down. Bit 3 is Start. When that bit is
; set, ROM bank 6 is mapped and $6783 is called. What $6783 does is still
; unknown. Every pass then calls $08BB and jumps back here.
;
; Both bank stores are the 3-byte form. The counter uses ldh.
; wCurrentROMBank and rROMB0 are the names from reset.asm.

; Incremented every pass. Its role is still unknown.
DEF hMainLoopCounter EQU $FFA8

; Buttons that went down since the previous ReadJoypad sample.
DEF wButtonsPressed EQU $C932

DEF BANK_MAIN_HOOK EQU $06

GameLoop::
    ldh a, [hMainLoopCounter]
    inc a
    ldh [hMainLoopCounter], a
    ld a, [wButtonsPressed]
    bit 3, a
    jr z, .tail
    ld a, BANK_MAIN_HOOK
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call HandleStartPress
.tail:
    call FinishFrame
    jp GameLoop
