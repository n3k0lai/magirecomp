; Opcode $30 stores a little-endian address at $C840, plants the
; initial script handler, maps bank 7, and jumps here.
;
; CallCallback runs the installed callback when the LCD is off, or asks
; VBlank to run it and waits. That call can replace the mapped bank.
; The word at $C840 is then loaded into HL and entered with jp hl.
; A target in $4000-$7FFF therefore uses the bank CallCallback left.
;
; CallCallback is the name from call_callback.asm. $C840 is the pair
; written by opcode_30.asm.

EnterOpcode30Target::
    call CallCallback
    ld hl, $C840
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    jp hl
