; Turn the LCD off, run the saved script, seed a $20 camera box, and enter
; the main loop.
;
; This is the same opening as FinishStartup through the script loop, without
; clearing $CCA5 and without setting $C6F3. After the loop, A is $20 and is
; stored at the map stride $C847, at $C848, and at the camera limits $C845
; and $C846. $1F8F is the first of those stores, so a jump there keeps the
; value already in A. Bank 7 is mapped and ClampMapCamera runs. The stack
; returns to $CED8, the LCD turns on, and control jumps to the main loop.
;
; The stores to $FF9F, $FFA0, $FFA4, and $FFA5 are the 3-byte form, and each
; of the four $C715 bytes reloads A. hScriptDest, wScriptRecord, wQuadC715,
; CopyScriptRecord, InitQuadRecords, and TurnOnLCD are the names from
; finish_startup.asm. hScriptHandler, INITIAL_SCRIPT_HANDLER, wStackTop,
; wCurrentROMBank, rROMB0, and BANK_INIT are the names from reset.asm.
; ArmTimer is the name from turn_off_lcd.asm. wMapRowStride is the name from
; draw_metatile_window.asm.

; Stored with the stride and the two limits. ClampMapCamera does not read it.
; Its role is still unknown.
DEF wCameraByteC848 EQU $C848

; Rightmost camera column and bottom camera row. ClampMapCamera reads both.
DEF wCameraColumnLimit EQU $C845
DEF wCameraRowLimit EQU $C846

SeedCameraAndEnterLoop::
    call TurnOffLCD
    call ArmTimer
    ld a, LOW(wScriptRecord)
    ld [hScriptDest], a
    ld a, HIGH(wScriptRecord)
    ld [hScriptDest + 1], a
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ld [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ld [hScriptHandler + 1], a
    call CopyScriptRecord
    call SetupDefaultState
    call InitQuadRecords
    ld a, $00
    ld [wQuadC715], a
    ld a, $00
    ld [wQuadC715 + 1], a
    ld a, $02
    ld [wQuadC715 + 2], a
    ld a, $14
    ld [wQuadC715 + 3], a
    ld sp, wStackTop
    call RunScriptRecord
    ld a, $20
.storeLimits:
    ld [wMapRowStride], a
    ld [wCameraByteC848], a
    ld [wCameraColumnLimit], a
    ld [wCameraRowLimit], a
    ld a, BANK_INIT
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call ClampMapCamera
    ld sp, wStackTop
    call TurnOnLCD
    jp GameLoop
