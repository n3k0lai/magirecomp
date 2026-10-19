; STAT handler planted at hSTATHandler by opcode $9D.
;
; The LCD STAT vector pushes AF and HL, then jumps through that pointer.
; This stores LCDC_PLAY with the object layer off ($E1): LCD on, window map
; $9C00, window on, BG and window tiles at $8800, background map $9800,
; 8x8 sprites, objects off, background on. It then pops those registers and
; returns from the interrupt.
;
; LCDC_PLAY and rLCDC are the names from turn_on_lcd.asm and turn_off_lcd.asm.
; hSTATHandler is the name from lcd_stat.asm. The store is the 2-byte form.
; Bit 1 of LCDC is the object enable.

StatSetLCDCObjectsOff::
    ld a, LCDC_PLAY & ~$02
    ldh [rLCDC], a
    pop hl
    pop af
    reti
