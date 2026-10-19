; Bank 7 at $46E4. ApplyPanelRowWords calls this once per panel word.
; Other callers in this bank pass BC = 1 or BC = 3 and a pointer into the
; $C7AB palette block.
;
; BC is the number of little-endian color words at HL. DE selects the step.
; Bit 15 of DE is ignored. $0000 and $8000 store $46C6, which walks a word
; toward black. $7FFF and $FFFF store $46DA, which walks a word toward white.
; Any other DE is split by $4586 into red, green, and blue and saved at
; $C82D, $C82C, and $C82B, and $46D0 is stored. That routine walks a word
; toward those three bytes.
;
; The chosen address is kept at $C82E. Each word is loaded into BC, entered
; through JumpHL, and written back. HL advances by two. BC counts down to
; zero. DE is restored. The steppers read the repeat count at $C830 and
; refill it from wEntryRecord ($C9DC). $4586, $46C6, $46D0, and $46DA are
; still INCBIN. JumpHL is the trampoline at $0789.

DEF SplitColorWord EQU $4586

StepColorWords::
    push de
    push hl
    ld a, d
    or $80
    cp $ff
    jr z, .white

    and $7f
    cp $00
    jr z, .black

.color:
    push bc
    ld b, d
    ld c, e
    call SplitColorWord
    ld [$C82D], a
    ld a, e
    ld [$C82C], a
    ld a, d
    ld [$C82B], a
    pop bc
    ld hl, StepColorWordTowardSaved
    ld a, l
    ld [$C82E], a
    ld a, h
    ld [$C82F], a
    jr .words

.white:
    cp e
    jr nz, .color

    ld hl, StepColorWordTowardWhite
    ld a, l
    ld [$C82E], a
    ld a, h
    ld [$C82F], a
    jr .words

.black:
    cp e
    jr nz, .color

    ld hl, StepColorWordTowardBlack
    ld a, l
    ld [$C82E], a
    ld a, h
    ld [$C82F], a

.words:
    pop hl

.word:
    push bc
    ld a, [hl+]
    ld c, a
    ld a, [hl-]
    ld b, a
    push hl
    ld a, [$C82F]
    ld h, a
    ld a, [$C82E]
    ld l, a
    call JumpHL
    pop hl
    ld a, c
    ld [hl+], a
    ld a, b
    ld [hl+], a
    pop bc
    dec bc
    ld a, c
    or b
    jr nz, .word

    pop de
    ret
