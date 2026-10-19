; Turn the low 10 bits of DE into three decimal digits.
;
; DrawStartScreenMap loads a word into DE and calls here. It later adds
; $A1 to $C92F, $C92E, and $C92D and writes those tiles. $C92F is the
; hundreds place, $C92E the tens, and $C92D the ones.
;
; D is masked with 3. That selects the decimal image of 0, 256, 512, or
; 768 (00 00 00, 02 05 06, 05 01 02, or 07 06 08). E is split into
; hundreds, tens, and a remainder, then added with one carry from ones
; into tens and one from tens into hundreds. Hundreds is not reduced
; again, so 1000 through 1023 leave 10 in $C92F.
;
; $0444, $0447, $0455, $045A, $0468, $046D, and $0482 sit in the middle
; of this routine. Something still inside an INCBIN calls or jumps to
; them. What those entries pass in is still unknown.

DEF wStartDigitOnes EQU $C92D
DEF wStartDigitTens EQU $C92E
DEF wStartDigitHundreds EQU $C92F

FormatStartDigits::
    xor a
    ld [wStartDigitHundreds], a
    ld [wStartDigitTens], a
    ld [wStartDigitOnes], a
    ld a, d
    and $03
    jr z, .addLow

    cp $03
    jr nz, .not768

    ld a, $07
    ld [wStartDigitHundreds], a
    ld a, $06
    ld [wStartDigitTens], a
    ld a, $08
    ld [wStartDigitOnes], a
    jr .addLow

.not768:
    cp $02
    jr nz, .seed256

    ld a, $05
.entry0444:
    ld [wStartDigitHundreds], a
.entry0447:
    ld a, $01
    ld [wStartDigitTens], a
    ld a, $02
    ld [wStartDigitOnes], a
    jr .addLow

.seed256:
    ld a, $02
.entry0455:
    ld [wStartDigitHundreds], a
    ld a, $05
.entry045A:
    ld [wStartDigitTens], a
    ld a, $06
    ld [wStartDigitOnes], a

.addLow:
    ld a, [wStartDigitHundreds]
    ld b, a
    ld a, e
    ld c, a
.entry0468:
.hundreds:
    sub $64
    jr c, .storeHundreds
    inc b
.entry046D:
    ld c, a
    jr .hundreds

.storeHundreds:
    ld a, b
    ld [wStartDigitHundreds], a
    ld a, [wStartDigitTens]
    ld b, a
    ld a, c
.tens:
    sub $0a
    jr c, .storeTens
    inc b
    ld c, a
    jr .tens

.storeTens:
    ld a, b
.entry0482:
    ld [wStartDigitTens], a
    ld a, [wStartDigitOnes]
    add c
    ld [wStartDigitOnes], a
    sub $0a
    jr c, .carryTens

    ld [wStartDigitOnes], a
    ld a, [wStartDigitTens]
    inc a
    ld [wStartDigitTens], a

.carryTens:
    ld a, [wStartDigitTens]
    sub $0a
    jr c, .done

    ld [wStartDigitTens], a
    ld a, [wStartDigitHundreds]
    inc a
    ld [wStartDigitHundreds], a

.done:
    ret

FormatStartDigitsEnd:
