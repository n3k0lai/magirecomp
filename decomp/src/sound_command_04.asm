; Sound command $04 from the word table at $4DA6.
; RunSoundStream calls it while ROM bank $30 stays mapped, then returns
; without walking further. BC is the stream cursor just past this command,
; and $DF9C is the stream index. The next tick resumes from $DF9A.
;
; The word at $DF92, indexed by the stream, is a countdown. When that word
; is zero, four operand bytes arm it. Operand 1 selects the source: zero
; copies operand 2 as the high byte and operand 3 as the low byte. Nonzero
; loads that pair into HL, calls $41B9, and stores one past the word that
; call returns. $41B9 steps the byte at $DF03 and folds a byte of it into
; the range of the nonzero half of HL.
;
; Operand 0 then decides this tick. When it is nonzero and bit 7 of
; [$DF0D + stream] is set, the countdown word is cleared and $DF9A moves
; four bytes ahead, past the operands. Otherwise the word is decremented.
; A nonzero result points $DF9A back at this command so the next tick
; repeats it. A zero result does that too when operand 2 and operand 3
; are both zero, and uses the four-byte advance when either one is not.

SoundCommand04:
    ld a, [$DF9C]
    ld d, $00
    ld e, a
    sla e
    ld hl, $DF92
    add hl, de
    ld a, [hl+]
    or [hl]
    jr nz, .operand0

    push bc
    inc bc
    ld a, [bc]
    inc bc
    and a
    jr z, .copyWord

    push hl
    ld a, [bc]
    ld h, a
    inc bc
    ld a, [bc]
    ld l, a
    call $41B9
    inc hl
    ld b, l
    ld a, h
    pop hl
    ld [hl-], a
    ld [hl], b
    pop bc
    jr .operand0

.copyWord:
    ld a, [bc]
    ld [hl-], a
    inc bc
    ld a, [bc]
    ld [hl], a
    pop bc

.operand0:
    ld a, [bc]
    and a
    jr z, .tick

    ld hl, $DF0D
    srl e
    add hl, de
    sla e
    bit 7, [hl]
    jr z, .tick

    ld hl, $DF93
    add hl, de
    xor a
    ld [hl-], a
    ld [hl], a

.advanceFour:
    ld hl, $DF9A
    ld a, [hl]
    add $04
    ld [hl+], a
    ld a, [hl]
    adc $00
    ld [hl], a
    ret

.tick:
    ld hl, $DF92
    add hl, de
    ld a, [hl+]
    ld e, a
    ld d, [hl]
    dec de
    ld a, d
    ld [hl-], a
    ld [hl], e
    or e
    jr nz, .repeat

    ld hl, $0003
    add hl, bc
    ld a, [hl-]
    or [hl]
    jr nz, .advanceFour

.repeat:
    dec bc
    ld hl, $DF9A
    ld a, c
    ld [hl+], a
    ld [hl], b
    ret
