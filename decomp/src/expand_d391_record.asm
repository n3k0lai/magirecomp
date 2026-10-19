; Bank 4 at $411A. InitWram7BeforeReset stores [$D391] * $2D + $415B
; at $CD8D, stores $CD91 at $CD8F, and calls here. The bytes written
; through the $CD8F pointer are later copied from $CD91 to $D336.
;
; Each record is $2D bytes and still INCBIN at $415B. This reads the
; first 27 bytes and writes 30:
;   +0       [$D391]
;   +1       record byte 0
;   +2..+4   zero
;   +5..+6   record bytes 2 and 3
;   +7..+8   those same two bytes again
;   +9..+18  record bytes 4 through 13
;   +19      zero
;   +20..+21 record bytes 14 and 15
;   +22..+29 record bytes 19 through 26
; Byte 1, bytes 16 through 18, and bytes 27 through 44 are left unread.
; wOpcode25Second is the name from lcd_off_setup.asm.

ExpandD391Record::
    ld hl, $CD8D
    ld a, [hl+]
    ld b, [hl]
    ld c, a
    ld hl, $CD8F
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld a, [wOpcode25Second]
    ld [hl+], a
    ld a, [bc]
    ld [hl+], a
    inc bc
    xor a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    inc bc
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld a, [bc]
    ld [hl+], a
    inc bc
    dec bc
    dec bc
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld d, $0A
.copyTen:
    ld a, [bc]
    ld [hl+], a
    inc bc
    dec d
    jr nz, .copyTen
    xor a
    ld [hl+], a
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld a, [bc]
    ld [hl+], a
    inc bc
    inc bc
    inc bc
    ld d, $08
.copyEight:
    ld a, [bc]
    ld [hl+], a
    inc bc
    dec d
    jr nz, .copyEight
    ret
