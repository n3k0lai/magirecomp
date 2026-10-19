; Joypad transition interrupt vector. The CPU enters here when a button
; changes while the joypad interrupt is enabled. The handler returns immediately.

Joypad::
    reti
