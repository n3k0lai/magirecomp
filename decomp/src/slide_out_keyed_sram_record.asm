; Bank 3 at $56BD. ResolveShortListChoice calls here while SRAM bank
; [$C727] plus one is enabled, after choice $0B. This bank stays mapped.
; The routine does not write rROMB0.
;
; [$CD68] is LIST_KEY. One less than that key is the record to remove.
; Records are CHOICE_RECORD_STRIDE ($25) bytes from sChoiceRecord ($A025).
; The index is kept at $CC89, the same byte as wUnknownCC89.
;
; Bytes $22 and $23 of the removed record are stored at LIST_SIDE_A and
; LIST_SIDE_B ($CD7A and $CD7B). The caller increments $A019 through those
; bytes when they are not zero. The extra inc bc after the second store
; is overwritten by the destination pointer popped into BC.
;
; Each later record is copied onto the previous one. The destination
; index starts at key minus one and the copy stops when that index is
; $CF. Record $CF is the $25 bytes at $BE10. The caller then fills those
; bytes with $FF.
;
; MulCByB, LIST_KEY, LIST_SIDE_A, sChoiceRecord, and CHOICE_RECORD_STRIDE
; are already named in source.

; Running destination index. Stops the slide at record $CF.
DEF sShortRecordIndex EQU $CC89
DEF SHORT_RECORD_LAST EQU $CF

; Side bytes inside the removed record, just before the next record.
DEF SHORT_SIDE_OFFSET EQU $0022

SlideOutKeyedSRAMRecord::
    ld a, [LIST_KEY]
    dec a
    ld [sShortRecordIndex], a
    ld b, a
    ld c, CHOICE_RECORD_STRIDE
    call MulCByB
    ld bc, sChoiceRecord
    add hl, bc
    push hl
    ld bc, SHORT_SIDE_OFFSET
    add hl, bc
    ld bc, LIST_SIDE_A
    ld a, [hl+]
    ld [bc], a
    inc bc
    ld a, [hl+]
    ld [bc], a
    inc bc
    pop hl
    push hl
    ld bc, CHOICE_RECORD_STRIDE
    add hl, bc
    pop bc
.slide:
    ld a, [sShortRecordIndex]
    cp SHORT_RECORD_LAST
    ret z
    ld d, CHOICE_RECORD_STRIDE
.copyRecord:
    ld a, [hl+]
    ld [bc], a
    inc bc
    dec d
    jr nz, .copyRecord
    ld a, [sShortRecordIndex]
    inc a
    ld [sShortRecordIndex], a
    jr .slide
