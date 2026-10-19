; Tail of the countdown entry at $1AE5, from the uncovered byte at $1B05.
; That byte is the middle of `ld [rROMB0], a`, so this starts at $1B04.
;
; A is already $07. The instruction just before this stored that value in
; wCurrentROMBank and pushed BC. This maps bank 7, calls $41CB, restores BC,
; and jumps to $19E8.
;
; $41CB is bank 7, file address $01C1CB. $19E8 is still INCBIN. What either
; routine does is still unknown.
;
; wCurrentROMBank and rROMB0 are the names from reset.asm.

; Bank 7, still INCBIN. CPU address while bank 7 is mapped.
DEF Bank7Routine41CB EQU $41CB

MapBank7Call41CB::
    ld [rROMB0], a
    call Bank7Routine41CB
    pop bc
    jp StepBank7CallbackCountdown
