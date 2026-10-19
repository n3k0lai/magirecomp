; Bank 0 at $24C7. PlantStripHandler24C7 plants this as hScriptHandler
; and leaves the bank-1 callback alone. This pass only replaces the
; handler with $24D2. $24D2 is still INCBIN. What it does is still
; unknown.
;
; hScriptHandler is the name from reset.asm. The store is the 3-byte form.

; Next handler. Still INCBIN.
DEF StripSlideHandler24D2 EQU $24D2

PlantStripHandler24D2::
    ld a, LOW(StripSlideHandler24D2)
    ld [hScriptHandler], a
    ld a, HIGH(StripSlideHandler24D2)
    ld [hScriptHandler + 1], a
    ret
