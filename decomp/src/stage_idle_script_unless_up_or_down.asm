; Bank 1 at $56EF. The uncovered byte $56F0 is the mask of this
; `bit 6, a`. A is the byte loaded from $c9a3 at $56E2, the copy of
; $c931 written by FinishFrame. Bits 4 and 5 were already tested.
;
; Bit 6 (up) jumps to $5917. Bit 7 (down) jumps to $5779. Otherwise
; this calls $5E65, calls $682D in bank 5 through CallBankedHL, stages
; the third script from the marked cell, nudges the camera past the
; follow edge, and jumps to the shared exit at $5D9B.
;
; CallBankedHL, StageThirdScriptFromMarkedCell, and
; NudgeCameraPastFollowEdge are already source. $c9a3 has no name.
; $5E65, $5917, $5779, and $5D9B are still INCBIN in this bank.
; Bank 5's $682D is still INCBIN.

StageIdleScriptUnlessUpOrDown::
    bit 6, a
    jp nz, $5917
    bit 7, a
    jp nz, $5779
    call $5e65
    ld hl, $682d
    ld e, $05
    call CallBankedHL
    call StageThirdScriptFromMarkedCell
    call NudgeCameraPastFollowEdge
    jp $5d9b
