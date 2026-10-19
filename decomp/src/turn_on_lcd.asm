; Turn the LCD on with LCDC $E3 unless wLCDC is already nonzero.
;
; Callers reach this through the TurnOnLCD address in finish_startup.asm.
; A nonzero wLCDC means a previous turn-on stored an LCDC value, so this
; returns without touching the hardware. Otherwise STAT is set to the LYC
; source, IF and hVBlankFlags are cleared, VBlank and STAT are enabled,
; LCDC $E3 is stored in rLCDC and wLCDC, and interrupts are enabled.
;
; wLCDC, rLCDC, rIF, and rIE are the names from turn_off_lcd.asm.
; hVBlankFlags, IEF_VBLANK, and IEF_STAT are the names from
; draw_cgb_notice.asm. Every store to a high address below is the 3-byte
; form.

DEF rSTAT EQU $FF41

; Bit 6 selects LYC=LY as a STAT interrupt source. The LYC line is unchanged.
DEF STAT_LYC EQU $40

; LCD on, sprites on, background on. The window map is $9C00 and the window
; is off. Background map $9800, BG and window tiles at $8000, sprites 8x8.
DEF LCDC_PLAY EQU $E3

TurnOnLCDIfOff::
    ld a, [wLCDC]
    and a
    ret nz
    ld a, STAT_LYC
    ld [rSTAT], a
    xor a
    ld [rIF], a
    ld [hVBlankFlags], a
    ld a, IEF_VBLANK | IEF_STAT
    ld [rIE], a
    ld a, LCDC_PLAY
    ld [rLCDC], a
    ld [wLCDC], a
    ei
    ret
