; Add $C6F5 into $C6F6. A carry increments $C6F7 and the sum stored at
; $C6F6 is 0. $C6F5 is then cleared. $C6F8, $C6FA, and $C6FC each move
; one byte forward ($C6F9, $C6FB, $C6FD) and the source byte is cleared.
; WriteQuadRecords left those three destinations untouched.
;
; wUnknownC6F5 is the name from write_quad_records.asm.
;
; .shift_two is $28FE. Bank $54 calls it when NZ, and bank $5E loads it
; into BC. HL must already point at the byte before the pair to shift.
; .store_and_shift is $2902. Bank $08 jumps here. Several banks load the
; address into BC. A is stored at HL, then the byte two ahead is copied
; one byte forward and cleared. .store_and_skip is $2907. Bank $44 jumps
; here when NZ. Banks $29, $51, and $62 load the address into a register
; pair. A is stored at HL, and HL moves two bytes forward.

AddAndShiftUnknown::
    ld hl, wUnknownC6F5
    ld a, [hl+]
    add [hl]
    jr nc, .store_sum

    ld a, [wUnknownC6F5 + 2]
    inc a
    ld [wUnknownC6F5 + 2], a
    xor a

.store_sum:
    ld [hl-], a
    xor a
    ld [hl], a
    ld hl, wUnknownC6F5 + 3
    ld a, [hl+]
    ld [hl-], a
    xor a
    ld [hl+], a

.shift_two:
    inc hl
    ld a, [hl+]
    ld [hl-], a
    xor a

.store_and_shift:
    ld [hl+], a
    inc hl
    ld a, [hl+]
    ld [hl-], a
    xor a

.store_and_skip:
    ld [hl+], a
    inc hl
    ret
