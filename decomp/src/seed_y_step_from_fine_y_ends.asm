; Bank 5 at $6787. The caller at $6626, still INCBIN, calls here when
; the Y step at wClearedOnRecordLoad + 1 ($C6D3) is zero.
;
; hObjectFineY ($FF90) of $00 stores $FF. $0F stores $01. Any other
; fine Y stores $00. This routine does not write rROMB0 and does not
; call out.
;
; wClearedOnRecordLoad is the name from load_record_head.asm.
; hObjectFineY is the name from queue_sprite_list.asm.

SeedYStepFromFineYEnds::
    ld a, [hObjectFineY]
    cp $00
    jr z, .storeMinusOne

    cp $0f
    jr z, .storeOne

    xor a
    ld [wClearedOnRecordLoad + 1], a
    ret

.storeOne:
    ld a, $01
    ld [wClearedOnRecordLoad + 1], a
    ret

.storeMinusOne:
    ld a, $ff
    ld [wClearedOnRecordLoad + 1], a
    ret
