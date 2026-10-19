; Bank 1 at $6405, the first byte after StageScratchThenPlantHeadWord64D1.
; rROMB0 is left alone except inside the calls.
;
; RunTwoScriptsThenTouchCell loads the record at hRecordPointer, runs
; its two script records, and may mark the map cell. GateCellNearFirstRecord
; returns with A clear when this should leave the record alone. Unlike
; the routine at $63ED, a nonzero wRecordState does not return and the
; scratch is not filled.
;
; HL is then the live record, using the 3-byte loads of hRecordPointer.
; The next two bytes are the head word LoadRecordHead copies to
; hRecordHead + 1. They become the little-endian address $64D1, still
; INCBIN in this bank. What the record uses that word for is still
; unknown.
;
; RunTwoScriptsThenTouchCell, GateCellNearFirstRecord, and
; hRecordPointer are already source.

; Head word still in this bank's INCBIN. Written at record byte 1.
DEF HeadWord64D1Live EQU $64D1

PlantHeadWord64D1::
    call RunTwoScriptsThenTouchCell
    call GateCellNearFirstRecord
    and a
    ret z
    ld a, [hRecordPointer + 1]
    ld h, a
    ld a, [hRecordPointer]
    ld l, a
    inc hl
    ld a, LOW(HeadWord64D1Live)
    ld [hl+], a
    ld a, HIGH(HeadWord64D1Live)
    ld [hl+], a
    ret
