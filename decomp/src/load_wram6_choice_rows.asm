; Bank 4 at $5F1A. StageCopiedBlockWindow calls here with bank 4 mapped,
; and the $582C window loop calls here again when the choice is zero.
;
; WRAM bank 6 is stored in wCurrentWRAMBank and selected with rSVBK, so
; the $D001 reads below are in that bank. Both names come from
; timer_overflow.asm. MulCByB is already source. It returns HL = C * B.
;
; $CD81 selects the path.
;
; Zero rewinds $CD21 by 3 and stores that value at $CC89 and $CC4D. The
; next three bytes, $CC4E through $CC50, are 1. $CC51 is ($CD20 + 1)
; minus the index from before the rewind.
;
; Any other value except 4 clears $CD21 and $CC89.
;
; Both of those paths store 3 at $CD3A, then copy $18 bytes from
; $D001 + 8 * $CD21 into $CD22 and join the tail.
;
; Four writes 1 at $CC4D and skips $CC4E. $CC4F and $CC50 are 0. Sixteen
; bytes at $CD2A are $FF $FF $00 $FF followed by four zeros, then that
; pattern again. $CD3A is 1. $CD21 increases by 3, and eight bytes are
; copied from $D001 + 8 * $CD21 into $CD22.
;
; If $CD20 is below $CD21 + 1, $CC51 is cleared. Otherwise $CD3A
; increments, $CC4F becomes 1, and the next eight bytes land at $CD2A.
; The same test at $CD21 + 2 fills $CD32 and sets $CC50 to 1. If $CD20
; is still below $CD21 + 3, $CC51 is cleared.
;
; The tail returns when $CD21 is 0. Otherwise that index replaces $CC4D.

DEF WRAM6_ROW_BANK EQU $06
DEF wRowIndex EQU $CD21
DEF wRowLimit EQU $CD20
DEF wRowCount EQU $CD3A
DEF wRowScratch EQU $CC89
DEF wRowFlags EQU $CC4D
DEF wRowFlag2 EQU $CC4F
DEF wRowFlag3 EQU $CC50
DEF wRowRemain EQU $CC51
DEF wRowBytes EQU $CD22
DEF wRowBytes2 EQU $CD2A
DEF wRowBytes3 EQU $CD32
DEF WRAM6_ROWS EQU $D001
DEF ROW_STRIDE EQU $08
DEF THREE_ROWS EQU $18
DEF ROW_STEP EQU $03

LoadWRAM6ChoiceRows::
    ld a, WRAM6_ROW_BANK
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld a, [$CD81]
    cp $00
    jr z, .rewind
    cp $04
    jr z, .slotFour
    xor a
    ld [wRowIndex], a
    ld [wRowScratch], a
    jr .copyThree

.rewind:
    ld hl, wRowIndex
    ld a, [hl]
    sub ROW_STEP
    ld [hl], a
    ld [wRowScratch], a
    ld hl, wRowFlags
    ld [hl+], a
    ld a, $01
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld a, [wRowIndex]
    add ROW_STEP
    ld b, a
    ld a, [wRowLimit]
    inc a
    sub b
    ld [hl+], a

.copyThree:
    ld a, $03
    ld [wRowCount], a
    ld a, [wRowIndex]
    ld b, a
    ld c, ROW_STRIDE
    call MulCByB
    ld bc, WRAM6_ROWS
    add hl, bc
    ld bc, wRowBytes
    ld d, THREE_ROWS
.copy18:
    ld a, [hl+]
    ld [bc], a
    inc bc
    dec d
    jr nz, .copy18
    jp .tail

.slotFour:
    ld a, $01
    ld hl, wRowFlags
    ld [hl+], a
    xor a
    inc hl
    ld [hl+], a
    ld [hl+], a
    ld hl, wRowBytes2
    ld a, $FF
    ld [hl+], a
    ld [hl+], a
    xor a
    ld [hl+], a
    ld a, $FF
    ld [hl+], a
    xor a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld a, $FF
    ld [hl+], a
    ld [hl+], a
    xor a
    ld [hl+], a
    ld a, $FF
    ld [hl+], a
    xor a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld a, $01
    ld [wRowCount], a
    ld a, [wRowIndex]
    add ROW_STEP
    ld [wRowIndex], a
    ld b, a
    ld c, ROW_STRIDE
    call MulCByB
    ld bc, WRAM6_ROWS
    add hl, bc
    ld bc, wRowBytes
    ld d, ROW_STRIDE
.copy8First:
    ld a, [hl+]
    ld [bc], a
    inc bc
    dec d
    jr nz, .copy8First
    ld a, [wRowIndex]
    inc a
    ld b, a
    ld a, [wRowLimit]
    cp b
    jr c, .clearRemain
    ld hl, wRowCount
    inc [hl]
    ld a, $01
    ld [wRowFlag2], a
    ld a, [wRowIndex]
    inc a
    ld b, a
    ld c, ROW_STRIDE
    call MulCByB
    ld bc, WRAM6_ROWS
    add hl, bc
    ld bc, wRowBytes2
    ld d, ROW_STRIDE
.copy8Second:
    ld a, [hl+]
    ld [bc], a
    inc bc
    dec d
    jr nz, .copy8Second
    ld a, [wRowIndex]
    inc a
    inc a
    ld b, a
    ld a, [wRowLimit]
    cp b
    jr c, .clearRemain
    ld hl, wRowCount
    inc [hl]
    ld a, $01
    ld [wRowFlag3], a
    ld a, [wRowIndex]
    inc a
    inc a
    ld b, a
    ld c, ROW_STRIDE
    call MulCByB
    ld bc, WRAM6_ROWS
    add hl, bc
    ld bc, wRowBytes3
    ld d, ROW_STRIDE
.copy8Third:
    ld a, [hl+]
    ld [bc], a
    inc bc
    dec d
    jr nz, .copy8Third
    ld a, [wRowIndex]
    add ROW_STEP
    ld b, a
    ld a, [wRowLimit]
    cp b
    jr nc, .tail

.clearRemain:
    xor a
    ld [wRowRemain], a

.tail:
    ld a, [wRowIndex]
    and a
    ret z
    ld [wRowFlags], a
    ret
