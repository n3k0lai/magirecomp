; Bank 1 at $4587. NudgeScrollDeltasFromScriptByte jumps here with ROM
; bank 1 mapped. H is the edge flags at $C842, L is 2 (one count per
; axis), and D is the signed script step. BC is the script pointer.
;
; hFFA6 is the column to reach and hFFA7 is the row. Each axis is
; compared with the map column at $C85F or the map row at $C860. A
; match decrements L and leaves that delta alone. A column above the
; target adds D to the horizontal pixel delta at $C843 unless bit 1 of
; H blocks a right step. A column below the target adds the negation of
; D unless bit 2 blocks a left step. The row does the same with $C844:
; bit 5 blocks a down step and bit 6 blocks an up step.
;
; L still nonzero means an axis can still move, so BC stays put and
; this returns. L landing on 0 consumes the script byte into hScriptPtr
; and plants INITIAL_SCRIPT_HANDLER. Those two handler stores, and the
; pointer stores, are the 3-byte form.
;
; hScriptPtr, hScriptHandler, and INITIAL_SCRIPT_HANDLER are the names
; from reset.asm.

NudgeCameraDeltas::
    ldh a, [$ffa6]
    ld e, a
    ld a, [$c85f]
    cp e
    jr c, .column_low

    jr nz, .column_high

.column_done:
    dec l
    jr .row

.column_high:
    bit 2, h
    jr nz, .column_done

    ld a, d
    cpl
    inc a
    ld e, a
    jr .add_column

.column_low:
    bit 1, h
    jr nz, .column_done

    ld e, d

.add_column:
    ld a, [$c843]
    add e
    ld [$c843], a

.row:
    ldh a, [$ffa7]
    ld e, a
    ld a, [$c860]
    cp e
    jr c, .row_low

    jr nz, .row_high

.row_done:
    dec l
    jr .finish

.row_high:
    bit 6, h
    jr nz, .row_done

    ld a, d
    cpl
    inc a
    ld e, a
    jr .add_row

.row_low:
    bit 5, h
    jr nz, .row_done

    ld e, d

.add_row:
    ld a, [$c844]
    add e
    ld [$c844], a

.finish:
    ld a, l
    and a
    ret nz

    inc bc
    ld a, b
    ld [hScriptPtr + 1], a
    ld a, c
    ld [hScriptPtr], a
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ld [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ld [hScriptHandler + 1], a
    ret
