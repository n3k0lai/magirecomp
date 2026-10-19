; Add E to each of BC bytes at HL, replacing a sum that is not below D.
;
; Each pass loads [HL], adds E, and compares that 8-bit sum with D. A sum
; below D is stored. Any other sum, including one equal to D, is replaced
; with D. A sum that wrapped past $FF is judged only by its low 8 bits.
; HL advances one byte. BC counts down, and a count of zero wraps and
; walks 65536 bytes. On return BC is zero and HL points one past the last
; byte. The tilemap walks that are still INCBIN call this with D = $FF.

ClampAddedByte::
.byte:
    ld a, [hl]
    add e
    cp d
    jr c, .store
    ld a, d
.store:
    ld [hl+], a
    dec bc
    ld a, c
    or b
    jr nz, .byte
    ret
