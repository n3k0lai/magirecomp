; Step index for the value in C. Zero returns 0. One returns 1.
; From 2 upward, C falls into a wider band and A returns 2 through $10.
; The bands start at 2, 5, $0B, $13, $1D, $29, $37, $47, $59, $6D, $83,
; $9B, $B5, $D0, and $EE. Anything from $EE through $FF returns $10.
; Values under $29 are handled first; $29 and above share the later bands.

BucketFromC::
    ld a, c
    and a
    ret z
    cp $29
    jr nc, .from7
    cp $02
    jr nc, .from2
    ld a, $01
    ret

.from2:
    cp $05
    jr nc, .from3
    ld a, $02
    ret

.from3:
    cp $0b
    jr nc, .from4
    ld a, $03
    ret

.from4:
    cp $13
    jr nc, .from5
    ld a, $04
    ret

.from5:
    cp $1d
    jr nc, .six
    ld a, $05
    ret

.six:
    ld a, $06
    ret

.from7:
    cp $37
    jr nc, .from8
    ld a, $07
    ret

.from8:
    cp $47
    jr nc, .from9
    ld a, $08
    ret

.from9:
    cp $59
    jr nc, .from10
    ld a, $09
    ret

.from10:
    cp $6d
    jr nc, .from11
    ld a, $0a
    ret

.from11:
    cp $83
    jr nc, .from12
    ld a, $0b
    ret

.from12:
    cp $9b
    jr nc, .from13
    ld a, $0c
    ret

.from13:
    cp $b5
    jr nc, .from14
    ld a, $0d
    ret

.from14:
    cp $d0
    jr nc, .from15
    ld a, $0e
    ret

.from15:
    cp $ee
    jr nc, .sixteen
    ld a, $0f
    ret

.sixteen:
    ld a, $10
    ret
