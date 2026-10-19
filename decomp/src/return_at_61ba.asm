; Bank 1 at $61BA. One `ret` between DispatchPressedAOnFacingCell,
; which leaves through an unconditional jump, and
; PlantDownRecordHead61DE at $61BB. Nothing in the lifted source falls
; into this byte. What calls or jumps here is still unknown.
;
; DispatchPressedAOnFacingCell is the label in
; dispatch_pressed_a_on_facing_cell.asm. PlantDownRecordHead61DE is the
; label in plant_down_record_head_61de.asm.

ReturnAt61BA::
    ret

ReturnAt61BAEnd:
