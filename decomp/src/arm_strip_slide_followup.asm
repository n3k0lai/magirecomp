; Bank 0 at $24A2. RunSavedStripText plants this as hScriptHandler when the
; strip countdown at $C6ED reaches zero, and arms wCallback as $4864 in
; bank 1. This pass replaces both: hScriptHandler becomes $24BC, and
; wCallback becomes $487C in bank 1. Both addresses are still INCBIN.
; What those two routines do is still unknown.
;
; hScriptHandler is the name from reset.asm. wCallback and wCallbackBank
; are the names from default_state.asm. Handler stores are the 3-byte form.

; Next handler. Still INCBIN.
DEF StripSlideFollowHandler EQU $24BC
; Bank-1 callback planted with that handler. Still INCBIN.
DEF StripSlideFollowCallback EQU $487C
DEF STRIP_SLIDE_FOLLOW_BANK EQU $01

ArmStripSlideFollowup::
    ld a, LOW(StripSlideFollowHandler)
    ld [hScriptHandler], a
    ld a, HIGH(StripSlideFollowHandler)
    ld [hScriptHandler + 1], a
    ld a, STRIP_SLIDE_FOLLOW_BANK
    ld [wCallbackBank], a
    ld a, LOW(StripSlideFollowCallback)
    ld [wCallback], a
    ld a, HIGH(StripSlideFollowCallback)
    ld [wCallback + 1], a
    ret
