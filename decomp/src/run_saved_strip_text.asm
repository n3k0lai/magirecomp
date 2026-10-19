; Bank 0 at $2421. StageStripTextFromScript plants this as hScriptHandler
; after the script pointer is saved as strip text and $C939 points at $2B51.
;
; JumpHL runs that strip routine. D = 0 means it is not finished, and this
; returns with the handler unchanged. Otherwise the map-cell word at $C93F
; becomes $9C65, and the strip-text word is copied back to hScriptPtr (low
; byte first, LDH).
;
; D = $FD plants INITIAL_SCRIPT_HANDLER and returns. D = $FF plants
; StageStripTextFromScript, then joins the countdown. Any other value plants
; .waitA. .waitA also stays the handler: it writes itself again and returns
; until A (bit 0 of $C931) is held.
;
; While [$C6ED] is nonzero it is decremented and the handler becomes
; StageStripTextFromScript. At zero the handler becomes $24A2, and wCallback
; becomes $4864 in bank 1. FinishWindowYSlide is what stores 1 at $C6ED.
; What $FD and $FF mean inside the strip routine is still unknown.
;
; hScriptPtr, hScriptHandler, and INITIAL_SCRIPT_HANDLER are the names from
; reset.asm. JumpHL is the trampoline at $0789. wCallback and wCallbackBank
; are the names from default_state.asm. The strip words are named in later
; files, so this file uses addresses. Handler stores are the 3-byte form.

; wStripRoutine. Named later.
DEF StripRoutineWord EQU $C939
; wStripText. Named later.
DEF StripTextWord EQU $C93B
; wStripMapCell. Window map cell written once the strip routine finishes.
DEF StripMapCell EQU $C93F
DEF STRIP_MAP_CELL_DONE EQU $9C65
; Countdown FinishWindowYSlide sets to 1. No other source names this byte.
DEF wStripSlideCount EQU $C6ED
; wButtonsHeld. read_joypad.asm names $C931. Bit 0 is A.
DEF wHeldButtons EQU $C931
DEF BTN_A EQU $01
; Next handler and the bank-1 callback it arms. Both still INCBIN.
DEF StripSlideDoneHandler EQU $24A2
DEF StripSlideDoneCallback EQU $4864
DEF STRIP_SLIDE_DONE_BANK EQU $01

RunSavedStripText::
    ld hl, StripRoutineWord
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    call JumpHL
    ld a, d
    and a
    ret z
    ld a, LOW(STRIP_MAP_CELL_DONE)
    ld [StripMapCell], a
    ld a, HIGH(STRIP_MAP_CELL_DONE)
    ld [StripMapCell + 1], a
    ld a, [StripTextWord]
    ldh [hScriptPtr], a
    ld a, [StripTextWord + 1]
    ldh [hScriptPtr + 1], a
    ld a, d
    cp $FD
    jr nz, .notDoneFD
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ld [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ld [hScriptHandler + 1], a
    ret

.notDoneFD:
    cp $FF
    jr nz, .waitA
    ld a, LOW(StageStripTextFromScript)
    ld [hScriptHandler], a
    ld a, HIGH(StageStripTextFromScript)
    ld [hScriptHandler + 1], a
    jr .countdown

.waitA:
    ld a, LOW(.waitA)
    ld [hScriptHandler], a
    ld a, HIGH(.waitA)
    ld [hScriptHandler + 1], a
    ld a, [wHeldButtons]
    and BTN_A
    jr nz, .countdown
    ret

.countdown:
    ld a, [wStripSlideCount]
    and a
    jr z, .armCallback
    dec a
    ld [wStripSlideCount], a
    ld a, LOW(StageStripTextFromScript)
    ld [hScriptHandler], a
    ld a, HIGH(StageStripTextFromScript)
    ld [hScriptHandler + 1], a
    ret

.armCallback:
    ld a, LOW(StripSlideDoneHandler)
    ld [hScriptHandler], a
    ld a, HIGH(StripSlideDoneHandler)
    ld [hScriptHandler + 1], a
    ld a, STRIP_SLIDE_DONE_BANK
    ld [wCallbackBank], a
    ld a, LOW(StripSlideDoneCallback)
    ld [wCallback], a
    ld a, HIGH(StripSlideDoneCallback)
    ld [wCallback + 1], a
    ret
