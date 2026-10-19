; AddBcToRecordWord5. Bank 0 at $3812.
;
; HL is a record. BC is a signed addend. AdjustA000RecordOnce calls this
; with BC = -MEASURE_UNDER (-100) when bit 0 of $D389 is clear.
;
; The big-endian word at record+5 is loaded, BC is added with wrap, and
; the sum is written back in the same byte order. $381A is the add-and-store
; tail: the word is already in HL and the destination address is already
; on the stack. Bank $7B calls that tail. There is no clamp.

AddBcToRecordWord5::
    ld de, $0005
    add hl, de
    push hl
    ld a, [hl+]
    ld l, [hl]
    ld h, a

AddBcToPushedWord::
    add hl, bc
    ld a, h
    ld c, l
    pop hl
    ld [hl+], a
    ld [hl], c
    ret
