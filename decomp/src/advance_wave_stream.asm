; Wave-stream tick. UpdateSoundTick calls this at $56CB when bit 7 of
; wSoundFlags ($DF74) is set.
;
; The word at $DF78 counts down by one. At zero, bit 7 is cleared and
; control jumps to $505C with C = 2, which drops channel 2 from NR51.
;
; Until then, the word at $DF76 is a pointer. $3BEF maps the bank in
; $DF75, copies a waveform from that pointer, restores the bank from
; $DF00, and returns the pointer moved forward. A high byte at or above
; $80 is wrapped to $40 and $DF75 is incremented before the pointer is
; stored back.

AdvanceWaveStream:
    ld hl, wWaveFloor
    ld a, [hl]
    sub $01
    ld [hl+], a
    ld c, a
    ld a, [hl]
    sbc $00
    ld [hl], a
    or c
    jr z, .stream_done

    ld hl, wWaveStep
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    call $3bef
    bit 7, h
    jr z, .store_pointer

    ld h, $40
    ld a, [wWaveWidth]
    inc a
    ld [wWaveWidth], a

.store_pointer:
    ld a, l
    ld b, h
    ld hl, wWaveStep
    ld [hl+], a
    ld [hl], b
    ret

.stream_done:
    ld hl, wSoundFlags
    res 7, [hl]
    ld c, $02
    jp $505c
