; Script step at $1EDA. BC is the script pointer. hScriptHandler is
; planted as $4552 with the 3-byte form, then control jumps to
; StageEightScriptBytesCopy. That copy stages the next eight script
; bytes, stores BC past them at hScriptPtr, sets bit 7 of hScriptBank
; so the planted handler runs from bank 1, and returns.
;
; $4552 is the file address of the bank 1 entry this step plants. It is
; still INCBIN. The jump target is already source. hScriptHandler is
; the name from reset.asm.

DEF Bank1Handler4552 EQU $4552

PlantBank1Handler4552::
    ld a, LOW(Bank1Handler4552)
    ld [hScriptHandler], a
    ld a, HIGH(Bank1Handler4552)
    ld [hScriptHandler + 1], a
    jp StageEightScriptBytesCopy
