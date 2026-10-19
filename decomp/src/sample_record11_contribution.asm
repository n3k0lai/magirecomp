; SampleRecord11Contribution. Bank 2 at $5AFA.
;
; SpendMeasureHundred calls this first of five samplers. The byte returned
; in A is stored at $D38C and added to record+11, capped at $63.
;
; AddDividerStep runs twice. The first result stays in B. The second is
; nibble-swapped, then ANDed with B and with $07. Those three bits index
; the table at $5B0F, which is still INCBIN. Its eight bytes are
; $01, $02, $01, $02, $00, $03, $02, $01. A returns the indexed byte.
;
; AddDividerStep is already source. B is the first sample; C is the index.

SampleRecord11Contribution::
    call AddDividerStep
    ld b, a
    call AddDividerStep
    swap a
    and b
    and $07
    ld c, a
    ld b, $00
    ld hl, $5B0F
    add hl, bc
    ld a, [hl]
    ret
