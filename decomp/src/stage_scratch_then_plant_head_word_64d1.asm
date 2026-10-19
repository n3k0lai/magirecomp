; Bank 1 at $63ED, the first byte after RunTwoScriptsThenNudgeCamera.
;
; RunTwoScriptsThenTouchCell loads the record at hRecordPointer, runs
; its two script records, and may mark the map cell. $641D, still
; INCBIN, then returns with A clear when this should leave the record
; alone. A nonzero wRecordState also returns: the scratch already holds
; a record. Otherwise CopyRecordToScratch copies $1B bytes to $C1A4,
; sets wRecordState to 1, and leaves HL on the live record.
;
; The next two bytes are the head word LoadRecordHead copies to
; hRecordHead + 1. They become the little-endian address $64D1, still
; INCBIN in this bank. What the record uses that word for is still
; unknown.
;
; RunTwoScriptsThenTouchCell, CopyRecordToScratch, wRecordState, and
; hRecordHead are already source. rROMB0 is left alone except inside
; those calls.

; Head word still in this bank's INCBIN. Written at record byte 1.
DEF HeadWord64D1 EQU $64D1

StageScratchThenPlantHeadWord64D1::
    call RunTwoScriptsThenTouchCell
    call GateCellNearFirstRecord
    and a
    ret z
    ld a, [wRecordState]
    and a
    ret nz
    call CopyRecordToScratch
    inc hl
    ld a, LOW(HeadWord64D1)
    ld [hl+], a
    ld a, HIGH(HeadWord64D1)
    ld [hl+], a
    ret
