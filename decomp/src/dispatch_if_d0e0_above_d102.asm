; Bank 5 at $43E6. MatchDividerRemainderToFF calls this through
; CallBankedHL after LoadSelectedRecordToD100.
;
; WRAM bank 7 is stored in wCurrentWRAMBank and selected with rSVBK.
; Both names are from timer_overflow.asm.
;
; A zero [$D102] skips the compare and tests HL as the caller left it.
; A nonzero [$D102] loads $D0E0/$D0E1 as a high byte then a low byte and
; subtracts [$D102]. Carry means the word was at least [$D102]. HL is
; then the difference.
;
; A zero result, a borrow, or a zero [$D102] with HL already zero stores
; 2 at $C921 (wSoundSlotA in select_sound_command.asm), stores 1 at
; $D0D8, clears $D0AF, and returns. The caller retries while $D0AF is 0.
;
; Any other result copies [$D103] to $D0B0. [$D103] minus $0A, times 2,
; indexes the word table at $4000 in this bank. JumpHL calls that word.
;
; JumpHL is already source. The $4000 table is still INCBIN.

DispatchIfD0E0AboveD102::
    ld a, $07
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld a, [$D102]
    and a
    jr z, .hlLeftByCaller
    ld c, a
    ld hl, $D0E0
    ld a, [hl+]
    ld l, [hl]
    ld h, a
    ld b, $00
    ld a, c
    cpl
    ld c, a
    ld a, b
    cpl
    ld b, a
    inc bc
    add hl, bc
    jr c, .hlLeftByCaller
.flagRetry:
    ld a, $02
    ld [$C921], a
    ld a, $01
    ld [$D0D8], a
    xor a
    ld [$D0AF], a
    ret

.hlLeftByCaller:
    ld a, h
    or l
    jr z, .flagRetry
    ld a, [$D103]
    ld [$D0B0], a
    sub $0A
    add a
    ld c, a
    ld b, $00
    ld hl, $4000
    add hl, bc
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    call JumpHL
    ret
