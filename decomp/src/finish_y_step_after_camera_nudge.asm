; Bank 1. $52F0 is the high byte of the call that begins at $52EE.
; The bytes just before this, still INCBIN, called bank $05 at $682D
; through CallBankedHL and restored this bank.
;
; StageThirdScriptFromMarkedCell runs, then NudgeCameraPastFollowEdge.
; $C6D3 is the signed vertical step named in
; nudge_camera_past_follow_edge.asm. A zero step calls $4B7B, $51B6,
; and $570D, then jumps to $5308. Any other step jumps to $5305.
; rROMB0 is left alone, so those calls stay in this bank. Both jump
; targets are still INCBIN.

; Still INCBIN. Joins the zero-step calls with the nonzero path.
DEF YStepAfterNudgeJoin EQU $5308

FinishYStepAfterCameraNudge::
    call StageThirdScriptFromMarkedCell
    call NudgeCameraPastFollowEdge
    ld a, [$c6d3]
    and a
    jr nz, OnNonzeroYStepAfterNudge

    call $4B7B
    call $51B6
    call $570D
    jr YStepAfterNudgeJoin
