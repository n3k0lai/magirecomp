; Bank 1 at $5BA7. ResumeRightScriptOnA calls here when bit 0 of
; $C9A4 is set. That bit is A in the pressed-button copy FinishFrame
; writes from wButtonsPressed. rROMB0 is left alone.
;
; hRecordHead ($FF8C) keeps its low two bits. Those bits pick one of
; four bank-1 entries:
;   $00 jumps to $4C6E, still INCBIN
;   $01 jumps to DispatchCellLeftOnButtonA
;   $02 jumps to DispatchCellRightOnButtonA
;   $03 jumps to DispatchCellBelowOnButtonA
; The compares cover every value `and $03` can leave, so the fall
; through into the $00 jump is unused. The `ret` after the four jumps
; is unused too. $5BC8, the next byte, is still INCBIN.
;
; $5BBF is the low byte inside `jp DispatchCellBelowOnButtonA`.
; ResumeOtherLeftCellScript stores that address as hScriptPtr when bit
; 6 of $c9a3 is clear. What the script engine does with a pointer into
; this jump is still unknown.
;
; hRecordHead is the name from write_record_head.asm. hScriptPtr is the
; name from reset.asm. wButtonsPressed is the name from main_loop.asm.
; The A-button bit is the name from read_joypad.asm.

DispatchRecordHeadOnA::
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
