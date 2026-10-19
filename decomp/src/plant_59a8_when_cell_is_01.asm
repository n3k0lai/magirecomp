; Bank 1 at $570D. FinishYStepAfterCameraNudge calls this when the
; vertical step at $C6D3 is zero, after $4B7B and $51B6.
;
; [HL] must be $01, and $C9A6 must be at least $04. Otherwise this
; returns to that caller. When both checks pass, this calls $56C0,
; drops that return address, stores $59A8 as hScriptPtr (low at $FFA2,
; high at $FFA3, the 3-byte form), and jumps to PlantHandlerAndHeadWord.
; hScriptPtr is the name from reset.asm. $56C0 and the $59A8 routine
; are still INCBIN in this bank. What [HL] and $C9A6 are is unknown.

; Still INCBIN. Planted as hScriptPtr when both checks pass.
DEF ScriptPtr59A8 EQU $59A8

Plant59A8WhenCellIs01::
    ld a, [hl]
    cp $01
    ret nz
    ld a, [$c9a6]
    sub $04
    ret c
    call $56c0
    pop af
    ld a, LOW(ScriptPtr59A8)
    ld [hScriptPtr], a
    ld a, HIGH(ScriptPtr59A8)
    ld [hScriptPtr + 1], a
    jp PlantHandlerAndHeadWord
