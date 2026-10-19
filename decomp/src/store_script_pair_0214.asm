; Skip three bytes of the record at HL, store $02 then $14, skip two
; more, and return.
;
; HL ends two bytes past the $14. The three bytes before the pair and the
; two after it stay as they were. $02 $14 is the same pair WriteQuadRecords
; stores in the quads at $C70E and $C71C. What the skipped fields mean is
; still unknown. Callers use this while filling a script record. BC is not
; touched.

StoreScriptPair0214::
    inc hl
    inc hl
    inc hl
    ld a, $02
    ld [hl+], a
    ld a, $14
    ld [hl+], a
    inc hl
    inc hl
    ret
