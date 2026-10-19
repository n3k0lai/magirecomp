; Bank 0 at $24D2. PlantStripHandler24D2 plants this as hScriptHandler
; and leaves the bank-1 callback at $487C alone. This pass replaces both:
; hScriptHandler becomes StageStripTextFromScript ($2401), and wCallback
; becomes $489D in bank 1. $489D is still INCBIN. What it does is still
; unknown.
;
; hScriptHandler is the name from reset.asm. wCallback and wCallbackBank
; are the names from default_state.asm. Handler stores are the 3-byte form.

; Bank-1 callback planted with the strip-text step. Still INCBIN.
DEF StripTextCallback EQU $489D
DEF STRIP_TEXT_CALLBACK_BANK EQU $01

ArmStripTextStep::
    ld a, LOW(StageStripTextFromScript)
    ld [hScriptHandler], a
    ld a, HIGH(StageStripTextFromScript)
    ld [hScriptHandler + 1], a
    ld a, STRIP_TEXT_CALLBACK_BANK
    ld [wCallbackBank], a
    ld a, LOW(StripTextCallback)
    ld [wCallback], a
    ld a, HIGH(StripTextCallback)
    ld [wCallback + 1], a
    ret
