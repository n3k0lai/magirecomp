; Bank 1 at $5E3E. ResumeDirectionDispatchHead calls here when no
; direction bit of $c9a3 is set, after NudgeCameraPastFollowEdge.
; The bytes at $5E10 also call here. rROMB0 is left alone.
;
; A is the pressed-button copy FinishFrame writes to $C9A4 from
; wButtonsPressed. Bit 0 is A. When that bit is clear this returns,
; and the caller at $5B3B continues into CommitScriptAndRecordHead.
;
; When A is pressed, hRecordHead ($FF8C) keeps its low two bits.
; Those bits pick one of four bank-1 entries and do not return here:
;   $00 jumps to DispatchCellAboveOnButtonA
;   $01 jumps to DispatchCellLeftOnButtonA
;   $02 jumps to DispatchCellRightOnButtonA
;   $03 jumps to DispatchCellBelowOnButtonA
; The compares cover every value `and $03` can leave, so the fall
; through into the $00 jump is unused. The `ret` after the four jumps
; is unused too. $5E65, the next byte, is AddCellDirectionStep.
;
; hRecordHead is the name from write_record_head.asm.
; wButtonsPressed is the name from main_loop.asm. The A-button bit
; is the name from read_joypad.asm. CommitScriptAndRecordHead is the
; EQU in plant_handler_and_head_word.asm.

DispatchRecordHeadIfAPressed::
    ld a, [$c9a4]
    bit 0, a
    ret z

    ldh a, [hRecordHead]
    and $03
    cp $00
    jr z, .index0
    cp $03
    jr z, .index3
    cp $01
    jr z, .index1
    cp $02
    jr z, .index2

.index0:
    jp DispatchCellAboveOnButtonA

.index3:
    jp DispatchCellBelowOnButtonA

.index1:
    jp DispatchCellLeftOnButtonA

.index2:
    jp DispatchCellRightOnButtonA
    ret
