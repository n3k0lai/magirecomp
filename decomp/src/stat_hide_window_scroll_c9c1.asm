; STAT handler at $36B1.
;
; LCDStat pushes AF and HL, then jumps through hSTATHandler.
; StatWindowScrollThenBank4 plants this address. This stores $A7 in rWX,
; so the window starts at pixel 160 and sits off the right edge. $C9C1 is
; copied into rSCX, and rSCY is set to $B0. HL and AF are popped and the
; interrupt returns. hSTATHandler is left alone, so the next STAT runs
; this handler again.
;
; rWX is the name from setup_window.asm. rSCX and rSCY are the names from
; lcd_off_setup.asm. hSTATHandler is the name from lcd_stat.asm.
; ScaleEByDIntoC9C0 writes $C9C1. What that scaled byte means as a scroll
; is still unknown.

; rWX value that places the window just past the right edge of the screen.
DEF STAT_WX_OFF_RIGHT EQU $A7

; Fixed background Y scroll for this handler.
DEF STAT_SCY_B0 EQU $B0

StatHideWindowScrollC9C1::
    ld a, STAT_WX_OFF_RIGHT
    ldh [rWX], a
    ld a, [$C9C1]
    ldh [rSCX], a
    ld a, STAT_SCY_B0
    ldh [rSCY], a
    pop hl
    pop af
    reti
