; Reset jumps here when the boot ROM's model id is not $11.
;
; DrawCGBNotice paints the notice at $01D3 ("Magi-Nation is Specially
; Designed for Game Boy Color...") into VRAM, turns the LCD on, and returns.
; The jump below does not return, so execution stays here.

; Bank 0, still INCBIN.
DEF DrawCGBNotice EQU $0242

NonCGBLockup::
    call DrawCGBNotice
.lock:
    jp .lock
