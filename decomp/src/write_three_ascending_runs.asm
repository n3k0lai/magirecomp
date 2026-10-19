; Bank 4 at $54BA. Callers pass the first tile in A and the first map
; cell in HL. PaintWindowFrameMap calls this three times when [$CD54]
; is 0, starting at $94 / $9C43, $B2 / $9CA3, and $D0 / $9D03.
;
; Each call writes ten tiles, then ten more one row down and one column
; to the right, then ten more one row below that second run. A climbs
; by one for every store. The first gap is $17 because HL has already
; advanced ten cells ($0A + $17 = $21). The second gap is $16
; ($0A + $16 = $20), so the third run keeps the second run's column.

DEF ASCENDING_RUN_LEN EQU $0A
; Ten cells already written, then one row ($20) and one column.
DEF ASCENDING_GAP_ROW_COL EQU $0017
; Ten cells already written, then exactly one row.
DEF ASCENDING_GAP_NEXT_ROW EQU $0016

WriteThreeAscendingRunsFromA::
    ld d, ASCENDING_RUN_LEN
.run1
    ld [hli], a
    inc a
    dec d
    jr nz, .run1

    ld bc, ASCENDING_GAP_ROW_COL
    add hl, bc
    ld d, ASCENDING_RUN_LEN
.run2
    ld [hli], a
    inc a
    dec d
    jr nz, .run2

    ld bc, ASCENDING_GAP_NEXT_ROW
    add hl, bc
    ld d, ASCENDING_RUN_LEN
.run3
    ld [hli], a
    inc a
    dec d
    jr nz, .run3

    ret
