; Bank 2 at $6BE7. InitWram7BeforeReset calls here after the eight
; bytes at $D092 are cleared and filled again by earlier setup.
;
; WRAM bank 7 is stored in wCurrentWRAMBank and selected with rSVBK, so
; the $D000 accesses below are in that bank. wCurrentWRAMBank and rSVBK
; are the names from timer_overflow.asm. MulCByB is the name from
; multiply.asm.
;
; C walks 0 through 7. [$D092+C] is the slot flag. A zero flag stores
; score 0 at $D000+C and $FF at $D008+C. A nonzero flag treats C as a
; record index: HL becomes C * $37, then $D17E + $0D. The byte there is
; kept at $D015. Three bytes later is passed in B, with A = $0A, to
; $53FB. That result is added to [$D015]; a carry stores 0 instead.
; The sum is the score at $D000+C, and $D008+C receives C + 1.
;
; The eight scores are then bubble-sorted downward. $D074 is how many
; leading entries are already finished. Each pass walks E from 7 down to
; $D074 and swaps $D000+E with the byte before it when the higher index
; is greater or equal, and swaps the matching $D008 ids the same way.
; $D010 holds an id during that swap. The pass stops once $D074 is 6.
; The ret after the jump back into the pass is not reached.

RankEightD092Slots::
    ld a, $07
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld c, $FF
.scan:
    inc c
    ld hl, $D092
    ld b, $00
    add hl, bc
    xor a
    cp [hl]
    jr z, .empty
    ld b, $37
    call MulCByB
    ld de, $000D
    add hl, de
    ld de, $D17E
    add hl, de
    ld a, [hl]
    ld [$D015], a
    ld de, $0003
    add hl, de
    ld b, [hl]
    ld a, $0A
    push bc
    call $53FB
    pop bc
    ld hl, $D015
    add a, [hl]
    jr nc, .storeScore
    xor a
.storeScore:
    ld hl, $D000
    ld b, $00
    add hl, bc
    ld [hl], a
    ld hl, $D008
    add hl, bc
    ld [hl], c
    inc [hl]
    jr .nextSlot
.empty:
    ld hl, $D000
    ld b, $00
    add hl, bc
    ld [hl], a
    ld hl, $D008
    add hl, bc
    dec a
    ld [hl], a
.nextSlot:
    ld a, $07
    cp c
    jr nz, .scan
    ld e, $07
    xor a
    ld [$D074], a
.pass:
    ld d, $00
    ld hl, $D000
    ld bc, $D008
    add hl, de
    ld a, e
    add a, c
    ld c, a
    ld a, [hl]
    dec hl
    dec bc
    cp [hl]
    jr c, .noSwap
    ld d, a
    ld a, [hl+]
    ld [hl-], a
    ld [hl], d
    ld a, [bc]
    inc bc
    ld d, a
    ld a, [bc]
    ld [$D010], a
    ld a, d
    ld [bc], a
    dec bc
    ld a, [$D010]
    ld [bc], a
.noSwap:
    dec e
    ld a, [$D074]
    cp e
    jr nz, .pass
    cp $06
    ret z
    inc a
    ld [$D074], a
    ld e, $07
    jr .pass
    ret
