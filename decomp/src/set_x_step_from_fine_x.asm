; Bank 5 at $66A6. The uncovered byte $66AE is the low byte of the
; hObjectFineX operand below.
;
; A nonzero X step at wClearedOnRecordLoad ($C6D2) is applied with
; ApplyFineXDelta. A zero step reads hObjectFineX ($FF8F). Exactly $08
; jumps to $66C8, which calls ApplyFineYDelta. A fine X above $08 stores
; $FF as the step; a fine X below $08 stores $01. Either store then
; calls ApplyFineXDelta.
;
; wClearedOnRecordLoad is the name from load_record_head.asm.
; hObjectFineX is the name from queue_sprite_list.asm.
; ApplyFineXDelta is the routine at $67B1. $66C8 is still INCBIN.
; This routine does not write rROMB0.

SetXStepFromFineX::
    ld a, [wClearedOnRecordLoad]
    cp $00
    jr nz, .applyX

    ld a, [hObjectFineX]
    cp $08
    jr z, $66c8
    jr nc, .storeMinusOne

    ld a, $01
    ld [wClearedOnRecordLoad], a

.applyX:
    call ApplyFineXDelta
    ret

.storeMinusOne:
    ld a, $ff
    ld [wClearedOnRecordLoad], a
    call ApplyFineXDelta
    ret
