; Script step at $2401. ReturnUnlessC6EEIsTwo continues only when
; [wUnknownC6EE] is 2. BC, the script pointer, is then stored as the
; strip text word at $C93B (low byte first). $C939 points at $2B51.
; hScriptHandler becomes $2421, the next byte, which is still INCBIN.
;
; wStripText and wStripRoutine are the names from
; run_d0b1_map_strips.asm, included later, so this file uses the
; addresses. hScriptHandler is the name from reset.asm. $2B51 is still
; unknown. The stores are the 3-byte form.

; wStripText. Named later.
DEF wStripTextC93B EQU $C93B

; wStripRoutine. Named later.
DEF wStripRoutineC939 EQU $C939

; Pointer planted at wStripRoutine. Still INCBIN.
DEF StripRoutine2B51 EQU $2B51

; Planted as hScriptHandler. Still INCBIN.
DEF StripTextHandler EQU $2421

StageStripTextFromScript::
    call ReturnUnlessC6EEIsTwo
    ld a, b
    ld [wStripTextC93B + 1], a
    ld a, c
    ld [wStripTextC93B], a
    ld a, LOW(StripRoutine2B51)
    ld [wStripRoutineC939], a
    ld a, HIGH(StripRoutine2B51)
    ld [wStripRoutineC939 + 1], a
    ld a, LOW(StripTextHandler)
    ld [hScriptHandler], a
    ld a, HIGH(StripTextHandler)
    ld [hScriptHandler + 1], a
    ret
