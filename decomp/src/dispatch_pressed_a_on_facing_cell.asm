; Bank 1 at $619A. ResumePlantedHead6167 calls here when bit 0 of
; $c9a4 is set. That bit is A in the pressed-button copy FinishFrame
; writes from wButtonsPressed. rROMB0 is left alone.
;
; The low two bits of hRecordHead are the facing value the plant
; routines store: $00 up, $01 left, $02 right, and $03 down. Each
; value jumps to the button-A dispatch for the neighboring cell in
; that direction. Those four routines are already source in this bank.
; A value outside 0–3 cannot occur after `and $03`; that path would
; fall into the up jump.
;
; hRecordHead is the name from write_record_head.asm. wButtonsPressed
; is the name from main_loop.asm. $c9a4 has no name.
; DispatchCellAboveOnButtonA, DispatchCellBelowOnButtonA,
; DispatchCellLeftOnButtonA, and DispatchCellRightOnButtonA are the
; labels in the four button-A dispatch files. ResumePlantedHead6167
; is the label in resume_planted_head_6167.asm.

DispatchPressedAOnFacingCell::
    ldh a, [hRecordHead]
    and $03
    cp $00
    jr z, .above
    cp $03
    jr z, .below
    cp $01
    jr z, .left
    cp $02
    jr z, .right
.above
    jp DispatchCellAboveOnButtonA
.below
    jp DispatchCellBelowOnButtonA
.left
    jp DispatchCellLeftOnButtonA
.right
    jp DispatchCellRightOnButtonA

DispatchPressedAOnFacingCellEnd:
