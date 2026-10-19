; Toggle CPU speed. Arms the switch in rKEY1, masks every interrupt (rIE and
; rIF cleared, the old rIE kept in L), deselects the joypad lines, runs
; `stop` to perform the switch, then restores rIE.

ToggleCpuSpeed::
    ld hl, rKEY1
    set 0, [hl]
    ldh a, [rIE]
    ld l, a
    xor a
    ldh [rIE], a
    ldh [rIF], a
    ld a, $30
    ldh [rP1], a
    stop
    nop
    ld a, l
    ldh [rIE], a
    ret
