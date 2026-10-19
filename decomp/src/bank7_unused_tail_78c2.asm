; Unused zero fill in bank 7 at CPU $78C2 (file $01F8C2).
; The last instruction before this tail returns at file $01F4CB.
; From $01F4CC through $01FFFF every byte is $00. Nothing in this
; bank jumps here. This slice is the 64 bytes that start at $78C2.

Bank7UnusedTailAt78C2::
    ds 64  ; zero fill through CPU $7901
