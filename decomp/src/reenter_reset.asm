; Unconditional jump to Reset after the model-id check, at
; `ld sp, wStackTop`. ResetAtStack is the name from read_joypad.asm.
; Callers in other banks use this as a three-byte soft-reset entry.

ReenterReset::
    jp ResetAtStack
