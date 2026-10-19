; Bank 1 at $641D. StageScratchThenPlantHeadWord64D1 calls this
; before it plants head word $64D1, and returns when A is zero.
;
; A is zero unless bit 2 of the latched $FFAA copy at $FFAB is set,
; wRecordState is 0, wUnknownC6EE is 0, and $C716 is 0. $C716 is
; wThirdScriptRecord + 2; that name is defined later. $FFAB is read
; with ldh. hLatchedFFAB is defined later, in handle_start_press.asm.
;
; The record at hRecordPointer and the first list record at
; wRecordFlags each hold a cell pair at byte 5. The pair is taken as
; two bytes, first then second. The loads of hRecordPointer are the
; 3-byte form. An exact pair match returns 1.
;
; Otherwise the low two bits of the first list record's opening byte
; pick a window around that pair. 0 and 3 keep the first byte equal.
; 0 allows the second byte to be equal or one below; 3 allows it equal
; or one above. The `add a, $00` on those paths leaves the first byte
; unchanged, so the following carry test does not fire after the equal
; check. 1 allows the first byte equal or one below, and the second
; byte within one of the list byte. 2 allows the first byte equal or
; one above, with that same second-byte window. A miss returns 0.
;
; wRecordState is the name from restore_scratch_record.asm.
; wUnknownC6EE is the name from setup_window.asm. wRecordFlags is the
; name from init_pointer_list.asm. hRecordPointer is the name from
; copy_record_to_scratch.asm. Nothing here writes rROMB0.

; Byte offset of the two-byte cell pair inside a $1B record.
DEF RECORD_CELL_PAIR EQU $0005

GateCellNearFirstRecord::
    ldh a, [$FFAB]
    bit 2, a
    jp z, .reject

    ld a, [wRecordState]
    cp $00
    jp nz, .reject

    ld a, [wUnknownC6EE]
    cp $00
    jp nz, .reject

    ld a, [$C716]
    and a
    jp nz, .reject

    ld a, [hRecordPointer + 1]
    ld h, a
    ld a, [hRecordPointer]
    ld l, a
    ld de, RECORD_CELL_PAIR
    add hl, de
    ld a, [hl+]
    ld c, [hl]
    ld b, a
    ld hl, wRecordFlags
    add hl, de
    ld a, [hl+]
    ld d, a
    ld e, [hl]
    push bc
    ld h, d
    ld l, e
    ld a, c
    cpl
    ld c, a
    ld a, b
    cpl
    ld b, a
    inc bc
    add hl, bc
    ld a, h
    or l
    pop bc
    jr z, .allow

    ld a, [wRecordFlags]
    and $03
    cp $00
    jr z, .facing0

    cp $01
    jr z, .facing1

    cp $02
    jr z, .facing2

    ld a, b
    cp d
    jr nz, .reject

    add a, $00
    cp d
    jr c, .reject

    ld a, c
    sub $02
    cp e
    jr nc, .reject

    add a, $02
    cp e
    jr c, .reject

    jr .allow

.facing0:
    ld a, b
    cp d
    jr nz, .reject

    add a, $00
    cp d
    jr c, .reject

    ld a, c
    sub $01
    cp e
    jr nc, .reject

    add a, $02
    cp e
    jr c, .reject

    jr .allow

.facing1:
    ld a, b
    sub $01
    cp d
    jr nc, .reject

    add a, $02
    cp d
    jr c, .reject

    ld a, c
    add a, $01
    cp e
    jr c, .reject

    sub $03
    cp e
    jr nc, .reject

    jr .allow

.facing2:
    ld a, b
    sub $02
    cp d
    jr nc, .reject

    add a, $02
    cp d
    jr c, .reject

    ld a, c
    add a, $01
    cp e
    jr c, .reject

    sub $03
    cp e
    jr nc, .reject

.allow:
    ld a, $01
    ret

.reject:
    xor a
    ret
