; RST $00. Re-enters Reset after the model-id check, at `ld sp, wStackTop`.
; ResetAtStack is the name from read_joypad.asm. The rest of this vector
; slot is padding and stays INCBIN.

RST_00::
    jp ResetAtStack
