; Switch the CGB into double-speed mode.
;
; Reset calls this as SwitchToDoubleSpeed. That name is the EQU in reset.asm,
; so the entry label here is different. rIF and rIE are the names from
; turn_off_lcd.asm. Every absolute store below is the 3-byte form.
;
; KEY1 bit 7 is set while the CPU is already in double speed. Bit 0 arms the
; switch; STOP performs it. Interrupts are masked across STOP, then restored.
; $30 on rP1 releases both joypad select lines so a button does not cancel
; STOP. The loop repeats the KEY1 read until bit 7 reads back as set.

; Joypad register. Both select bits set means neither group is read.
DEF rP1 EQU $FF00
DEF P1F_NEITHER EQU $30

; CGB speed switch. $01 prepares a change; bit 7 reports the current speed.
DEF rKEY1 EQU $FF4D
DEF KEY1F_PREPARE EQU $01

SwitchCPUToDoubleSpeed::
    ld a, [rKEY1]
    bit 7, a
    ret nz
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
    jr z, .wait_speed
    xor a
    ld [rP1], a
    ld [rIF], a
    pop af
    ld [rIE], a
    ret
