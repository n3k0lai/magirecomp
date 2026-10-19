; Bank 5 at $673E. SeedXStepThenApplyXAndY calls here when the X step
; at wClearedOnRecordLoad ($C6D2) is zero.
;
; hObjectFineX ($FF8F) of $00 stores $FF. $0F stores $01. Any other
; fine X stores $00. This routine does not write rROMB0 and does not
; call out.
;
; wClearedOnRecordLoad is the name from load_record_head.asm.
; hObjectFineX is the name from queue_sprite_list.asm.

SeedXStepFromFineXEnds::
    ld a, [hObjectFineX]
    cp $00
    jr z, .storeMinusOne

    cp $0f
    jr z, .storeOne

    xor a
    ld [wClearedOnRecordLoad], a
    ret

.storeOne:
    ld a, $01
    ld [wClearedOnRecordLoad], a
    ret

.storeMinusOne:
    ld a, $ff
    ld [wClearedOnRecordLoad], a
    ret
