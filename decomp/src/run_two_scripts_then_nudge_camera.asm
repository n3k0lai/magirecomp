; Bank 1 at $63E6, the first byte after RunOneScriptThenWriteHead.
;
; RunTwoScriptsFromRecord loads the record at hRecordPointer, runs its
; two script records, and writes the head back. CallBankedHL inside that
; routine maps bank 5 and restores the bank it found. This then adds the
; signed pixel step at $C6D2/$C6D3 onto the camera deltas when the sprite
; is past the follow edge, and returns.
;
; RunTwoScriptsFromRecord and NudgeCameraPastFollowEdge are already source.
; rROMB0 is left alone except inside those calls.

RunTwoScriptsThenNudgeCamera::
    call RunTwoScriptsFromRecord
    call NudgeCameraPastFollowEdge
    ret

RunTwoScriptsThenNudgeCameraEnd:
