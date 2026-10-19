; Bank 1 at $517C. DispatchZeroStepCellRun calls this and reads the
; run length in C. HL is a map cell and DE is the stride. The first
; cell is copied into B and is not read again here. The byte at $C9A6
; has no name.
;
; When that byte is at least 4, only $02 continues the run. When it is
; below 4, $01 and $02 both continue. $00 and $82 end the run and keep
; the count. Any other cell after the first step forces C to 3.

CountCellRun::
    ld a, [$c9a6]
    sub $04
    jp c, .underFour

    ld c, $00
    ld a, [hl]
    ld b, a
    cp $02
    ret nz

    inc c
    add hl, de
    ld a, [hl]
    cp $02
    jr nz, .checkEnd

.advance:
    inc c
    add hl, de
    ld a, [hl]

.checkEnd:
    cp $00
    ret z

    cp $82
    ret z

    ld c, $03
    ret

.underFour:
    ld c, $00
    ld a, [hl]
    ld b, a
    cp $01
    jr z, .step

    cp $02
    ret nz

.step:
    inc c
    add hl, de
    ld a, [hl]
    cp $01
    jr z, .backToAdvance

    cp $02
    jr nz, .checkEnd

.backToAdvance:
    jr .advance
