; Bank 0 at $2BBB. StepMapStripGlyph jumps here when the strip tile id
; reaches the end. Callers know the address as ParkStripRoutine.
;
; The pointer at $C939 is what JumpHL runs on later strip passes. Storing
; this address there parks those passes: they return immediately with D = 0
; and do not advance another glyph. $2B8C also jumps here; that byte is
; still INCBIN.

ParkStripRoutineBody::
    ld a, LOW(ParkStripRoutineBody)
    ld [$C939], a
    ld a, HIGH(ParkStripRoutineBody)
    ld [$C93A], a
    ld d, $00
    ret
