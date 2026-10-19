; Switch the CGB from double speed back to normal speed.
;
; This is the twin of SwitchCPUToDoubleSpeed at $5A4F. rP1, rKEY1,
; KEY1F_PREPARE, and P1F_NEITHER are the names from that file. rIF and rIE
; are the names from turn_off_lcd.asm. Every absolute store below is the
; 3-byte form.
;
; KEY1 bit 7 is clear while the CPU is already in normal speed, so this
; returns immediately. Bit 0 arms the switch; STOP performs it. Interrupts
; are masked across STOP, then restored. $30 on rP1 releases both joypad
; select lines so a button does not cancel STOP. The loop repeats the KEY1
; read until bit 7 reads back as clear.

SwitchCPUToNormalSpeed::
    ld a, [rKEY1]
    bit 7, a
    ret z
    ld a, KEY1F_PREPARE
    ld [rKEY1], a
    ld a, [rIE]
    push af
    xor a
    ld [rIE], a
    ld a, P1F_NEITHER
    ld [rP1], a
    stop
.wait_speed
    ld a, [rKEY1]
    bit 7, a
    jr nz, .wait_speed
    xor a
    ld [rP1], a
    ld [rIF], a
    pop af
    ld [rIE], a
    ret
