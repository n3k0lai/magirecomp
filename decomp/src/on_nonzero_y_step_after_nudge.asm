; Bank 1 at $5305. FinishYStepAfterCameraNudge jumps here when the
; vertical step at $C6D3 is not zero. The zero-step path calls $4B7B,
; $51B6, and $570D, then joins at $5308.
;
; This calls StepCell82OnEvenPass, then loads the $c931 copy at $c9a3
; that FinishFrame writes. Bit 1 clear jumps to $54A4. Bit 1 set jumps
; to $5D9B, the shared tail that copies the script bytes and writes the
; record head.
;
; What bit 1 of $c9a3 means is still unknown. $54A4 is still INCBIN.
; CommitScriptAndRecordHead is the name from plant_handler_and_head_word.asm.
; StepCell82OnEvenPass is already source. rROMB0 is left alone.

; Still INCBIN. Taken when bit 1 of $c9a3 is clear.
DEF YStepBit1Clear EQU $54A4

OnNonzeroYStepAfterNudge::
    call StepCell82OnEvenPass
; $5308. The zero-step path joins here.
.join:
    ld a, [$c9a3]
    bit 1, a
    jp z, YStepBit1Clear
    jp CommitScriptAndRecordHead
