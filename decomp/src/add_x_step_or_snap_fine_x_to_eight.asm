; Bank 5 at $6717. Adds the signed X step at wClearedOnRecordLoad
; ($C6D2) into hObjectFineX ($FF8F).
;
; A negative step whose sum is below $08, or a non-negative step whose
; sum is at least $08, stores $08 in fine X and clears the X step.
; Any other sum is stored as-is, with no nibble mask. This routine does
; not write rROMB0 and does not call out.
;
; wClearedOnRecordLoad is the name from load_record_head.asm.
; hObjectFineX is the name from queue_sprite_list.asm.

AddXStepOrSnapFineXToEight::
    ld hl, hObjectFineX
    ld a, [wClearedOnRecordLoad]
    ld b, a
    bit 7, a
    jr z, .nonNegative

    ld a, [hl]
    add b
    cp $08
    jr nc, .storeNegativeSum

    xor a
    ld [wClearedOnRecordLoad], a
    ld a, $08

.storeNegativeSum:
    ld [hl], a
    ret

.nonNegative:
    ld a, [hl]
    add b
    cp $08
    jr c, .storePositiveSum

    xor a
    ld [wClearedOnRecordLoad], a
    ld a, $08

.storePositiveSum:
    ld [hl], a
    ret
