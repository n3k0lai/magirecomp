; Call the installed callback, or ask VBlank to run and wait.
;
; A clear wLCDC means the LCD has not been turned on. This maps
; wCallbackBank, loads the little-endian pointer at wCallback into HL, and
; enters it through JumpHL. SetupDefaultState installs IdleCallback there,
; which stores its own address and returns.
;
; A nonzero wLCDC takes the other exit. hVBlankFlags is set to 6: bit 1 asks
; the default VBlank body to call wCallback in wCallbackBank, and bit 2's
; role is still unknown. WaitVBlankFlag sets bit 7 and waits until VBlank
; clears it.
;
; wLCDC is the name from turn_off_lcd.asm. wCallback and wCallbackBank are
; the names from default_state.asm. wCurrentROMBank and rROMB0 are the names
; from reset.asm. hVBlankFlags is the name from draw_cgb_notice.asm. The
; hVBlankFlags store is ldh.

CallCallback::
    ld a, [wLCDC]
    and a
    jr nz, .lcd_on
    ld a, [wCallbackBank]
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    ld a, [wCallback + 1]
    ld h, a
    ld a, [wCallback]
    ld l, a
    call JumpHL
    ret

.lcd_on:
    ld a, $06
    ldh [hVBlankFlags], a
    call WaitVBlankFlag
    ret
