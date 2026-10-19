; Turn the LCD off during vblank.
;
; wLCDC is cleared either way. If the LCD is already off, that is the whole
; routine. If it is on, interrupts are masked, the spin waits until LY is the
; second line of vblank, and the LCD is switched off. Flags raised during the
; spin are dropped, IME is set, and the timer is armed.
;
; Every access to HRAM below is the 3-byte form.

DEF rLCDC EQU $FF40
DEF rLY EQU $FF44
DEF rIF EQU $FF0F
DEF rIE EQU $FFFF

; LCDC bit 7 is set while the LCD is running.
DEF LCDCB_ON EQU 7

; 0 while the LCD is off. The turn-on routine at $07EA stores its LCDC value
; here. Callers only test the byte for zero.
DEF wLCDC EQU $C936

; LY runs $00-$99. Vblank is $90-$99, and the LCD is turned off on the second
; of those lines.
DEF LY_OFF EQU $91

; Bank 0, still INCBIN. Sets the timer modulo to $80, starts the 4096 Hz
; timer, and enables only the timer interrupt.
DEF ArmTimer EQU $29F3

TurnOffLCD::
    xor a
    ld [wLCDC], a
    ld a, [rLCDC]
    bit LCDCB_ON, a
    ret z
    xor a
    ld [rIF], a
    ld [rIE], a
.wait_ly:
    ld a, [rLY]
    cp LY_OFF
    jr nz, .wait_ly
    xor a
    ld [rLCDC], a
    ld [rIF], a
    ld [rIE], a
    ei
    call ArmTimer
    ret
