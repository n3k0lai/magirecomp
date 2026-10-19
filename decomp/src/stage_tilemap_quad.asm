; Records the 2x2 tilemap block whose top-left corner is HL.
; $C836 keeps HL, $C838 is one column right, $C83A is one row down, and
; $C83C is the corner one column right of that row. StepTilemapColumn and
; StepTilemapRow do the wraps. C is set to 1 and left there.
;
; wCallback becomes WriteStagedBytesAtFourPtrs in this bank, which writes
; the bytes already sitting at $C83E and $C83F through those four pointers.
; SelectSoundCommand runs, then CallCallback runs the writer immediately.
; StagedPtrTable, wCallback, and wCallbackBank are names from earlier source.

StageTilemapQuad:
    push hl
    ld c, $01
    ld a, h
    ld [StagedPtrTable + 1], a
    ld a, l
    ld [StagedPtrTable], a
    call StepTilemapColumn
    ld a, h
    ld [StagedPtrTable + 3], a
    ld a, l
    ld [StagedPtrTable + 2], a
    pop hl
    call StepTilemapRow
    ld a, h
    ld [StagedPtrTable + 5], a
    ld a, l
    ld [StagedPtrTable + 4], a
    call StepTilemapColumn
    ld a, h
    ld [StagedPtrTable + 7], a
    ld a, l
    ld [StagedPtrTable + 6], a
    ld a, BANK("Stage tilemap quad")
    ld [wCallbackBank], a
    ld a, LOW(WriteStagedBytesAtFourPtrs)
    ld [wCallback], a
    ld a, HIGH(WriteStagedBytesAtFourPtrs)
    ld [wCallback + 1], a
    call SelectSoundCommand
    call CallCallback
    ret
