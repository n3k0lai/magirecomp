; SampleRecord14Contribution. Bank 2 at $5A64.
;
; SpendMeasureHundred calls this fourth of five samplers. The byte returned
; in A is stored at $D38F and added to record+14, capped at $63.
;
; AddDividerStep updates $FFA9 and returns it. DivideCByB with B = $0A
; leaves that byte modulo 10 in L. That index selects one byte from a
; 10-byte table chosen by [$D113], which is record+3 when the record is
; the usual $D110 buffer:
;
;   $00 -> $5B17   00 00 01 01 01 01 00 00 02 00
;   $02 -> $5B21   00 02 01 01 01 01 00 00 02 00
;   $04 -> $5B2B   00 03 01 01 01 01 00 01 02 00
;   $06 -> $5B17
;   else -> $5B2B
;
; A second AddDividerStep is divided by 3. When the remainder is 2, one
; is added to the table byte. Other remainders add nothing.
;
; Those tables are still INCBIN, packed after the eight-byte table at
; $5B0F. AddDividerStep and DivideCByB are already source. The first
; divide uses B = $0A and then clears it; the second uses B = $03.
; C is the table index, then the second sample.

SampleRecord14Contribution::
    call AddDividerStep
    ld c, a
    ld b, $0a
    call DivideCByB
    ld c, l
    ld b, $00
    ld a, [$D113]
    cp $00
    jr nz, .notZero

    ld hl, $5B17
    jr .index

.notZero:
    cp $04
    jr nz, .notFour

    ld hl, $5B2B
    jr .index

.notFour:
    cp $02
    jr nz, .notTwo

    ld hl, $5B21
    jr .index

.notTwo:
    cp $06
    jr nz, .defaultTable

    ld hl, $5B17
    jr .index

.defaultTable:
    ld hl, $5B2B

.index:
    add hl, bc
    ld a, [hl]
    push af
    call AddDividerStep
    ld c, a
    ld b, $03
    call DivideCByB
    ld a, l
    and $02
    srl a
    ld b, a
    pop af
    add b
    ret
