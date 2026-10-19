; STAT handler at $2AA8.
;
; The LCD STAT vector pushes AF and HL, then jumps through hSTATHandler.
; This copies $FF9B into rLCDC, $FF9C into rSCX, and $FF9D into rSCY, then
; pops those registers and returns from the interrupt.
;
; rLCDC is the name from turn_off_lcd.asm. rSCX and rSCY are the names from
; lcd_off_setup.asm. hSTATHandler is the name from lcd_stat.asm. Each HRAM
; access is the 2-byte form. Who plants this address, and what fills the
; three HRAM bytes, is still unknown.

DEF hSTATLCDC EQU $FF9B
DEF hSTATSCX EQU $FF9C
DEF hSTATSCY EQU $FF9D

StatCopyLCDCScroll::
    ldh a, [hSTATLCDC]
    ldh [rLCDC], a
    ldh a, [hSTATSCX]
    ldh [rSCX], a
    ldh a, [hSTATSCY]
    ldh [rSCY], a
    pop hl
    pop af
    reti
