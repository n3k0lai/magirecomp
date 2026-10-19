; Queued map-column copy. StepHorizontalScroll exits here with ROM bank 7
; mapped. $C891 is the column-load countdown.
;
; Zero returns at once. Any value other than 2 jumps to $4E2B, which copies
; the attribute half of a column already queued in $C895-$C89E. The value 2
; is this tile pass: it is saved at $C892, then ten metatile ids are read
; from the map word at $C88D/$C88E. WRAM bank 3 is mapped for that read.
; $C847 is the stride between rows and B stays 0, so BC is that stride.
;
; Bit 3 of the horizontal fine position at $C85D picks the metatile column
; (0 or 1) and stores it at $C893. The vertical fine position at $C85E is
; copied to $C894. WRAM bank 2 then supplies the definitions at $D000.
; Each id becomes $D000 + id * 4 + column. The two bytes of that column are
; the top and bottom tiles; the other column is skipped. They are written
; at $C116. Bit 3 of $C894 set means the screen starts halfway through the
; first metatile, so its top tile is left out.
;
; $C88F/$C890 is the BG-map address of the column. Its high byte is masked
; to two bits and biased by $98 so each step stays in $9800-$9BFF. Nineteen
; row addresses, one every $20 bytes, are stored at $C89F-$C8C4. wCurrentWRAMBank
; and rSVBK are the names from timer_overflow.asm.

CopyQueuedColumn::
    ld a, [$c891]
    and a
    ret z

    cp $02
    jp nz, $4e2b

    ld [$c892], a
    ld b, $00
    ld a, [$c847]
    ld c, a
    ld a, [$c88e]
    ld h, a
    ld a, [$c88d]
    ld l, a
    ld a, $03
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld a, [hl]
    ld [$c895], a
    add hl, bc
    ld a, [hl]
    ld [$c896], a
    add hl, bc
    ld a, [hl]
    ld [$c897], a
    add hl, bc
    ld a, [hl]
    ld [$c898], a
    add hl, bc
    ld a, [hl]
    ld [$c899], a
    add hl, bc
    ld a, [hl]
    ld [$c89a], a
    add hl, bc
    ld a, [hl]
    ld [$c89b], a
    add hl, bc
    ld a, [hl]
    ld [$c89c], a
    add hl, bc
    ld a, [hl]
    ld [$c89d], a
    add hl, bc
    ld a, [hl]
    ld [$c89e], a
    add hl, bc
    ld de, $0000
    ld a, [$c85d]
    bit 3, a
    jr z, .subcolumn

    ld e, $01

.subcolumn:
    ld a, e
    ld [$c893], a
    ld a, [$c85e]
    ld [$c894], a
    ld a, $02
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld bc, $c116
    ld a, [$c895]
    ld l, a
    xor a
    sla l
    adc d
    sla a
    sla l
    adc $d0
    ld h, a
    ld a, l
    add e
    ld l, a
    ld a, [$c894]
    bit 3, a
    jr nz, .skip_top

    ld a, [hl]
    ld [bc], a
    inc bc

.skip_top:
    inc hl
    inc hl
    ld a, [hl]
    ld [bc], a
    inc bc

FOR metatile, $C896, $C89F
    ld a, [metatile]
    ld l, a
    xor a
    sla l
    adc d
    sla l
    rla
    add $d0
    ld h, a
    ld a, l
    add e
    ld l, a
    ld a, [hl+]
    ld [bc], a
    inc bc
    inc hl
    ld a, [hl]
    ld [bc], a
    inc bc
ENDR

    ld bc, $0020
    ld de, $0398
    ld a, [$c890]
    ld h, a
    ld a, [$c88f]
    ld l, a
    ld a, l
    ld [$c89f], a
    ld a, h
    and d
    add e
    ld h, a
    ld [$c8a0], a

FOR row, $C8A1, $C8C5, 2
    add hl, bc
    ld a, l
    ld [row], a
    ld a, h
    and d
    add e
    ld h, a
    ld [row + 1], a
ENDR

    add hl, bc
    ret
