; Bank 5 at $6884, called from SaveStepThenApplyOrDispatch.
;
; Clears $C6D5, then classifies the signed X step at wClearedOnRecordLoad
; against hObjectFineX ($FF8F). A negative step whose sum is below $08
; stores $01. A positive step whose sum is at least $09 stores $04.
; A zero step, or a sum that stays on the other side of those tests,
; stores $07. The same tests on the Y step at wClearedOnRecordLoad + 1
; and hObjectFineY ($FF90) then adjust that byte: a negative step below
; $08 subtracts one, a positive step at or above $09 adds zero, and every
; other Y step adds one. The sum is returned in A and left out of $C6D5.
;
; A result of $08 is the pair that never took the low X class or the
; positive-Y class. The caller applies the fine deltas in that case and
; dispatches the other classes through the word tables at $651E and $652E.
;
; wClearedOnRecordLoad is the name from load_record_head.asm.
; hObjectFineX and hObjectFineY are the names from queue_sprite_list.asm.
; This routine does not write rROMB0 and does not call out.

ClassifyStepAgainstFine8::
    ld a, $00
    ld [$c6d5], a
    ld a, [wClearedOnRecordLoad]
    bit 7, a
    jr z, .xNonNegative

    ld b, a
    ld a, [$ff8f]
    add b
    cp $08
    jr nc, .xNeither

    ld a, $01
    jr .storeX

.xNonNegative:
    cp $00
    jr z, .xNeither

    ld b, a
    ld a, [$ff8f]
    add b
    cp $09
    jr c, .xNeither

    ld a, $04
    jr .storeX

.xNeither:
    ld a, $07

.storeX:
    ld [$c6d5], a
    ld a, [wClearedOnRecordLoad + 1]
    bit 7, a
    jr z, .yNonNegative

    ld b, a
    ld a, [$ff90]
    add b
    cp $08
    jr nc, .yNeither

    ld b, $ff
    jr .addY

.yNonNegative:
    cp $00
    jr z, .yNeither

    ld b, a
    ld a, [$ff90]
    add b
    cp $09
    jr c, .yNeither

    ld b, $00
    jr .addY

.yNeither:
    ld b, $01

.addY:
    ld a, [$c6d5]
    add b
    ret

ClassifyStepAgainstFine8End:
