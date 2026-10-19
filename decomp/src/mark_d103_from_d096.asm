; Bank 2 at $72A7.
;
; A zero byte at $D096 stores 1 in $CCA7, calls bank 5 at $56AF, then
; writes $20, $01, and $14 to $D068, $D069, and $D06A and $05 to $D103.
; Those three bytes are the index, spend count, and pair later copied
; into a $D110 record by FillD110FromIndexedEntry.
;
; Any other byte stores 0 in $CCA7, calls the same bank 5 routine, and
; writes $09 to $D103. The jr lands on the shared ret.
;
; CallBankedHL is already source. Bank 5's $56AF is still INCBIN.

MarkD103FromD096::
    ld a, [$D096]
    and a
    jr z, .zero

    xor a
    ld [$CCA7], a
    ld hl, $56AF
    ld e, $05
    call CallBankedHL
    ld a, $09
    ld [$D103], a
    jr .return

.zero:
    ld a, $01
    ld [$CCA7], a
    ld hl, $56AF
    ld e, $05
    call CallBankedHL
    ld a, $20
    ld [$D068], a
    ld a, $01
    ld [$D069], a
    ld a, $14
    ld [$D06A], a
    ld a, $05
    ld [$D103], a

.return:
    ret
