; Constants that the published code uses but that were defined in files
; left out of MagiRecomp (they assemble data copied from the ROM).

DEF wGlyphSrc EQU $C6E7
DEF wGlyphDest EQU $C6E9
DEF hVBlankFlags EQU $FF9E
DEF wChannelFlagBase EQU $DF09
DEF CopyGlyph EQU $2949
DEF wGlyphVRAMBank EQU $C6EB
DEF MultiplyCByB EQU $04CA
DEF wChannelLengthTimerTop EQU $DF07
DEF IEF_VBLANK EQU $01
DEF IEF_STAT EQU $02

; RST $00. Re-enters Reset after the model-id check, at `ld sp, wStackTop`.
; ResetAtStack is the name from read_joypad.asm. The rest of this vector
; slot is padding and stays INCBIN.

RST_00::
    jp ResetAtStack
