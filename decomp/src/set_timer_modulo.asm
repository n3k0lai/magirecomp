; Set the timer modulo to $80 and enable only the timer interrupt.
;
; TMA $80 reloads the timer so it overflows every 128 counts. TAC starts that
; timer at 4096 Hz. Pending flags are cleared first, then IE is set to the
; timer bit alone, which masks VBlank, STAT, serial, and joypad. TurnOffLCD
; reaches this through the ArmTimer address.
;
; rTMA, rTAC, and TACF_START are the names from reset.asm. rIF and rIE are the
; names from turn_off_lcd.asm. Every store below is the 3-byte form.

; Timer interrupt only. The bit matches TACF_START, but it is written to IE.
DEF IEF_TIMER EQU $04

SetTimerModulo::
    ld a, $80
    ld [rTMA], a
    ld a, TACF_START
    ld [rTAC], a
    xor a
    ld [rIF], a
    ld a, IEF_TIMER
    ld [rIE], a
    ret
