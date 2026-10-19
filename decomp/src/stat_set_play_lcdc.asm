; STAT handler installed at hSTATHandler before the $D0B1 choice wait.
;
; The LCD STAT vector pushes AF and HL, then jumps through that pointer.
; This stores LCDC_PLAY ($E3): LCD on, window map $9C00, window on, BG and
; window tiles at $8800, background map $9800, 8x8 sprites, objects and
; background on. It then pops those registers and returns from the interrupt.
;
; LCDC_PLAY and rLCDC are the names from turn_on_lcd.asm and turn_off_lcd.asm.
; hSTATHandler is the name from lcd_stat.asm. The store is the 2-byte form.

StatSetPlayLCDC::
    ld a, LCDC_PLAY
    ldh [rLCDC], a
    pop hl
    pop af
    reti
