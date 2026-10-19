; Bank 1 at $59E7. ResumeHead01Record plants this address as hScriptPtr
; when the map cell one column left is $00, then jumps to
; PlantHandlerAndHeadWord. The same address is also the next instruction
; after StageThirdScriptFromMarkedCell in the path that starts at $59B5,
; which is still INCBIN. rROMB0 is left alone.
;
; This entry nudges the camera from the signed step at $C6D2 and $C6D3,
; steps cell $82 when that countdown is enabled and the main-loop counter
; is on its fourth pass, then dispatches the cell one row below if A was
; pressed. Control then jumps to CommitScriptRecord, which copies the
; HRAM script bytes and writes the record head.
;
; NudgeCameraPastFollowEdge, StepCell82EveryFourthFrame,
; DispatchCellBelowOnButtonA, and CommitScriptRecord are already source.
; Nothing here calls or jumps into an INCBIN.

RunLeftZeroCellScript::
    call NudgeCameraPastFollowEdge
    call StepCell82EveryFourthFrame
    call DispatchCellBelowOnButtonA
    jp CommitScriptRecord
