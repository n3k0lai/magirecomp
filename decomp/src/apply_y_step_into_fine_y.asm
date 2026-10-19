; Bank 5 at $675A. Adds the signed Y step at wClearedOnRecordLoad + 1
; ($C6D3) into hObjectFineY ($FF90) and writes that sum back as the step.
;
; A negative step (bit 7) keeps the sum in fine Y when the sum is still
; at least $08. A sum below $08 clears the step and stores $08. A
; non-negative step keeps the sum when it is still below $08. A sum of
; $08 or more clears the step and stores $08. The compare flags survive
; the store of the sum, so the clamp test is the compare against $08.
;
; wClearedOnRecordLoad is the name from load_record_head.asm.
; hObjectFineY is the name from queue_sprite_list.asm.
; This routine does not write rROMB0 and does not call out.

ApplyYStepIntoFineY::
    ld hl, hObjectFineY
    ld a, [wClearedOnRecordLoad + 1]
    ld b, a
    bit 7, a
    jr z, .nonNegative

    ld a, [hl]
    add b
    cp $08
    ld [wClearedOnRecordLoad + 1], a
    jr nc, .storeFine

    xor a
    ld [wClearedOnRecordLoad + 1], a
    ld a, $08

.storeFine:
    ld [hl], a
    ret

.nonNegative:
    ld a, [hl]
    add b
    cp $08
    ld [wClearedOnRecordLoad + 1], a
    jr c, .storeFineNonNeg

    xor a
    ld [wClearedOnRecordLoad + 1], a
    ld a, $08

.storeFineNonNeg:
    ld [hl], a
    ret
