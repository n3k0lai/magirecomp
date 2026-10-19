; Bank 0 at $2B8C. The strip routine pointer at $C939 is called once
; per pass. This entry jumps straight to ParkStripRoutineBody, which
; stores its own address at that pointer and returns with D = 0, so
; later passes stay parked and do not advance another glyph.

ParkStripTrampoline::
    jp ParkStripRoutineBody
