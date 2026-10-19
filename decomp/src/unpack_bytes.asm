; Copy a packed stream from HL to DE.
;
; Each command starts with a control byte. Bits 7 and 6 pick the command.
; The low six bits are a length. A short length of zero returns. A long
; length is those six bits in B and the next byte in C, and a count of zero
; wraps through the decrement. After a command the routine reads the next
; control byte.
;
; 00: copy that many following bytes.
; 01: repeat the next byte that many times.
; 10: copy the 14-bit count of following bytes.
; 11: repeat the next byte for the 14-bit count, then advance HL past it.

UnpackBytes::
    ld a, [hl]
    bit 6, a
    jr nz, .longCommand
    bit 7, a
    jr nz, .repeatShortJump
    jp .copyShort

.repeatShortJump:
    jp .repeatShort

.longCommand:
    bit 7, a
    jr nz, .repeatLongJump
    jp .copyLong

.repeatLongJump:
    jp .repeatLong

.copyShort:
    ld a, [hl+]
    and $3f
    and a
    ret z
    ld c, a
.copyShortByte:
    ld a, [hl+]
    ld [de], a
    inc de
    dec c
    jr nz, .copyShortByte
    jp UnpackBytes

.copyLong:
    ld a, [hl+]
    and $3f
    ld b, a
    ld a, [hl+]
    ld c, a
.copyLongByte:
    ld a, [hl+]
    ld [de], a
    inc de
    dec bc
    ld a, c
    or b
    jr nz, .copyLongByte
    jp UnpackBytes

.repeatShort:
    ld a, [hl+]
    and $3f
    and a
    ret z
    ld c, a
    ld a, [hl+]
.repeatShortByte:
    ld [de], a
    inc de
    dec c
    jr nz, .repeatShortByte
    jp UnpackBytes

.repeatLong:
    ld a, [hl+]
    and $3f
    ld b, a
    ld a, [hl+]
    ld c, a
.repeatLongByte:
    ld a, [hl]
    ld [de], a
    inc de
    dec bc
    ld a, c
    or b
    jr nz, .repeatLongByte
    inc hl
    jp UnpackBytes
