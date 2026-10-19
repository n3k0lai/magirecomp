; Bank 0 at $24BC. ArmStripSlideFollowup plants this as hScriptHandler
; after arming wCallback as $487C in bank 1. This pass only replaces
; the handler with $24C7 and leaves that callback alone. $24C7 is still
; INCBIN. What it does is still unknown.
;
; hScriptHandler is the name from reset.asm. The store is the 3-byte form.

; Next handler. Still INCBIN.
DEF StripSlideNextHandler EQU $24C7

PlantStripHandler24C7::
    ld a, LOW(StripSlideNextHandler)
    ld [hScriptHandler], a
    ld a, HIGH(StripSlideNextHandler)
    ld [hScriptHandler + 1], a
    ret
